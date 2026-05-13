// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'pkce_utils.dart';

const _kVerifierKey = 'ms_pkce_verifier';
const _kStateKey = 'ms_pkce_state';
const _kRedirectKey = 'ms_pkce_redirect';

void _clearSessionKeys() {
  html.window.sessionStorage.remove(_kVerifierKey);
  html.window.sessionStorage.remove(_kStateKey);
  html.window.sessionStorage.remove(_kRedirectKey);
}

void _clearOAuthQueryFromUrl() {
  final path = html.window.location.pathname ?? '';
  final safePath = path.isEmpty ? '/' : path;
  html.window.history.replaceState(null, html.document.title, safePath);
}

Future<bool> tryHandleMicrosoftOAuthReturn({
  required Future<void> Function(String code, String codeVerifier, String redirectUri) onSuccess,
  required void Function(String message) onError,
}) async {
  final href = html.window.location.href;
  if (href.isEmpty) return false;

  final uri = Uri.parse(href);
  final oauthErr = uri.queryParameters['error'];
  if (oauthErr != null) {
    final desc = uri.queryParameters['error_description'];
    onError(desc != null ? Uri.decodeFull(desc.replaceAll('+', ' ')) : oauthErr);
    _clearSessionKeys();
    _clearOAuthQueryFromUrl();
    return true;
  }

  final code = uri.queryParameters['code'];
  final returnedState = uri.queryParameters['state'];
  if (code == null || returnedState == null) return false;

  final storedState = html.window.sessionStorage[_kStateKey];
  final verifier = html.window.sessionStorage[_kVerifierKey];
  final redirect = html.window.sessionStorage[_kRedirectKey];

  if (storedState == null || verifier == null || redirect == null) {
    onError('Sign-in session expired. Please try "Continue with Microsoft" again.');
    _clearOAuthQueryFromUrl();
    return true;
  }

  if (storedState != returnedState) {
    onError('Invalid sign-in state. Please try again.');
    _clearSessionKeys();
    _clearOAuthQueryFromUrl();
    return true;
  }

  try {
    await onSuccess(code, verifier, redirect);
  } catch (e) {
    onError(e.toString());
    _clearSessionKeys();
    _clearOAuthQueryFromUrl();
    return true;
  }

  _clearSessionKeys();
  _clearOAuthQueryFromUrl();
  return true;
}

void startMicrosoftSignIn({
  required String tenantId,
  required String clientId,
  required String redirectUri,
}) {
  final verifier = generatePkceVerifier();
  final challenge = pkceChallengeS256(verifier);
  final state = generateOAuthState();

  html.window.sessionStorage[_kVerifierKey] = verifier;
  html.window.sessionStorage[_kStateKey] = state;
  html.window.sessionStorage[_kRedirectKey] = redirectUri;

  final path = '/$tenantId/oauth2/v2.0/authorize';
  final uri = Uri.https('login.microsoftonline.com', path, <String, String>{
    'client_id': clientId,
    'response_type': 'code',
    'redirect_uri': redirectUri,
    'response_mode': 'query',
    'scope': 'openid profile email offline_access',
    'state': state,
    'code_challenge': challenge,
    'code_challenge_method': 'S256',
  });

  html.window.location.assign(uri.toString());
}
