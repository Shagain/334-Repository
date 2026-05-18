/// Normalizes and validates Microsoft Entra IDs from `.env` / `--dart-define`.
class MicrosoftOAuthConfig {
  MicrosoftOAuthConfig({
    required this.tenantId,
    required this.clientId,
  });

  final String tenantId;
  final String clientId;

  static final RegExp _guid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static const _specialTenants = {'common', 'organizations', 'consumers'};

  static String sanitizeId(String raw) {
    var value = raw.trim();
    if (value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1).trim();
    }
    if (value.startsWith("'") && value.endsWith("'")) {
      value = value.substring(1, value.length - 1).trim();
    }

    const loginHost = 'https://login.microsoftonline.com/';
    if (value.startsWith(loginHost)) {
      final rest = value.substring(loginHost.length);
      final slash = rest.indexOf('/');
      value = slash < 0 ? rest : rest.substring(0, slash);
    }

    return value.trim();
  }

  static MicrosoftOAuthConfig? parse({
    required String rawTenantId,
    required String rawClientId,
  }) {
    final tenantId = sanitizeId(rawTenantId);
    final clientId = sanitizeId(rawClientId);
    if (tenantId.isEmpty || clientId.isEmpty) return null;
    return MicrosoftOAuthConfig(tenantId: tenantId, clientId: clientId);
  }

  /// Human-readable message when values are wrong; null if OK.
  String? validate() {
    if (tenantId == clientId) {
      return 'MICROSOFT_TENANT_ID and MICROSOFT_CLIENT_ID are the same. '
          'In Azure Portal they are different: use Directory (tenant) ID for the tenant, '
          'and Application (client) ID for the client.';
    }

    final tenantLower = tenantId.toLowerCase();
    if (tenantLower == 'your-tenant-id' ||
        tenantLower == 'your-tenant-guid' ||
        tenantLower.contains('your-tenant')) {
      return 'MICROSOFT_TENANT_ID is still a placeholder. Replace it with your real Tenant ID from Azure.';
    }

    if (tenantId.contains(' ') || clientId.contains(' ')) {
      return 'Remove spaces around the IDs in frontend/.env (no quotes needed).';
    }

    if (tenantId.contains('://') || clientId.contains('://')) {
      return 'Use only the GUID values, not a full https:// URL.';
    }

    if (!_isValidTenant(tenantId)) {
      return 'MICROSOFT_TENANT_ID "$tenantId" is not valid.\n\n'
          'Use one of:\n'
          '• Directory (tenant) ID — a GUID from Azure Portal → Microsoft Entra ID → Overview\n'
          '• Your tenant domain — e.g. contoso.onmicrosoft.com\n'
          '• common — if the app is multi-tenant\n\n'
          'Do not put the Application (client) ID in MICROSOFT_TENANT_ID.';
    }

    if (!_guid.hasMatch(clientId)) {
      return 'MICROSOFT_CLIENT_ID must be the Application (client) ID GUID from your app registration.';
    }

    return null;
  }

  static bool _isValidTenant(String tenantId) {
    final lower = tenantId.toLowerCase();
    if (_specialTenants.contains(lower)) return true;
    if (_guid.hasMatch(tenantId)) return true;
    // e.g. contoso.onmicrosoft.com or custom verified domain
    return RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9.-]*\.[a-zA-Z]{2,}$').hasMatch(tenantId);
  }
}
