using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartParking.Domain.Entities;

namespace SmartParking.Infrastructure.Persistence;

public class ParkingSessionConfiguration : IEntityTypeConfiguration<ParkingSession>
{
    public void Configure(EntityTypeBuilder<ParkingSession> builder)
    {
        // Explicitly tell EF that SessionID is the Primary Key
        builder.HasKey(ps => ps.SessionID);

        builder.Property(ps => ps.Status).HasMaxLength(20).IsRequired();

        // Relationships are already handled by convention but good to be explicit
        builder.HasOne(ps => ps.User)
               .WithMany(u => u.Sessions)
               .HasForeignKey(ps => ps.UserID);

        builder.HasOne(ps => ps.Spot)
               .WithMany(s => s.Sessions)
               .HasForeignKey(ps => ps.SpotID);

        builder.HasOne(ps => ps.Vehicle)
               .WithMany(v => v.Sessions)
               .HasForeignKey(ps => ps.VehicleID);
    }
}
