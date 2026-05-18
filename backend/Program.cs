using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using SmartParking.Domain.Common;
using SmartParking.Infrastructure.Authentication;
using SmartParking.Infrastructure.Data;
using SmartParking.Features.Auth;
using SmartParking.Features.Zones;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"))
);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IZoneService, ZoneService>();
builder.Services.AddHttpClient<MicrosoftOAuthTokenService>();

if (builder.Environment.IsDevelopment())
{
    builder.Services.AddCors(options =>
    {
        options.AddDefaultPolicy(policy =>
        {
            policy.SetIsOriginAllowed(static origin =>
                origin.StartsWith("http://localhost:", StringComparison.OrdinalIgnoreCase) ||
                origin.StartsWith("http://127.0.0.1:", StringComparison.OrdinalIgnoreCase));
            policy.AllowAnyHeader();
            policy.AllowAnyMethod();
        });
    });
}

// --- Master Switch Security ---
var bypassAuth = builder.Configuration["BYPASS_AUTH"] == "true";

if (bypassAuth)
{
    // Mock Identity & Auth
    builder.Services.AddScoped<ICurrentUserService, MockCurrentUserService>();
    builder.Services.AddAuthentication("Mock")
        .AddScheme<AuthenticationSchemeOptions, MockAuthHandler>("Mock", null);
}
else
{
    // The "Real" JWT config will go here later
    // builder.Services.AddScoped<ICurrentUserService, RealCurrentUserService>();
}

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    var cfg = app.Configuration;
    var tenant = cfg["MicrosoftAuth:TenantId"] ?? cfg["MICROSOFT_TENANT_ID"];
    var client = cfg["MicrosoftAuth:ClientId"] ?? cfg["MICROSOFT_CLIENT_ID"];
    if (string.IsNullOrWhiteSpace(tenant) || string.IsNullOrWhiteSpace(client))
    {
        app.Logger.LogWarning(
            "Microsoft OAuth not configured (missing tenant or client id). "
            + "Ensure frontend/.env has MICROSOFT_TENANT_ID and MICROSOFT_CLIENT_ID, then rebuild the API container.");
    }
    else
    {
        app.Logger.LogInformation("Microsoft OAuth: tenant and client id are configured.");
    }
}

// Auto-run migrations on startup
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<AppDbContext>();
        context.Database.Migrate();
        DbInitializer.Seed(context);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while migrating the database.");
    }
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
}

// CORS must run *before* HTTPS redirection, otherwise the browser's OPTIONS preflight
// can get a redirect response without Access-Control-Allow-* headers and fail.
if (app.Environment.IsDevelopment())
{
    app.UseCors();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
