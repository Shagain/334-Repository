using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartParking.Features.Vehicles.DTOs;

namespace SmartParking.Features.Vehicles;

[ApiController]
[Authorize]
public class VehiclesController : ControllerBase
{
    [HttpGet("vehicles")]
    public IActionResult GetVehicles() => Ok();

    [HttpPost("vehicles")]
    public IActionResult RegisterVehicle([FromBody] VehicleRegistrationRequest request) => Ok();

    [HttpDelete("vehicles/{vehicleId}")]
    public IActionResult DeleteVehicle([FromRoute] int vehicleId) => Ok();
}
