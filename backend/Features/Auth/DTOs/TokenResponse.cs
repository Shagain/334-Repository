namespace SmartParking.Features.Auth.DTOs;

public record TokenResponse(string AccessToken, int ExpiresIn, string TokenType = "Bearer");
