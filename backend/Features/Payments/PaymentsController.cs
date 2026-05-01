using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Payments;

[ApiController]
[Authorize]
public class PaymentsController : ControllerBase
{
    [HttpPost("payments")]
    public IActionResult ProcessPayment() => Ok();
}
