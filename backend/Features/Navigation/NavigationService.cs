using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Entities;
using SmartParking.Domain.Enums;
using SmartParking.Infrastructure.Data;

namespace SmartParking.Features.Navigation;

public class NavigationService : INavigationService
{
    private readonly AppDbContext _context;

    public NavigationService(AppDbContext context)
    {
        _context = context;
    }

    // ----------------------------------------------------
    // 1. MAIN: GET BEST SPOT + ROUTE
    // ----------------------------------------------------
    public async Task<ParkingNavigationResponseDto> GetParkingRouteAsync(
        int zoneId,
        LocationDto from,
        bool preferEV,
        bool preferAccessible,
        int? preferredFloor = null
    )
    {
        var zone = await _context
            .Zones.Include(z => z.Spots)
            .FirstOrDefaultAsync(z => z.ZoneID == zoneId);

        if (zone == null)
            throw new KeyNotFoundException($"Zone {zoneId} not found.");

        var availableSpots = zone.Spots
            .Where(s => s.Status == SpotStatus.Available)
            .ToList();

        if (!availableSpots.Any())
        {
            return new ParkingNavigationResponseDto(
                zoneId,
                null!,
                null!,
                "full",
                "No available spots in this zone."
            );
        }

        var bestSpot = availableSpots
            .Select(s => new
            {
                Spot = s,
                Score = CalculateSpotScore(s, from, preferEV, preferAccessible, preferredFloor)
            })
            .OrderBy(x => x.Score)
            .First().Spot;

        var route = BuildRoute(from, bestSpot);

        return new ParkingNavigationResponseDto(
            zoneId,
            MapSpot(bestSpot),
            route,
            "success",
            null
        );
    }

    // ----------------------------------------------------
    // 2. EXIT ROUTE
    // ----------------------------------------------------
    public async Task<ParkingRouteDto> GetExitRouteAsync(
        int zoneId,
        int spotId,
        LocationDto exitPoint
    )
    {
        var spot = await _context.Spots.FirstOrDefaultAsync(s => s.SpotID == spotId);

        if (spot == null)
            throw new KeyNotFoundException($"Spot {spotId} not found.");

        var start = new LocationDto(spot.X, spot.Y, spot.Floor);

        return BuildRoute(start, new SpotEntityStub(exitPoint));
    }

    // ----------------------------------------------------
    // 3. RE-ROUTE (REAL TIME CHANGES)
    // ----------------------------------------------------
    public Task<ParkingRouteDto> RecalculateRouteAsync(
        int zoneId,
        LocationDto currentLocation,
        int targetSpotId
    )
    {
        return GetExitRouteAsync(zoneId, targetSpotId, currentLocation);
    }

    // ----------------------------------------------------
    // 4. NEARBY SPOTS
    // ----------------------------------------------------
    public async Task<IEnumerable<ParkingSpotSuggestionDto>> GetNearbySpotsAsync(
        int zoneId,
        LocationDto from,
        double radiusMeters = 50
    )
    {
        var zone = await _context.Zones.Include(z => z.Spots)
            .FirstOrDefaultAsync(z => z.ZoneID == zoneId);

        if (zone == null)
            return Enumerable.Empty<ParkingSpotSuggestionDto>();

        return zone.Spots
            .Where(s => s.Status == SpotStatus.Available)
            .Select(s => new ParkingSpotSuggestionDto(
                s.SpotID,
                s.SpotNumber,
                s.Floor,
                new LocationDto(s.X, s.Y, s.Floor),
                Distance(from, new LocationDto(s.X, s.Y, s.Floor)),
                s.IsEVCharging,
                s.IsAccessible,
                s.Status.ToString()
            ))
            .Where(s => s.DistanceFromUserMeters <= radiusMeters)
            .OrderBy(s => s.DistanceFromUserMeters);
    }

    // ----------------------------------------------------
    // SPOT SCORING (SMART PARKING LOGIC)
    // ----------------------------------------------------
    private double CalculateSpotScore(
        Spot s,
        LocationDto from,
        bool preferEV,
        bool preferAccessible,
        int? preferredFloor
    )
    {
        var distance = Distance(from, new LocationDto(s.X, s.Y, s.Floor));

        double score = distance;

        if (preferEV && !s.IsEVCharging)
            score += 1000;

        if (preferAccessible && !s.IsAccessible)
            score += 1000;

        if (preferredFloor != null && s.Floor != preferredFloor.ToString())
            score += 200;

        return score;
    }

    // ----------------------------------------------------
    // ROUTE BUILDER (INDOOR PATH)
    // ----------------------------------------------------
    private ParkingRouteDto BuildRoute(LocationDto from, SpotEntityStub to)
    {
        var steps = new List<ParkingNavigationStepDto>();

        steps.Add(new ParkingNavigationStepDto(
            1,
            $"Move from current location on floor {from.Floor}",
            Distance(from, to.Location),
            from,
            to.Location,
            from.Floor
        ));

        steps.Add(new ParkingNavigationStepDto(
            2,
            $"Arrive at Spot {to.SpotNumber}",
            0,
            to.Location,
            to.Location,
            to.Location.Floor
        ));

        return new ParkingRouteDto(
            TotalDistanceMeters: steps.Sum(s => s.DistanceMeters),
            EstimatedTimeSeconds: (int)(steps.Sum(s => s.DistanceMeters) / 1.4), // walking speed
            StartFloor: from.Floor ?? "Unknown",
            EndFloor: to.Location.Floor ?? "Unknown",
            Steps: steps.ToArray()
        );
    }

    // ----------------------------------------------------
    // DISTANCE (INDOOR EUCLIDEAN)
    // ----------------------------------------------------
    private double Distance(LocationDto a, LocationDto b)
    {
        var dx = a.X - b.X;
        var dy = a.Y - b.Y;
        return Math.Sqrt(dx * dx + dy * dy);
    }

    // ----------------------------------------------------
    // MAPPER
    // ----------------------------------------------------
    private ParkingSpotSuggestionDto MapSpot(Spot s)
    {
        return new ParkingSpotSuggestionDto(
            s.SpotID,
            s.SpotNumber,
            s.Floor,
            new LocationDto(s.X, s.Y, s.Floor),
            0,
            s.IsEVCharging,
            s.IsAccessible,
            s.Status.ToString()
        );
    }

    // ----------------------------------------------------
    // SMALL INTERNAL HELPER
    // ----------------------------------------------------
    private class SpotEntityStub
    {
        public string SpotNumber { get; }
        public LocationDto Location { get; }

        public SpotEntityStub(LocationDto loc)
        {
            SpotNumber = "EXIT";
            Location = loc;
        }
    }
}