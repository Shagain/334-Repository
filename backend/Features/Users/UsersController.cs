using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartParking.Features.Users.DTOs;

namespace SmartParking.Features.Users;

[ApiController]
[Authorize]
public class UsersController : ControllerBase
{
    [HttpGet("users/me")]
    public IActionResult GetMe() => Ok();

    [HttpPatch("users/me")]
    public IActionResult UpdateMe([FromBody] UserProfileUpdate request) => Ok();
}
