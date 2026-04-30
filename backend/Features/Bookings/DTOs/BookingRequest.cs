namespace SmartParking.Features.Bookings.DTOs;

public record BookingRequest(
    DateTime StartTime, 
    DateTime EndTime, 
    int UserID, 
    int SpotID, 
    int VehicleID);
