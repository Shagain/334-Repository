using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Entities;
using SmartParking.Domain.Enums;
using SmartParking.Infrastructure.Data;

namespace SmartParking.Features.Zones;

public class ZoneService : IZoneService
{
    private readonly AppDbContext _context;

    public ZoneService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Zone>> GetRecommendedZonesAsync(double userLat, double userLng)
    {
        var zones = await _context.Zones
            .Include(z => z.Spots)
            .ToListAsync();

        return zones
            .Select(zone => new
            {
                Zone = zone,
                Score = CalculateSmartScore(userLat, userLng, zone)
            })
            .OrderBy(z => z.Score)
            .Select(z => z.Zone);
    }

    private double CalculateSmartScore(double userLat, double userLng, Zone zone)
    {
        var distance = CalculateDistanceToZone(userLat, userLng, zone);
        var availableSpots = zone.Spots.Count(s => s.Status == SpotStatus.Available);

        // --- SMART RANKING FORMULA ---
        // 1. Distance is the primary weight (1km = 10 units)
        // 2. Price is a subtle preference (1 unit = $2.00)
        // 3. Availability is a HARD penalty if full

        double score = (distance * 10.0) + (zone.PricePerHour * 0.5);

        if (availableSpots == 0)
        {
            score += 10000; // Massive penalty for full zones
        }
        else if (availableSpots < 10)
        {
            score += 2; // Slight penalty for zones that are almost full
        }

        return score;
    }

    private double CalculateDistanceToZone(double userLat, double userLng, Zone zone)
    {
        var centroid = GetCentroid(zone.GeoJson);
        return HaversineDistance(userLat, userLng, centroid.Lat, centroid.Lng);
    }

    private (double Lat, double Lng) GetCentroid(string geoJson)
    {
        try
        {
            using var doc = JsonDocument.Parse(geoJson);
            var root = doc.RootElement;
            var type = root.GetProperty("type").GetString();

            // For both Polygon and MultiPolygon, we'll flatten all coordinates and average them
            var lats = new List<double>();
            var lngs = new List<double>();

            void ExtractCoords(JsonElement element)
            {
                if (element.ValueKind == JsonValueKind.Array)
                {
                    if (
                        element.GetArrayLength() == 2
                        && element[0].ValueKind == JsonValueKind.Number
                    )
                    {
                        lngs.Add(element[0].GetDouble());
                        lats.Add(element[1].GetDouble());
                    }
                    else
                    {
                        foreach (var item in element.EnumerateArray())
                            ExtractCoords(item);
                    }
                }
            }

            ExtractCoords(root.GetProperty("coordinates"));

            return (lats.Average(), lngs.Average());
        }
        catch
        {
            return (0, 0); // Fallback for invalid GeoJSON
        }
    }

    private double HaversineDistance(double lat1, double lon1, double lat2, double lon2)
    {
        const double R = 6371; // Earth radius in KM
        var dLat = ToRadians(lat2 - lat1);
        var dLon = ToRadians(lon2 - lon1);

        var a =
            Math.Sin(dLat / 2) * Math.Sin(dLat / 2)
            + Math.Cos(ToRadians(lat1))
                * Math.Cos(ToRadians(lat2))
                * Math.Sin(dLon / 2)
                * Math.Sin(dLon / 2);

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return R * c;
    }

    private double ToRadians(double angle) => Math.PI * angle / 180.0;
}
