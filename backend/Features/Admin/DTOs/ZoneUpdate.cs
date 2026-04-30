using SmartParking.Domain.Enums;

namespace SmartParking.Features.Admin.DTOs;

public record ZoneUpdate(
    string Name, 
    int Capacity, 
    double PricePerHour, 
    int MaxDuration, 
    AccessLevel AccessLevel, 
    ZoneType ZoneType, 
    string GeoJson);
