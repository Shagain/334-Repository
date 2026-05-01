using SmartParking.Domain.Entities;
using SmartParking.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace SmartParking.Infrastructure.Data;

public static class DbInitializer
{
    public static void Seed(AppDbContext context)
    {
        // 1. Check if we have any users - if so, assume it's already seeded
        if (context.Users.Any()) return;

        // 2. Seed Users
        var admin = new User { Name = "Admin User", Email = "admin@campus.edu", Role = UserRole.Admin };
        var student = new User { Name = "John Student", Email = "john@student.edu", Role = UserRole.Student };
        var staff = new User { Name = "Jane Staff", Email = "jane@staff.edu", Role = UserRole.Staff };
        
        context.Users.AddRange(admin, student, staff);
        context.SaveChanges(); // Need IDs for foreign keys

        // 3. Seed Zones
        var mainZone = new Zone 
        { 
            Name = "Main Central", 
            Capacity = 50, 
            PricePerHour = 2.50, 
            MaxDuration = 4, 
            AccessLevel = AccessLevel.Student, 
            ZoneType = ZoneType.Regular,
            GeoJson = "{\"type\": \"Polygon\", \"coordinates\": [[[0,0],[0,1],[1,1],[1,0],[0,0]]]}"
        };

        var staffZone = new Zone 
        { 
            Name = "North Staff Only", 
            Capacity = 20, 
            PricePerHour = 1.50, 
            MaxDuration = 10, 
            AccessLevel = AccessLevel.Staff, 
            ZoneType = ZoneType.Accessible,
            GeoJson = "{\"type\": \"Polygon\", \"coordinates\": [[[2,2],[2,3],[3,3],[3,2],[2,2]]]}"
        };

        context.Zones.AddRange(mainZone, staffZone);
        context.SaveChanges();

        // 4. Seed Spots
        var spot1 = new ParkingSpot { SpotNumber = "M-01", Status = SpotStatus.Available, ZoneID = mainZone.ZoneID };
        var spot2 = new ParkingSpot { SpotNumber = "M-02", Status = SpotStatus.Occupied, ZoneID = mainZone.ZoneID };
        var spot3 = new ParkingSpot { SpotNumber = "N-01", Status = SpotStatus.Available, ZoneID = staffZone.ZoneID };

        context.ParkingSpots.AddRange(spot1, spot2, spot3);
        context.SaveChanges();

        // 5. Seed Vehicles
        var studentCar = new Vehicle { LicensePlate = "ABC-123", UserID = student.UserID };
        var staffCar = new Vehicle { LicensePlate = "STAFF-1", UserID = staff.UserID };

        context.Vehicles.AddRange(studentCar, staffCar);
        context.SaveChanges();

        // 6. Seed Booking & Payment
        var booking = new Booking 
        { 
            StartTime = DateTime.UtcNow.AddHours(1), 
            EndTime = DateTime.UtcNow.AddHours(3), 
            Status = BookingStatus.Upcoming,
            UserID = student.UserID,
            SpotID = spot1.SpotID,
            VehicleID = studentCar.VehicleID
        };
        context.Bookings.Add(booking);
        context.SaveChanges();

        var payment = new Payment 
        { 
            Amount = 5.00, 
            Method = "card", 
            Status = PaymentStatus.Paid, 
            PaidAt = DateTime.UtcNow, 
            BookingID = booking.BookingID 
        };
        context.Payments.Add(payment);

        // 7. Seed Session & Violation
        var session = new ParkingSession 
        { 
            StartTime = DateTime.UtcNow.AddHours(-1), 
            Status = "Active",
            UserID = staff.UserID,
            SpotID = spot2.SpotID,
            VehicleID = staffCar.VehicleID
        };
        context.ParkingSessions.Add(session);
        context.SaveChanges();

        var violation = new Violation 
        { 
            Type = ViolationType.Overstay, 
            DetectedAt = DateTime.UtcNow, 
            Status = ViolationStatus.Unresolved,
            SessionID = session.SessionID,
            UserID = staff.UserID
        };
        context.Violations.Add(violation);

        // 8. Seed Notification
        var note = new Notification 
        { 
            Type = "booking_confirmation", 
            Message = "Your booking for M-01 is confirmed.", 
            Channel = "email",
            SentAt = DateTime.UtcNow,
            UserID = student.UserID
        };
        context.Notifications.Add(note);

        context.SaveChanges();
    }
}
