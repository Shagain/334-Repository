using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Violations;

[ApiController]
[Authorize]
public class ViolationsController : ControllerBase
{
    [HttpGet("violations")]
    public IActionResult GetViolations() => Ok();
}
