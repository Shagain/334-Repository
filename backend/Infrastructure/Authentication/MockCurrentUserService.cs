using SmartParking.Domain.Common;

namespace SmartParking.Infrastructure.Authentication;

/// TEMP MOCK: This is a placeholder to allow parallel development.
/// It will be replaced with a real JWT-based implementation once the Auth feature is complete.
public class MockCurrentUserService : ICurrentUserService
{
    // Hardcoded to John Student (ID 2 from our Seeder) for development purposes.
    public int? UserId => 2;
}
