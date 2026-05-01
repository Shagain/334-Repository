namespace SmartParking.Domain.Common;

public interface ICurrentUserService
{
    /// Returns the ID of the currently authenticated user extracted from the Bearer Token (JWT).
    /// Returns null if the user is not authenticated.
    int? UserId { get; }
}
