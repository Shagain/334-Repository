import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/app_state.dart';
import '../screens/booking_creation_page.dart';
import '../screens/bookings_page.dart';
import '../screens/dashboard_page.dart';
import '../screens/login_page.dart';
import '../screens/payment_methods_page.dart';
import '../screens/payment_page.dart';
import '../screens/profile_page.dart';
import '../screens/vehicle_registration_page.dart';
import '../services/auth_service.dart';
import '../services/vehicle_service.dart';
import '../utils/sydney_time.dart';

/// Path-based URLs for Flutter web, e.g. `/dashboard`, `/bookings`.
abstract final class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const vehicleRegistration = '/vehicle-registration';
  static const bookings = '/bookings';
  static const bookingNew = '/bookings/new';
  static const profile = '/profile';
  static const payments = '/payments';
  static const paymentCheckout = '/payments/checkout';
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

late final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.login,
  redirect: _redirect,
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, state) {
        if (state.uri.queryParameters.containsKey('code')) return null;
        return AppRoutes.login;
      },
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (_, __) => const DashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.vehicleRegistration,
      builder: (_, __) => const VehicleRegistrationPage(),
    ),
    GoRoute(
      path: AppRoutes.bookings,
      builder: (_, __) => const BookingsPage(),
    ),
    GoRoute(
      path: AppRoutes.bookingNew,
      builder: (_, __) => const BookingCreationPage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (_, __) => const ProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.payments,
      builder: (_, state) {
        final booking = state.extra as Booking?;
        return PaymentMethodsPage(
          booking: booking ?? _placeholderBooking(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.paymentCheckout,
      builder: (_, state) {
        final booking = state.extra as Booking?;
        if (booking == null) {
          return const BookingsPage();
        }
        return PaymentPage(booking: booking);
      },
    ),
  ],
);

Booking _placeholderBooking() {
  return Booking(
    zone: 'Zone A',
    vehicle: '—',
    hours: 2,
    rate: 4.50,
    paymentMethod: '',
    paidAt: SydneyTime.nowUtc(),
  );
}

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final path = state.uri.path;
  final hasOAuthCode = state.uri.queryParameters.containsKey('code');

  if (hasOAuthCode) {
    if (path != '/' && path != AppRoutes.login) {
      return '/?${state.uri.query}';
    }
    return null;
  }

  final auth = AuthService();
  var loggedIn = await auth.isLoggedIn();
  if (!loggedIn) {
    try {
      loggedIn = await auth.tryRestoreSession();
    } catch (_) {
      await auth.logout();
      loggedIn = false;
    }
  }

  if (!loggedIn) {
    if (path == AppRoutes.login || path == '/') return null;
    return AppRoutes.login;
  }

  await auth.ensureMicrosoftProfile();

  if (path == AppRoutes.login || path == '/') {
    final vehicles = await VehicleService().getVehicles();
    return vehicles.isNotEmpty
        ? AppRoutes.dashboard
        : AppRoutes.vehicleRegistration;
  }

  return null;
}

/// After sign-in: dashboard if a vehicle exists, otherwise registration.
Future<void> goAfterSignIn(BuildContext context) async {
  final vehicles = await VehicleService().getVehicles();
  if (!context.mounted) return;
  context.go(
    vehicles.isNotEmpty ? AppRoutes.dashboard : AppRoutes.vehicleRegistration,
  );
}
