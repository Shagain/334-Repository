using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartParking.Domain.Enums;
using SmartParking.Features.Bookings.DTOs;

namespace SmartParking.Features.Bookings;

[ApiController]
[Authorize]
public class BookingsController : ControllerBase
{
    [HttpGet("bookings")]
    public IActionResult GetBookings([FromQuery] BookingStatus? status) => Ok();

    [HttpPost("bookings")]
    public IActionResult CreateBooking([FromBody] BookingRequest request) => Ok();

    [HttpGet("bookings/{bookingId}")]
    public IActionResult GetBooking([FromRoute] int bookingId) => Ok();

    [HttpPatch("bookings/{bookingId}")]
    public IActionResult UpdateBooking(
        [FromRoute] int bookingId,
        [FromBody] BookingRequest request
    ) => Ok();

    [HttpDelete("bookings/{bookingId}")]
    public IActionResult CancelBooking([FromRoute] int bookingId) => Ok();
}
