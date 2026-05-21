namespace SmartParking.Features.ParkingNavigation;

/// <summary>
/// Internal car park coordinate system (NOT GPS)
/// </summary>
public record LocationDto(
    double X,
    double Y,
    string? Floor = null
);

/// <summary>
/// Request to start parking navigation
/// </summary>
public record ParkingNavigationRequestDto(
    int ZoneID,
    LocationDto From,
    int? PreferredFloor,
    bool PreferEVSpot,
    bool PreferAccessibleSpot
);

/// <summary>
/// Suggested parking spot result
/// </summary>
public record ParkingSpotSuggestionDto(
    int SpotID,
    string SpotNumber,
    string Floor,
    LocationDto Location,
    double DistanceFromUserMeters,
    bool IsEVChargingAvailable,
    bool IsAccessible,
    string Status // "available", "reserved"
);

/// <summary>
/// One step in indoor navigation (car park directions)
/// </summary>
public record ParkingNavigationStepDto(
    int StepIndex,
    string Instruction,
    double DistanceMeters,
    LocationDto StartLocation,
    LocationDto EndLocation,
    string? Floor
);

/// <summary>
/// Full route inside the car park
/// </summary>
public record ParkingRouteDto(
    double TotalDistanceMeters,
    int EstimatedTimeSeconds,
    string StartFloor,
    string EndFloor,
    ParkingNavigationStepDto[] Steps
);

/// <summary>
/// Final response returned to frontend
/// </summary>
public record ParkingNavigationResponseDto(
    int ZoneID,
    ParkingSpotSuggestionDto SelectedSpot,
    ParkingRouteDto RouteToSpot,
    string Status, // "success", "full", "no_spots_available"
    string? Message
);