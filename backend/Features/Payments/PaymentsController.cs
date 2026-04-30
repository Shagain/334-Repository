using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartParking.Features.Payments.DTOs;

namespace SmartParking.Features.Payments;

[ApiController]
[Authorize]
public class PaymentsController : ControllerBase
{
    [HttpPost("payments")]
    public IActionResult ProcessPayment([FromBody] PaymentRequest request) => Ok();
}
