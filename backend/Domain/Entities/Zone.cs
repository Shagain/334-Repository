using SmartParking.Domain.Common;
using SmartParking.Domain.Enums;

namespace SmartParking.Domain.Entities;

public class Zone : BaseEntity
{
    public int ZoneID { get; set; }
    public string Name { get; set; } = string.Empty;
    public int Capacity { get; set; }
    public double PricePerHour { get; set; }
    public int MaxDuration { get; set; }
    public AccessLevel AccessLevel { get; set; }
    public ZoneType ZoneType { get; set; }
    public string GeoJson { get; set; } = string.Empty;

    public ICollection<ParkingSpot> Spots { get; set; } = new List<ParkingSpot>();
}
