import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// URL-safe base64 without padding (PKCE / OAuth).
String base64UrlNoPad(List<int> bytes) {
  return base64Url.encode(bytes).replaceAll('=', '');
}

String generatePkceVerifier() {
  final random = Random.secure();
  final raw = List<int>.generate(64, (_) => random.nextInt(256));
  return base64UrlNoPad(raw);
}

String pkceChallengeS256(String verifier) {
  final digest = sha256.convert(utf8.encode(verifier));
  return base64UrlNoPad(digest.bytes);
}

String generateOAuthState() {
  final random = Random.secure();
  final raw = List<int>.generate(16, (_) => random.nextInt(256));
  return base64UrlNoPad(raw);
}
