# Backend Code Structure

```txt
backend/
├── Domain/                 # Enterprise-wide logic and state
│   ├── Entities/           # EF Core Entities (User, Zone, Booking, etc.)
│   ├── Enums/              # Shared Enums (UserRole, BookingStatus, etc.)
│   └── Common/             # Base classes (BaseEntity)
├── Infrastructure/         # External concerns
│   ├── Data/               # AppDbContext & Migrations
│   ├── Persistence/        # EF Core Entity Configurations (Fluent API)
│   └── Authentication/     # Identity & OAuth logic
├── Features/               # Vertical Slices (Feature-based folders)
│   ├── Auth/               # Login, Token Exchange
│   ├── Users/              # Profile, Vehicles, Notifications
│   ├── Zones/              # Zone listing, Spot status, Recommendations
│   ├── Bookings/           # Create, Modify, Cancel bookings
│   ├── Sessions/           # Active sessions, Tracking
│   ├── Payments/           # Payment processing
│   └── Admin/              # Violation management, User/Zone administration
└── Program.cs              # Dependency Injection & Middleware
```
