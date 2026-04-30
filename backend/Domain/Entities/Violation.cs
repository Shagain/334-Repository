using SmartParking.Domain.Common;
using SmartParking.Domain.Enums;

namespace SmartParking.Domain.Entities;

public class Violation : BaseEntity
{
    public int ViolationID { get; set; }
    public ViolationType Type { get; set; }
    public DateTime DetectedAt { get; set; }
    public ViolationStatus Status { get; set; }

    public int? SessionID { get; set; }
    public ParkingSession? Session { get; set; }

    public int UserID { get; set; }
    public User User { get; set; } = null!;
}
