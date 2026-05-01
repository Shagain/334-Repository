using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Admin;

[ApiController]
[Authorize(Roles = "Admin")]
public class AdminController : ControllerBase
{
    [HttpGet("admin/users")]
    public IActionResult ListUsers() => Ok();

    [HttpPatch("admin/users/{userId}/role")]
    public IActionResult UpdateUserRole() => Ok();

    [HttpPost("admin/zones")]
    public IActionResult CreateZone() => Ok();

    [HttpPatch("admin/zones/{zoneId}")]
    public IActionResult UpdateZone() => Ok();

    [HttpDelete("admin/zones/{zoneId}")]
    public IActionResult DeleteZone() => Ok();

    [HttpGet("admin/violations")]
    public IActionResult GetViolations() => Ok();

    [HttpPatch("admin/zones/{zoneId}/spots/{spotId}/status")]
    public IActionResult OverrideSpotStatus() => Ok();

    [HttpGet("admin/reports")]
    public IActionResult GetReports() => Ok();
}
