using SmartParking.Domain.Entities;

namespace SmartParking.Features.Zones;

public interface IZoneService
{
    Task<IEnumerable<Zone>> GetRecommendedZonesAsync(double userLat, double userLng);
}
