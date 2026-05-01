# Where To Put What

This project follows a **Vertical Slice Architecture**, ensuring that features are isolated and easy to maintain.

```txt
backend/
├── Domain/                 # Enterprise-wide logic and state (Truth)
│   ├── Entities/           # Database models strictly matching ERD
│   └── Enums/              # Typed constants (Role, Status, Type)
├── Infrastructure/         # Technical implementations
│   ├── Data/               # DB Context, Seed Data, and Migrations
│   └── Persistence/        # Fluent API Configurations (Mapping Truth to DB)
├── Features/               # Vertical Slices (The meat of the app)
│   ├── Auth/               # Authentication & Authorization (Includes Token Logic)
│   ├── Users/              # Profile management
│   ├── Vehicles/           # License plate & car registration
│   ├── Bookings/           # Reservation lifecycle
│   ├── Sessions/           # Real-time parking tracking
│   ├── Notifications/      # Alerts and push messages
│   ├── Violations/         # Fine & overstay management
│   ├── Zones/              # Parking infrastructure & availability
│   ├── Navigation/         # Routing & Map logic
│   ├── Payments/           # Transaction processing
│   └── Admin/              # Global system oversight
│
│   # Typical Feature Folder Internal Structure:
│   └── [FeatureName]/
│       ├── [Name]Controller.cs     # Web API Entry point
│       ├── [Name]Service.cs        # Business logic & Database interaction
│       └── DTOs/                   # Request/Response contracts for this feature
│
├── Program.cs              # Global configuration & DI Container
└── SmartParking.csproj     # Project metadata & Analysis settings
```
