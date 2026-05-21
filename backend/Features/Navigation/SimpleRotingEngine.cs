using SmartParking.Features.Navigation;

namespace SmartParking.Infrastructure.Services;

public class SimpleRoutingEngine : IRoutingEngine
{
    private readonly ILogger<SimpleRoutingEngine> _logger;

    public SimpleRoutingEngine(ILogger<SimpleRoutingEngine> logger)
    {
        _logger = logger;
    }

    public Task<ParkingRouteDto> CalculateIndoorRouteAsync(
        LocationDto from,
        LocationDto to,
        int zoneId)
    {
        _logger.LogInformation("Calculating route from ({FromLat}, {FromLng}) to ({ToLat}, {ToLng}) in zone {ZoneId}",
            from.Latitude, from.Longitude, to.Latitude, to.Longitude, zoneId);

        // Calculate distance
        var distance = CalculateDistance(from, to);
        
        // Estimate time (assuming walking speed of 1.4 m/s or 84 m/min)
        var estimatedMinutes = (int)Math.Ceiling(distance / 84);
        
        // Generate simple waypoints
        var waypoints = new List<RoutePointDto>
        {
            new RoutePointDto
            {
                Location = from,
                Sequence = 0,
                Instruction = "Start",
                CumulativeDistance = 0
            },
            new RoutePointDto
            {
                Location = to,
                Sequence = 1,
                Instruction = "Arrive at destination",
                CumulativeDistance = distance
            }
        };

        var instructions = new List<NavigationInstructionDto>
        {
            new NavigationInstructionDto
            {
                Text = $"Walk {(distance > 50 ? "straight" : "to the spot")}",
                Maneuver = ManeuverType.Straight,
                DistanceMeters = distance,
                DurationSeconds = estimatedMinutes * 60,
                Location = from
            },
            new NavigationInstructionDto
            {
                Text = "Arrive at your parking spot",
                Maneuver = ManeuverType.Arrive,
                DistanceMeters = 0,
                DurationSeconds = 0,
                Location = to
            }
        };

        var route = new ParkingRouteDto
        {
            ZoneId = zoneId,
            SpotId = null,
            StartLocation = from,
            EndLocation = to,
            Waypoints = waypoints,
            TotalDistanceMeters = distance,
            EstimatedMinutes = estimatedMinutes,
            Instructions = instructions,
            PolylineEncoded = GenerateSimplePolyline(from, to),
            IsRecalculated = false
        };

        return Task.FromResult(route);
    }

    private double CalculateDistance(LocationDto from, LocationDto to)
    {
        var R = 6371000;
        var lat1 = from.Latitude * Math.PI / 180;
        var lat2 = to.Latitude * Math.PI / 180;
        var deltaLat = (to.Latitude - from.Latitude) * Math.PI / 180;
        var deltaLon = (to.Longitude - from.Longitude) * Math.PI / 180;
        
        var a = Math.Sin(deltaLat / 2) * Math.Sin(deltaLat / 2) +
                Math.Cos(lat1) * Math.Cos(lat2) *
                Math.Sin(deltaLon / 2) * Math.Sin(deltaLon / 2);
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        
        return R * c;
    }

    private string GenerateSimplePolyline(LocationDto from, LocationDto to)
    {
        // Simplified polyline encoding (just for demo)
        return $"{from.Latitude},{from.Longitude}|{to.Latitude},{to.Longitude}";
    }
}