using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartParking.Domain.Enums;
using SmartParking.Features.Admin.DTOs;

namespace SmartParking.Features.Admin;

[ApiController]
[Authorize(Roles = "Admin")]
public class AdminController : ControllerBase
{
    [HttpGet("admin/users")]
    public IActionResult ListUsers([FromQuery] string? query) => Ok();

    [HttpPatch("admin/users/{userId}/role")]
    public IActionResult UpdateUserRole([FromRoute] int userId, [FromBody] UserRoleUpdate request) => Ok();

    [HttpPost("admin/zones")]
    public IActionResult CreateZone([FromBody] ZoneUpdate request) => Ok();

    [HttpPatch("admin/zones/{zoneId}")]
    public IActionResult UpdateZone([FromRoute] int zoneId, [FromBody] ZoneUpdate request) => Ok();

    [HttpDelete("admin/zones/{zoneId}")]
    public IActionResult DeleteZone([FromRoute] int zoneId) => Ok();

    [HttpGet("admin/violations")]
    public IActionResult GetViolations() => Ok();

    [HttpPatch("admin/zones/{zoneId}/spots/{spotId}/status")]
    public IActionResult OverrideSpotStatus([FromRoute] int zoneId, [FromRoute] int spotId, [FromBody] SpotStatusOverride request) => Ok();

    [HttpGet("admin/reports")]
    public IActionResult GetReports(
        [FromQuery] ReportType reportType,
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate) => Ok();
}
