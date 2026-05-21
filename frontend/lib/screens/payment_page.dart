import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/parking_session.dart';
import '../router/app_router.dart';
import '../services/booking_service.dart';
import 'app_state.dart';
import 'bookings_page.dart';

class PaymentPage extends StatelessWidget {
  final Booking booking;

  const PaymentPage({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const lightBackground = Color(0xFFF7F7FA);

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        elevation: 0,
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.w800, color: primaryBlue),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.local_parking, color: primaryBlue, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      booking.zone,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: primaryBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${booking.dateText} • ${booking.timeText}',
                      style: const TextStyle(color: Color(0xFF8B8E99)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SummaryCard(booking: booking),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final start = booking.paidAt.toUtc();
                    final end = start.add(Duration(hours: booking.hours));

                    await BookingService().addSession(
                      ParkingSession(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        zoneTitle: booking.zone,
                        vehiclePlate: booking.vehicle,
                        driverName: booking.driverName,
                        startTime: start,
                        endTime: end,
                        status: SessionStatus.upcoming,
                        rate: booking.rate,
                      ),
                    );

                    AppState.addPaidBooking(booking);

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment successful. Booking confirmed.'),
                      ),
                    );
                    context.go(AppRoutes.bookings);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Pay ${booking.totalText}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Booking booking;

  const _SummaryCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          if (booking.driverName.isNotEmpty)
            _Row(label: 'Driver', value: booking.driverName),
          _Row(label: 'Parking zone', value: booking.zone),
          _Row(label: 'Vehicle', value: booking.vehicle),
          _Row(label: 'Duration', value: booking.durationText),
          _Row(label: 'Rate', value: '\$${booking.rate.toStringAsFixed(2)}/hr'),
          _Row(label: 'Payment method', value: booking.paymentMethod),
          const Divider(height: 28),
          _Row(label: 'Total', value: booking.totalText, isTotal: true),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _Row({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : const Color(0xFF8B8E99),
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? const Color(0xFF0D2E9B) : Colors.black87,
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
