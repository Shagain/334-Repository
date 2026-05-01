using SmartParking.Domain.Enums;

namespace SmartParking.Domain.Entities;

public class Booking
{
    public int BookingID { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public BookingStatus Status { get; set; }

    public int UserID { get; set; }
    public User User { get; set; } = null!;

    public int SpotID { get; set; }
    public ParkingSpot Spot { get; set; } = null!;

    public int VehicleID { get; set; }
    public Vehicle Vehicle { get; set; } = null!;

    public Payment? Payment { get; set; }
}
