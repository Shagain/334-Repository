import 'package:flutter/material.dart';

import '../router/app_router.dart';

/// After sign-in: dashboard if a vehicle exists, otherwise registration.
Future<void> navigateAfterSignIn(BuildContext context) => goAfterSignIn(context);
