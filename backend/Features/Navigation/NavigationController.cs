using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Navigation;

[ApiController]
[Authorize]
public class NavigationController : ControllerBase
{
    [HttpGet("navigation/route")]
    public IActionResult GetRoute() => Ok();
}
