using SmartParking.Domain.Entities;
using SmartParking.Domain.Enums;

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

        // 3. Seed Zones (Unified Manual Merged Polygons from Official API)
        var p1Zone = new Zone
        {
            Name = "P1 - Multi Level Parking",
            Capacity = 450,
            PricePerHour = 4.00,
            MaxDuration = 10,
            AccessLevel = AccessLevel.Staff,
            ZoneType = ZoneType.EV,
            GeoJson = "{\"type\": \"Polygon\", \"coordinates\": [[[150.878005, -34.407659], [150.878604, -34.407742], [150.878655, -34.407442], [150.878059, -34.407365], [150.878005, -34.407659]]]}"
        };

        var p2Zone = new Zone
        {
            Name = "P2 - Main Car Park",
            Capacity = 200,
            PricePerHour = 2.00,
            MaxDuration = 8,
            AccessLevel = AccessLevel.Student,
            ZoneType = ZoneType.Regular,
            GeoJson = "{\"type\": \"Polygon\", \"coordinates\": [[[150.877957, -34.406783], [150.87777, -34.406763], [150.877662, -34.406753], [150.877337, -34.406712], [150.877269, -34.406706], [150.87721, -34.40702], [150.877553, -34.407328], [150.877739, -34.407468], [150.877838, -34.407515], [150.877957, -34.406783]]]}"
        };

        var p3Zone = new Zone
        {
            Name = "P3 - South Western Carpark",
            Capacity = 120,
            PricePerHour = 2.00,
            MaxDuration = 6,
            AccessLevel = AccessLevel.Student,
            ZoneType = ZoneType.Regular,
            GeoJson = "{\"type\": \"Polygon\", \"coordinates\": [[[150.873886, -34.405726], [150.87456, -34.405811], [150.874802, -34.405909], [150.875027, -34.406037], [150.875181, -34.406153], [150.874541, -34.406548], [150.873728, -34.406428], [150.873792, -34.406118], [150.873819, -34.405992], [150.873886, -34.405726]]]}"
        };

        var p4Zone = new Zone
        {
            Name = "P4 - Western Carpark",
            Capacity = 80,
            PricePerHour = 0.00,
            MaxDuration = 8,
            AccessLevel = AccessLevel.Student,
            ZoneType = ZoneType.Regular,
            GeoJson = "{\"type\": \"Polygon\", \"coordinates\": [[[150.873009, -34.40328], [150.87482, -34.403497], [150.874747, -34.40396], [150.874714, -34.404199], [150.874446, -34.404172], [150.874371, -34.404695], [150.874092, -34.404659], [150.874081, -34.404482], [150.87317, -34.404367], [150.872944, -34.403969], [150.872955, -34.403721], [150.873009, -34.40328]]]}"
        };

        var p5Zone = new Zone
        {
            Name = "P5 - Northern Carpark",
            Capacity = 60,
            PricePerHour = 2.00,
            MaxDuration = 4,
            AccessLevel = AccessLevel.Student,
            ZoneType = ZoneType.Regular,
            GeoJson = "{\"type\": \"Polygon\", \"coordinates\": [[[150.877518, -34.401721], [150.878, -34.401778], [150.877873, -34.402447], [150.878385, -34.402526], [150.878736, -34.402796], [150.878545, -34.403856], [150.877633, -34.40373], [150.87637, -34.403598], [150.876452, -34.403477], [150.876645, -34.403502], [150.876704, -34.403404], [150.877027, -34.403343], [150.877221, -34.403332], [150.877251, -34.403051], [150.877486, -34.401833], [150.877518, -34.401721]]]}"
        };

        var p6Zone = new Zone
        {
            Name = "P6 - Sports Hub",
            Capacity = 30,
            PricePerHour = 5.00,
            MaxDuration = 2,
            AccessLevel = AccessLevel.Visitor,
            ZoneType = ZoneType.EV,
            GeoJson = "{\"type\": \"Polygon\", \"coordinates\": [[[150.879537, -34.403047], [150.879453, -34.403531], [150.880248, -34.403613], [150.880324, -34.403142], [150.879537, -34.403047]]]}"
        };

        var p8Zone = new Zone
        {
            Name = "P8 - Unicentre Carpark",
            Capacity = 150,
            PricePerHour = 3.50,
            MaxDuration = 4,
            AccessLevel = AccessLevel.Student,
            ZoneType = ZoneType.EV,
            GeoJson = "{\"type\": \"Polygon\", \"coordinates\": [[[150.880614, -34.407523], [150.881725, -34.407642], [150.881687, -34.407979], [150.881641, -34.408267], [150.880452, -34.408132], [150.880494, -34.407851], [150.880509, -34.407849], [150.880529, -34.407762], [150.880578, -34.407721], [150.880614, -34.407523]]]}"
        };

        context.Zones.AddRange(p1Zone, p2Zone, p3Zone, p4Zone, p5Zone, p6Zone, p8Zone);
        context.SaveChanges();

        // 4. Seed Spots (Auto-Generate based on Capacity)
        var allSpots = new List<ParkingSpot>();
        
        void AddSpots(Zone zone, string prefix)
        {
            for (int i = 1; i <= zone.Capacity; i++)
            {
                allSpots.Add(new ParkingSpot 
                { 
                    SpotNumber = $"{prefix}-{i:D3}", 
                    Status = SpotStatus.Available, 
                    ZoneID = zone.ZoneID 
                });
            }
        }

        AddSpots(p1Zone, "P1");
        AddSpots(p2Zone, "P2");
        AddSpots(p3Zone, "P3");
        AddSpots(p4Zone, "P4");
        AddSpots(p5Zone, "P5");
        AddSpots(p6Zone, "P6");
        AddSpots(p8Zone, "P8");

        context.ParkingSpots.AddRange(allSpots);
        context.SaveChanges();

        // Reference some spots for sample data
        var firstP1Spot = allSpots.First(s => s.ZoneID == p1Zone.ZoneID);
        var firstP2Spot = allSpots.First(s => s.ZoneID == p2Zone.ZoneID);

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
            SpotID = firstP1Spot.SpotID,
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
            SpotID = firstP2Spot.SpotID,
            VehicleID = staffCar.VehicleID
        };
        context.ParkingSessions.Add(session);
        context.SaveChanges();
        
        // Mark the session spot as occupied
        firstP2Spot.Status = SpotStatus.Occupied;
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
            Message = $"Your booking for {firstP1Spot.SpotNumber} is confirmed.", 
            Channel = "email",
            SentAt = DateTime.UtcNow,
            UserID = student.UserID
        };
        context.Notifications.Add(note);

        context.SaveChanges();
    }
}
