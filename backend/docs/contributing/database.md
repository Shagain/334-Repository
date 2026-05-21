# Database Operations (EF Core)

We use an **ORM** (Object-Relational Mapper) called Entity Framework Core. This means we interact with the database using C# objects instead of writing raw SQL.

## 1. The Gateway (`AppDbContext`)
The **`AppDbContext`** is your connection to the database. To use it, inject it into your service or controller:

```csharp
public class MyService(AppDbContext db) 
{
    private readonly AppDbContext _db = db;
}
```

## 2. Basic Operations (CRUD)

### Reading Data
Always use the **`Async`** versions of methods when talking to the database.
```csharp
// Get all zones
List<Zone> zones = await _db.Zones.ToListAsync();

// Find a specific item by its ID
Zone? zone = await _db.Zones.FindAsync(zoneId);
```

### Creating Data
1. Create the object.
2. Add it to the table (**`DbSet`**).
3. Save the changes.
```csharp
var newZone = new Zone { Name = "East Wing", Capacity = 30 };
_db.Zones.Add(newZone);
await _db.SaveChangesAsync(); // This actually sends the data to Postgres
```

### Updating Data
1. Get the item from the database.
2. Change its properties.
3. Save the changes.
```csharp
Zone? zone = await _db.Zones.FindAsync(id);
if (zone != null) 
{
    zone.Capacity = 100;
    await _db.SaveChangesAsync();
}
```

### Deleting Data
1. Find the item.
2. Remove it.
3. Save.
```csharp
Zone? zone = await _db.Zones.FindAsync(id);
if (zone != null) 
{
    _db.Zones.Remove(zone);
    await _db.SaveChangesAsync();
}
```

> [!IMPORTANT]
> **SaveChangesAsync()** is the only command that actually talks to the database. If you forget to call it, your changes will be lost when the request ends!
