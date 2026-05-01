using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartParking.Domain.Entities;

namespace SmartParking.Infrastructure.Persistence;

public class ViolationConfiguration : IEntityTypeConfiguration<Violation>
{
    public void Configure(EntityTypeBuilder<Violation> builder)
    {
        builder.HasKey(v => v.ViolationID);
        builder.Property(v => v.Status).HasConversion<string>();
        builder.Property(v => v.Type).HasConversion<string>();

        builder.HasOne(v => v.User)
            .WithMany()
            .HasForeignKey(v => v.UserID);

        builder.HasOne(v => v.Session)
            .WithMany(s => s.Violations)
            .HasForeignKey(v => v.SessionID);
    }
}
