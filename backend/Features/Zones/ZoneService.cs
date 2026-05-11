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
        var zones = await _context.Zones.Include(z => z.Spots).ToListAsync();

        return zones
            .Select(zone => new
            {
                Zone = zone,
                Score = CalculateSmartScore(userLat, userLng, zone),
            })
            .OrderBy(z => z.Score)
            .Select(z => z.Zone);
    }

    public async Task<ZoneStatsDto> GetZoneStatsAsync(int zoneId)
    {
        var zone = await _context
            .Zones.Include(z => z.Spots)
            .FirstOrDefaultAsync(z => z.ZoneID == zoneId);

        if (zone == null)
            throw new KeyNotFoundException($"Zone {zoneId} not found.");

        var spotIds = zone.Spots.Select(s => s.SpotID).ToList();
        var now = DateTime.UtcNow;
        var monthAgo = now.AddDays(-30);
        var weekAgo = now.AddDays(-7);

        // 1. Average Occupancy (Last 30 days)
        // Utility = (Sum of all Session Durations) / (Total Capacity * 30d * 24h)
        var sessionsMonth = await _context
            .ParkingSessions.Where(s => spotIds.Contains(s.SpotID) && s.StartTime >= monthAgo)
            .ToListAsync();

        double totalSessionSeconds = 0;
        foreach (var s in sessionsMonth)
        {
            var end = s.EndTime ?? now;
            var start = s.StartTime < monthAgo ? monthAgo : s.StartTime;
            totalSessionSeconds += (end - start).TotalSeconds;
        }

        var totalPotentialSeconds = zone.Spots.Count * 86400.0 * 30;
        var avgOccupancy =
            totalPotentialSeconds > 0 ? (totalSessionSeconds / totalPotentialSeconds) * 100 : 0;

        var sessionsWeek = await _context
            .ParkingSessions.Where(s => spotIds.Contains(s.SpotID) && s.StartTime >= weekAgo)
            .ToListAsync();

        // 2. Weekly Trends (Last 30 days, grouped by Day of Week)
        // Count how many of each DayOfWeek occurred in the last 30 days
        var dayCounts = new Dictionary<DayOfWeek, int>();
        for (int i = 0; i < 30; i++)
        {
            var d = now.AddDays(-i).DayOfWeek;
            dayCounts[d] = dayCounts.GetValueOrDefault(d) + 1;
        }

        var weeklyTrends = sessionsMonth
            .GroupBy(s => s.StartTime.DayOfWeek)
            .Select(g =>
            {
                var totalSeconds = 0.0;
                foreach (var s in g)
                {
                    var end = s.EndTime ?? now;
                    var start = s.StartTime < monthAgo ? monthAgo : s.StartTime;
                    totalSeconds += (end - start).TotalSeconds;
                }

                var occurrences = dayCounts.GetValueOrDefault(g.Key, 1);
                var avg = (totalSeconds / (zone.Spots.Count * 86400.0 * occurrences)) * 100;
                return new TrendItemDto(g.Key.ToString().ToUpper()[..3], Math.Round(avg, 1));
            })
            .ToArray();

        // Ensure all days are present
        var days = new[] { "MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN" };
        weeklyTrends = days.Select(d =>
                weeklyTrends.FirstOrDefault(t => t.Label == d) ?? new TrendItemDto(d, 0.0)
            )
            .ToArray();

        // 3. Hourly Trends (Last 7 days, averaged by hour)
        var hourlyTrends = new List<TrendItemDto>();
        for (int h = 0; h < 24; h++)
        {
            // Simplified hourly logic: % of time this hour was occupied over last 7 days
            var sessionsInHour = sessionsWeek
                .Where(s =>
                    (s.StartTime.Hour <= h && (s.EndTime ?? now).Hour >= h)
                    || (s.StartTime.Hour <= h && (s.EndTime ?? now).Day > s.StartTime.Day)
                )
                .ToList();

            var hourAvg = (sessionsInHour.Count / (zone.Spots.Count * 7.0)) * 100;
            hourlyTrends.Add(
                new TrendItemDto($"{h:D2}:00", Math.Round(Math.Min(hourAvg, 100.0), 1))
            );
        }

        return new ZoneStatsDto(
            zoneId,
            Math.Round(avgOccupancy, 1),
            weeklyTrends,
            hourlyTrends.ToArray()
        );
    }

    public async Task<PredictionResponseDto> GetPredictionsAsync(
        int zoneId,
        DateTime start,
        DateTime end
    )
    {
        var zone = await _context
            .Zones.Include(z => z.Spots)
            .FirstOrDefaultAsync(z => z.ZoneID == zoneId);
        if (zone == null)
            throw new KeyNotFoundException($"Zone {zoneId} not found.");

        var spotIds = zone.Spots.Select(s => s.SpotID).ToList();
        var now = DateTime.UtcNow;

        // 1. Get Historical Averages (per Hour/DayOfWeek)
        // We'll calculate this on the fly for the range requested
        var monthAgo = now.AddDays(-30);
        var sessions = await _context
            .ParkingSessions.Where(s => spotIds.Contains(s.SpotID) && s.StartTime >= monthAgo)
            .ToListAsync();

        // 2. Get Specific Future Bookings in the range
        var bookings = await _context
            .Bookings.Where(b =>
                spotIds.Contains(b.SpotID) && b.StartTime >= start && b.StartTime <= end
            )
            .ToListAsync();

        var predictions = new List<PredictionItemDto>();
        for (var slot = start; slot <= end; slot = slot.AddHours(1))
        {
            // A. Historical Occupancy for this hour/day
            var day = slot.DayOfWeek;
            var hour = slot.Hour;

            var histSessions = sessions
                .Where(s => s.StartTime.DayOfWeek == day && s.StartTime.Hour == hour)
                .ToList();
            // Count occurrences of this day in the 30-day window
            int dayOccurrences = 0;
            for (int i = 0; i < 30; i++)
                if (now.AddDays(-i).DayOfWeek == day)
                    dayOccurrences++;

            double histAvgCount =
                dayOccurrences > 0 ? histSessions.Count / (double)dayOccurrences : 0;

            // B. Booking Count for this specific hour
            double bookingCount = bookings.Count(b => b.StartTime <= slot && b.EndTime > slot);

            // C. Hybrid Logic
            double predictedLoad = Math.Max(histAvgCount, bookingCount);
            double probability = Math.Max(0, 1.0 - (predictedLoad / zone.Capacity));
            int available = (int)Math.Max(0, zone.Capacity - predictedLoad);

            predictions.Add(new PredictionItemDto(slot, Math.Round(probability, 2), available));
        }

        return new PredictionResponseDto(zoneId, predictions.ToArray());
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
