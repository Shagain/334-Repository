using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Sessions;

[ApiController]
[Authorize]
public class SessionsController : ControllerBase
{
    [HttpGet("parking-sessions")]
    public IActionResult GetSessions() => Ok();
}
