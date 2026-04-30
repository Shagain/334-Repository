using SmartParking.Domain.Common;
using SmartParking.Domain.Enums;

namespace SmartParking.Domain.Entities;

public class Payment : BaseEntity
{
    public int PaymentID { get; set; }
    public double Amount { get; set; }
    public string Method { get; set; } = string.Empty;
    public PaymentStatus Status { get; set; }
    public DateTime? PaidAt { get; set; }

    public int BookingID { get; set; }
    public Booking Booking { get; set; } = null!;
}
