# Smart Parking Backend (.NET 10 + PostgreSQL)

## Prerequisites
*   **Docker Desktop:** Installed and running. ([Windows](https://docs.docker.com/desktop/install/windows-install/) | [Mac](https://docs.docker.com/desktop/install/mac-install/))

## 1. Quick Start

Run the entire system using Docker Compose from the `backend` folder:

```bash
docker compose up --build -d
```

### Endpoints:
*   **Base API URL:** `http://localhost:5000`
*   **Interactive Testing UI (Swagger):** [http://localhost:5000/swagger](http://localhost:5000/swagger)
*   **Postgres DB:** `localhost:5432` (User: `postgres`, Pass: `password`)

### Shutdown:
```bash
docker compose down
```

## 2. Environment Rules

### Data Persistence (Amnesiac)
The database is wiped on every `docker compose down`.
*   **Migrations:** Runs automatically on startup.
*   **Seeding:** Injects demo data automatically on startup.

### Security (Bypass Mode)
The system currently runs with **BYPASS_AUTH=true**.
*   All `[Authorize]` attributes are ignored.
*   **Mock Identity:** You are treated as **UserID: 2** with all roles (**Admin**, **Student**, **Staff**).
*   Toggle this in `docker-compose.yml` by setting `BYPASS_AUTH` to `false`.

## 3. Documentation
*   **API Specification** (paste in editor.swagger.io to view): [api.yml](../api.yml)

### Tutorials (`docs/contributing/`):
*   [C# Crash Course](./docs/contributing/crashcourse.md)
*   [Database (ORM) Operations](./docs/contributing/database.md)
*   [Controllers & Routes](./docs/contributing/controllers.md)
*   [Identity & Auth Flow](./docs/contributing/authentication-flow.md)

## 4. Microsoft sign-in (Flutter web + API)

1. In **Microsoft Entra ID** (Azure Portal), register an app. Under **Authentication**, add a **Single-page application** redirect URI that matches how you run Flutter, for example **`http://localhost:8080/`** (then run `flutter run -d edge --web-port=8080`). You can add more `http://localhost:.../` URIs if you use random ports, or set a fixed port.
2. Note the **Application (client) ID** and **Directory (tenant) ID** (or use `common` / `organizations` as tenant for multi-tenant sign-in).
3. Configure the **backend** in `appsettings.json` or environment variables:
    * `MicrosoftAuth:TenantId`
    * `MicrosoftAuth:ClientId`
    * `MicrosoftAuth:ClientSecret` — optional; only if you registered a **Web** client with a secret. SPAs using PKCE often leave this empty.

   **Docker:** `docker-compose.yml` also loads **`../frontend/.env`** into the API container when present, so the same `MICROSOFT_TENANT_ID` / `MICROSOFT_CLIENT_ID` values work for both Flutter and the backend without duplicating them in `appsettings.json`.
4. Put the same **Tenant ID** and **Client ID** in **`frontend/.env`** (next to `pubspec.yaml`) as `MICROSOFT_TENANT_ID` and `MICROSOFT_CLIENT_ID`, or pass **`--dart-define=...`** on the Flutter command line (dart-define overrides `.env`).

5. Run the Flutter web app, for example:

```bash
flutter run -d edge --web-port=8080
```

If you prefer not to use a file, you can still pass defines explicitly:

```bash
flutter run -d edge --web-port=8080 --dart-define=MICROSOFT_TENANT_ID=your-tenant-id --dart-define=MICROSOFT_CLIENT_ID=your-client-id
```

Optional: `--dart-define=MICROSOFT_REDIRECT_URI=http://localhost:8080/` if it must differ from `Uri.base.origin + '/'`.
