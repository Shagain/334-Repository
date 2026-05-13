import 'package:flutter/material.dart';

/// Shared so SnackBars work on web even when nested [Scaffold] context is ambiguous.
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
