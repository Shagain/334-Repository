using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartParking.Features.Zones.DTOs;

namespace SmartParking.Features.Zones;

[ApiController]
[Authorize]
public class ZonesController : ControllerBase
{
    [HttpGet("zones")]
    public IActionResult GetZones() => Ok();

    [HttpGet("zones/recommendations")]
    public IActionResult GetRecommendations([FromQuery] double originLat, [FromQuery] double originLng) => Ok();

    [HttpGet("zones/{zoneId}/spots")]
    public IActionResult GetSpots([FromRoute] int zoneId) => Ok();

    [HttpGet("zones/{zoneId}/stats")]
    public IActionResult GetStats([FromRoute] int zoneId) => Ok();

    [HttpGet("zones/{zoneId}/predictions")]
    public IActionResult GetPredictions([FromRoute] int zoneId, [FromQuery] DateTime startDateTime, [FromQuery] DateTime endDateTime) => Ok();
}
