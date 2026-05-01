# Working with Controllers

Controllers handle incoming web requests and return responses to the user.

## 1. Basic Structure
In this project, we specify the **full URL path** directly on every method.

```csharp
[ApiController]
public class ZonesController : ControllerBase
{
    // This maps to: http://localhost:5000/zones
    [HttpGet("zones")] 
    public async Task<ActionResult<List<Zone>>> GetZones() => await _db.Zones.ToListAsync();
}
```

## 2. Extracting Parameters
Data can come from three main places:

### From the URL Path (`[FromRoute]`)
Used for specific IDs.
```csharp
[HttpGet("zones/{id}")] 
public async Task<ActionResult<Zone>> GetZone([FromRoute] int id) 
{
    var zone = await _db.Zones.FindAsync(id);
    return zone == null ? NotFound() : zone;
}
```

### From the URL Query (`[FromQuery]`)
Used for filtering or searching.
```csharp
[HttpGet("zones/search")] // /zones/search?capacity=10
public async Task<ActionResult<List<Zone>>> ListZones([FromQuery] int capacity) 
{
    return await _db.Zones.Where(z => z.Capacity >= capacity).ToListAsync();
}
```

### From the Body (`[FromBody]`)
Used for creating or updating data (usually JSON).
```csharp
[HttpPost("zones")]
public async Task<ActionResult<Zone>> CreateZone([FromBody] CreateZoneDto dto) 
{
    // ... logic to save
    return CreatedAtAction(nameof(GetZone), new { id = newZone.Id }, newZone);
}
```

## 3. Returning Responses (`ActionResult<T>`)
Always return an **`ActionResult<T>`**. This allows you to return both the **Data** and the **HTTP Status Code**.

*   **Returning Data**: Simply return the object. .NET automatically wraps it in a **200 OK**.
*   **`NotFound()`**: Returns 404 Not Found.
*   **`BadRequest("error")`**: Returns 400 Bad Request.
*   **`CreatedAtAction(...)`**: Returns 201 Created with a link to the new resource.

### Why use `ActionResult<T>`?
1.  **Swagger:** It automatically documents the return type for the frontend team.
2.  **Type Safety:** The compiler ensures you return the correct object type.

```csharp
[HttpGet("zones/{id}")]
public async Task<ActionResult<Zone>> GetZone(int id)
{
    Zone? zone = await _db.Zones.FindAsync(id);
    
    if (zone == null) return NotFound(); // Send 404
    
    return zone; // Send 200 OK with the data automatically
}
```
