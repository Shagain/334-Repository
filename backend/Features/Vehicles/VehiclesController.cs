using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Vehicles;

[ApiController]
[Authorize]
public class VehiclesController : ControllerBase
{
    [HttpGet("vehicles")]
    public IActionResult GetVehicles() => Ok();

    [HttpPost("vehicles")]
    public IActionResult RegisterVehicle() => Ok();

    [HttpDelete("vehicles/{vehicleId}")]
    public IActionResult DeleteVehicle() => Ok();
}
