using SmartParking.Features.Navigation;

namespace SmartParking.Domain.Services;

public interface IRoutingEngine
{
    Task<ParkingRouteDto> CalculateIndoorRouteAsync(
        LocationDto from,
        LocationDto to,
        int zoneId);
}