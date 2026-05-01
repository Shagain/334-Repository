using System.Security.Claims;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;

namespace SmartParking.Infrastructure.Authentication;

/// A "Fake" Authentication Handler that automatically signs in every request as an Admin.
/// Only used for development when BYPASS_AUTH=true.
public class MockAuthHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    public MockAuthHandler(
        IOptionsMonitor<AuthenticationSchemeOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder
    )
        : base(options, logger, encoder) { }

    protected override Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        // Create a fake identity
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, "2"), // John Student's ID
            new Claim(ClaimTypes.Name, "Demo User"),
            new Claim(ClaimTypes.Email, "demo@campus.edu"),
            new Claim(ClaimTypes.Role, "Admin"), // Grant full admin powers for testing
            new Claim(ClaimTypes.Role, "Student"),
            new Claim(ClaimTypes.Role, "Staff"),
        };

        var identity = new ClaimsIdentity(claims, "Mock");
        var principal = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principal, "Mock");

        return Task.FromResult(AuthenticateResult.Success(ticket));
    }
}
