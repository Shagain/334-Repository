namespace SmartParking.Features.Zones;

public record ZoneDto(
    int ZoneID,
    string Name,
    int Capacity,
    double PricePerHour,
    int MaxDuration,
    string AccessLevel,
    string ZoneType,
    object GeoJson
);

public record ParkingSpotDto(
    int SpotID,
    string SpotNumber,
    string Status,
    int ZoneID
);

public record TrendItemDto(string Label, double Value);

public record ZoneStatsDto(
    int ZoneID,
    double AverageOccupancy,
    TrendItemDto[] WeeklyTrends,
    TrendItemDto[] HourlyTrends
);
