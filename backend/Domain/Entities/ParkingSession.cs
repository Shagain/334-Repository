using SmartParking.Domain.Common;
using SmartParking.Domain.Enums;

namespace SmartParking.Domain.Entities;

public class ParkingSession : BaseEntity
{
    public int SessionID { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime? EndTime { get; set; }
    public string Status { get; set; } = string.Empty;

    public int UserID { get; set; }
    public User User { get; set; } = null!;

    public int SpotID { get; set; }
    public ParkingSpot Spot { get; set; } = null!;

    public int VehicleID { get; set; }
    public Vehicle Vehicle { get; set; } = null!;

    public ICollection<Violation> Violations { get; set; } = new List<Violation>();
}
