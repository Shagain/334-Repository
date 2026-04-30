using Microsoft.AspNetCore.Mvc;
using SmartParking.Features.Auth.DTOs;

namespace SmartParking.Features.Auth;

[ApiController]
public class AuthController : ControllerBase
{
    [HttpPost("auth/token")]
    public IActionResult GetToken([FromBody] TokenExchangeRequest request) => Ok();
}
