using SmartParking.Domain.Entities;

namespace SmartParking.Features.Navigation;

public interface INavigationService
{
    /// <summary>
    /// Finds best parking spot and generates route inside car park
    /// </summary>
    Task<ParkingNavigationResponseDto> GetParkingRouteAsync(
        int zoneId,
        LocationDto from,
        bool preferEV,
        bool preferAccessible,
        int? preferredFloor = null
    );

    /// <summary>
    /// Calculates route from current spot to exit gate
    /// </summary>
    Task<ParkingRouteDto> GetExitRouteAsync(
        int zoneId,
        int spotId,
        LocationDto exitPoint
    );

    /// <summary>
    /// Recalculate route if user deviates or spot becomes unavailable
    /// </summary>
    Task<ParkingRouteDto> RecalculateRouteAsync(
        int zoneId,
        LocationDto currentLocation,
        int targetSpotId
    );

    /// <summary>
    /// Get nearby available parking spots for preview
    /// </summary>
    Task<IEnumerable<ParkingSpotSuggestionDto>> GetNearbySpotsAsync(
        int zoneId,
        LocationDto from,
        double radiusMeters = 50
    );
}