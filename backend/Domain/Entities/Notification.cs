
namespace SmartParking.Domain.Entities;

public class Notification
{
    public int NotificationID { get; set; }
    public string Type { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string Channel { get; set; } = string.Empty;
    public DateTime SentAt { get; set; }

    public int UserID { get; set; }
    public User User { get; set; } = null!;
}
