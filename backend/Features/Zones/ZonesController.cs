using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Zones;

[ApiController]
[Authorize]
public class ZonesController : ControllerBase
{
    [HttpGet("zones")]
    public IActionResult GetZones() => Ok();

    [HttpGet("zones/recommendations")]
    public IActionResult GetRecommendations() => Ok();

    [HttpGet("zones/{zoneId}/spots")]
    public IActionResult GetSpots() => Ok();

    [HttpGet("zones/{zoneId}/stats")]
    public IActionResult GetStats() => Ok();

    [HttpGet("zones/{zoneId}/predictions")]
    public IActionResult GetPredictions() => Ok();
}
