namespace SmartParking.Features.Payments.DTOs;
public record PaymentRequest(double Amount, string Method, int BookingID);
