using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartParking.Domain.Entities;

namespace SmartParking.Infrastructure.Persistence;

public class ParkingSpotConfiguration : IEntityTypeConfiguration<ParkingSpot>
{
    public void Configure(EntityTypeBuilder<ParkingSpot> builder)
    {
        builder.HasKey(s => s.SpotID);
        builder.Property(s => s.SpotNumber).HasMaxLength(10).IsRequired();
        builder.Property(s => s.Status).HasConversion<string>();

        builder.HasOne(s => s.Zone)
            .WithMany(z => z.Spots)
            .HasForeignKey(s => s.ZoneID);
    }
}
