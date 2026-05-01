using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace SmartParking.Features.Bookings;

[ApiController]
[Authorize]
public class BookingsController : ControllerBase
{
    [HttpGet("bookings")]
    public IActionResult GetBookings() => Ok();

    [HttpPost("bookings")]
    public IActionResult CreateBooking() => Ok();

    [HttpGet("bookings/{bookingId}")]
    public IActionResult GetBooking() => Ok();

    [HttpPatch("bookings/{bookingId}")]
    public IActionResult UpdateBooking() => Ok();

    [HttpDelete("bookings/{bookingId}")]
    public IActionResult CancelBooking() => Ok();
}
