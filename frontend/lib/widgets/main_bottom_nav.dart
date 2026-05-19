import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../screens/app_state.dart';
import '../utils/sydney_time.dart';

/// Bottom navigation bar that updates the browser URL (`/dashboard`, `/bookings`, …).
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key});

  int _indexForPath(String path) {
    if (path.startsWith(AppRoutes.dashboard)) return 0;
    if (path.startsWith(AppRoutes.bookings)) return 1;
    if (path.startsWith(AppRoutes.payments)) return 2;
    if (path.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final currentIndex = _indexForPath(path);

    return NavigationBar(
      selectedIndex: currentIndex,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE8ECFF),
      onDestinationSelected: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            context.go(AppRoutes.dashboard);
          case 1:
            context.go(AppRoutes.bookings);
          case 2:
            context.push(
              AppRoutes.payments,
              extra: Booking(
                zone: 'Zone A',
                vehicle: '—',
                hours: 2,
                rate: 4.50,
                paymentMethod: '',
                paidAt: SydneyTime.nowUtc(),
              ),
            );
          case 3:
            context.go(AppRoutes.profile);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        NavigationDestination(
          icon: Icon(Icons.credit_card_outlined),
          selectedIcon: Icon(Icons.credit_card),
          label: 'Payments',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
