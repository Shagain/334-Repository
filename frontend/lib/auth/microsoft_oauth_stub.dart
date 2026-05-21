Future<bool> tryHandleMicrosoftOAuthReturn({
  required Future<void> Function(String code, String codeVerifier, String redirectUri) onSuccess,
  required void Function(String message) onError,
}) async =>
    false;

void startMicrosoftSignIn({
  required String tenantId,
  required String clientId,
  required String redirectUri,
}) {
  throw UnsupportedError(
    'Microsoft sign-in is only available in a web build. Run: flutter run -d edge --web-port=8080',
  );
}
