# C# Crash Course

This guide covers the core C# features used in this project. For basic syntax any AI can explain it better than I can.

## 1. Properties (`{ get; set; }`)
Properties are used to store data in a class.

```csharp
public class Zone 
{
    public int Capacity { get; set; } // Read (get) and Write (set)
    public string Name { get; init; } // Read (get) and Write only at creation (init)
}
```

**Using properties:**
```csharp
var zone = new Zone { Name = "North Campus" }; // Setting "init" property
zone.Capacity = 50;                            // Setting "set" property
Console.WriteLine(zone.Name);                  // Reading property
```

## 2. Dependency Injection (`DI`)

### Manual Instantiation (Avoid this)
Creating objects inside the constructor makes code hard to test and tightly coupled.
```csharp
public class BookingsController : ControllerBase
{
    private readonly BookingService _service;

    public BookingsController()
    {
        _service = new BookingService(); 
    }
}
```

### Class-based Injection
Requesting the class directly through the constructor. Dotnet automatically injects the requested service for you.
```csharp
public class BookingsController : ControllerBase
{
    private readonly BookingService _service;

    public BookingsController(BookingService service)
    {
        _service = service; 
    }
}
```
### Registration (Program.cs):
For dotnet to know about your service and manage it you need to register it in Program.cs.

```csharp
builder.Services.AddScoped<BookingService>();
```

### Interface-based Injection (Recommended)
Using an **Interface** allows you to swap implementations (e.g., swapping a Real Service for a Mock Service in unit test) without changing the controller code.

```csharp
// 1. The Interface (Contract)
public interface IBookingService { void Create(); }

// 2. The Implementation (Class)
public class BookingService : IBookingService { public void Create() { } }

// 3. The Registration (Program.cs)
builder.Services.AddScoped<IBookingService, BookingService>();

// 4. The Usage (Controller)
public class BookingsController(IBookingService service) : ControllerBase { }
```

### Lifetimes (`Scopes`):
*   **Transient:** A new instance is created **every time it is requested (not http request)** (`AddTransient`).
*   **Scoped:** A new instance is created **once per HTTP request** (`AddScoped`). This is the default choice for most services.
*   **Singleton:** Only one instance is created for the **entire life of the app** (`AddSingleton`).

## 3. Querying Data (`LINQ`)
Used to filter and transform lists or database tables.

### Common Methods:
*   **`Where`**: Filters data.
*   **`Select`**: Transforms data into a new shape.
*   **`FirstOrDefault`**: Returns the first match or `null` if none found.
*   **`Any`**: Returns `true` if at least one item matches.
*   **`Count`**: Returns the number of matching items.
*   **`Include`**: (EF Core specific) Tells the database to "Join" and bring back related data (like a User's Vehicles).

> [!NOTE]
> When talking to the database, we usually use the **Async** version of these methods (e.g., `AnyAsync()`, `ToListAsync()`, `FirstOrDefaultAsync()`) combined with the `await` keyword.

```csharp
// Example: Find a user and their cars
User? user = await _db.Users
    .Include(u => u.Vehicles)             // Join with Vehicles table
    .Where(u => u.Email == "test@me.com") // Filter
    .FirstOrDefaultAsync();               // Get the first result or null

// Example: Check if a spot is occupied
bool isOccupied = await _db.ParkingSpots
    .AnyAsync(s => s.Status == SpotStatus.Occupied);
```

## 4. Asynchronous Code (`async / await`)
Used to prevent the server from locking while waiting for external tasks like database queries.

### The `Task`
A **`Task`** represents a piece of work that will finish in the future.
*   **`Task`**: A job that returns nothing (like `void`).
*   **`Task<string>`**: A job that will eventually return a `string`.

### `async` and `await`
*   **`async`**: Marks a method as asynchronous. It allows the use of the `await` keyword.
*   **`await`**: Tells the server to pause this specific method and free up the current thread to help other users while the task (e.g., a database query) is running.

```csharp
// The method returns a Task that will eventually hold an IActionResult
public async Task<IActionResult> GetZones() 
{
    // We "await" the database task. 
    // The server is free to handle other requests while this line runs.
    var zones = await _db.Zones.ToListAsync(); 
    
    return Ok(zones);
}
```
