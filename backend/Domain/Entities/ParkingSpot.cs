using SmartParking.Domain.Common;
using SmartParking.Domain.Enums;

namespace SmartParking.Domain.Entities;

public class ParkingSpot : BaseEntity
{
    public int SpotID { get; set; }
    public string SpotNumber { get; set; } = string.Empty;
    public SpotStatus Status { get; set; }

    public int ZoneID { get; set; }
    public Zone Zone { get; set; } = null!;

    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    public ICollection<ParkingSession> Sessions { get; set; } = new List<ParkingSession>();
}
