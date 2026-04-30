namespace SmartParking.Features.Auth.DTOs;

public record TokenExchangeRequest(string Provider, string Code, string CodeVerifier);
