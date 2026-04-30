using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Notifications;

[ApiController]
[Authorize]
public class NotificationsController : ControllerBase
{
    [HttpGet("notifications")]
    public IActionResult GetNotifications() => Ok();
}
