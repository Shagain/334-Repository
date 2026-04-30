using SmartParking.Domain.Common;

namespace SmartParking.Domain.Entities;

public class Vehicle : BaseEntity
{
    public int VehicleID { get; set; }
    public string LicensePlate { get; set; } = string.Empty;

    public int UserID { get; set; }
    public User User { get; set; } = null!;

    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    public ICollection<ParkingSession> Sessions { get; set; } = new List<ParkingSession>();
}
