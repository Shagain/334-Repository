import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../services/vehicle_service.dart';
import '../utils/sydney_time.dart';
import 'app_state.dart';

class BookingCreationPage extends StatefulWidget {
  const BookingCreationPage({super.key});

  @override
  State<BookingCreationPage> createState() => _BookingCreationPageState();
}

class _BookingCreationPageState extends State<BookingCreationPage> {
  final _authService = AuthService();
  final _vehicleService = VehicleService();

  static const _primaryBlue = Color(0xFF0D2E9B);
  static const _lightBackground = Color(0xFFF7F7FA);
  static const _mutedText = Color(0xFF8B8E99);
  static const _hourlyRate = 4.50;

  static const _zones = [
    'Zone C - South Arts',
    'Library Deck - Level 3',
    'Zone A - Academic North',
    'Zone B - Library',
  ];

  static const _durationOptions = [1, 2, 3, 4];

  String _selectedZone = _zones.first;
  int _selectedHours = 2;
  String _driverName = '';
  String _vehiclePlate = '';
  late DateTime _selectedDate;
  late TimeOfDay _startTime;

  @override
  void initState() {
    super.initState();
    final sydney = SydneyTime.nowSydney();
    _selectedDate = DateTime(sydney.year, sydney.month, sydney.day);
    _startTime = TimeOfDay(hour: sydney.hour < 23 ? sydney.hour + 1 : 9, minute: 0);
    _loadProfile();
  }

  DateTime get _startUtc => SydneyTime.sydneyDateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

  DateTime get _endUtc => _startUtc.add(Duration(hours: _selectedHours));

  bool get _isScheduleValid => _startUtc.isAfter(SydneyTime.nowUtc());

  String get _dateLabel => SydneyTime.formatLongDate(_selectedDate);

  String get _timeRangeLabel =>
      '${SydneyTime.formatTime(_startUtc)} – ${SydneyTime.formatTime(_endUtc)} '
      '${SydneyTime.timezoneAbbreviation(_startUtc)}';

  Future<void> _loadProfile() async {
    await _authService.ensureMicrosoftProfile();
    final name = await _authService.getFullName() ?? '';
    final vehicles = await _vehicleService.getVehicles();
    if (!mounted) return;
    setState(() {
      _driverName = name;
      _vehiclePlate = vehicles.isNotEmpty ? vehicles.first.licensePlate : '';
    });
  }

  Future<void> _pickDate() async {
    final sydneyToday = SydneyTime.nowSydney();
    final today = DateTime(sydneyToday.year, sydneyToday.month, sydneyToday.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      helpText: 'Select date (Sydney)',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      helpText: 'Start time (Sydney)',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  void _continueToPayment() {
    if (_vehiclePlate.isEmpty) return;
    if (!_isScheduleValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a start time in the future (Sydney time).')),
      );
      return;
    }

    context.push(
      AppRoutes.payments,
      extra: Booking(
        zone: _selectedZone,
        vehicle: _vehiclePlate,
        hours: _selectedHours,
        rate: _hourlyRate,
        paymentMethod: '',
        paidAt: _startUtc,
        driverName: _driverName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _selectedHours * _hourlyRate;

    return Scaffold(
      backgroundColor: _lightBackground,
      appBar: AppBar(
        backgroundColor: _lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.bookings);
            }
          },
        ),
        title: const Text(
          'New booking',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create a parking session',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'All times are in Sydney (${SydneyTime.timezoneAbbreviation()})',
                      style: const TextStyle(color: _mutedText, fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    if (_driverName.isNotEmpty || _vehiclePlate.isNotEmpty)
                      _ProfileChip(name: _driverName, plate: _vehiclePlate),

                    const SizedBox(height: 16),

                    _SectionCard(
                      title: 'Parking zone',
                      icon: Icons.location_on_outlined,
                      child: DropdownButtonFormField<String>(
                        value: _selectedZone,
                        decoration: _inputDecoration(),
                        items: _zones
                            .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedZone = v);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    _SectionCard(
                      title: 'Date & time',
                      icon: Icons.calendar_today_outlined,
                      child: Column(
                        children: [
                          _PickerTile(
                            icon: Icons.event_outlined,
                            label: 'DATE',
                            value: _dateLabel,
                            onTap: _pickDate,
                          ),
                          const SizedBox(height: 12),
                          _PickerTile(
                            icon: Icons.schedule_outlined,
                            label: 'START TIME',
                            value: SydneyTime.formatTime(_startUtc),
                            onTap: _pickStartTime,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFDDE4FF)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timelapse, color: _primaryBlue, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Ends at ${SydneyTime.formatTime(_endUtc)} '
                                    '(${SydneyTime.timezoneAbbreviation(_startUtc)})',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4A4D57),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!_isScheduleValid) ...[
                            const SizedBox(height: 10),
                            const Text(
                              'Start time must be in the future.',
                              style: TextStyle(color: Color(0xFFE53935), fontSize: 13),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _SectionCard(
                      title: 'Duration',
                      icon: Icons.hourglass_bottom_outlined,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _durationOptions.map((h) {
                              final selected = _selectedHours == h;
                              return ChoiceChip(
                                label: Text('$h ${h == 1 ? 'hr' : 'hrs'}'),
                                selected: selected,
                                onSelected: (_) => setState(() => _selectedHours = h),
                                selectedColor: const Color(0xFFE8ECFF),
                                labelStyle: TextStyle(
                                  color: selected ? _primaryBlue : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                ),
                                side: BorderSide(
                                  color: selected ? _primaryBlue : const Color(0xFFE6E8EF),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _StepButton(
                                icon: Icons.remove,
                                onTap: _selectedHours > 1
                                    ? () => setState(() => _selectedHours--)
                                    : null,
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '$_selectedHours hours',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: _primaryBlue,
                                    ),
                                  ),
                                ),
                              ),
                              _StepButton(
                                icon: Icons.add,
                                onTap: _selectedHours < 12
                                    ? () => setState(() => _selectedHours++)
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '\$4.50 per hour',
                            style: TextStyle(color: _mutedText, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _SectionCard(
                      title: 'Summary',
                      icon: Icons.receipt_long_outlined,
                      child: Column(
                        children: [
                          _SummaryRow(label: 'Zone', value: _selectedZone),
                          _SummaryRow(label: 'Driver', value: _driverName.isEmpty ? '—' : _driverName),
                          _SummaryRow(label: 'Vehicle', value: _vehiclePlate.isEmpty ? '—' : _vehiclePlate),
                          _SummaryRow(label: 'When', value: '${SydneyTime.formatDayLabel(_startUtc)}, $_timeRangeLabel'),
                          _SummaryRow(label: 'Duration', value: '$_selectedHours hours'),
                          const Divider(height: 28),
                          _SummaryRow(
                            label: 'Total',
                            value: '\$${total.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _vehiclePlate.isEmpty || !_isScheduleValid ? null : _continueToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFB0B3BD),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _vehiclePlate.isEmpty
                        ? 'Register a vehicle first'
                        : 'Continue to payment',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.name, required this.plate});

  final String name;
  final String plate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE8ECFF),
            child: Icon(Icons.person, color: Color(0xFF0D2E9B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty)
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF0D2E9B),
                    ),
                  ),
                if (plate.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.directions_car_outlined, size: 16, color: Color(0xFF8B8E99)),
                      const SizedBox(width: 4),
                      Text(
                        plate,
                        style: const TextStyle(color: Color(0xFF8B8E99), fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F7FA),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF0D2E9B), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B8E99),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF8B8E99)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0D2E9B), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0D2E9B),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8ECFF),
          foregroundColor: const Color(0xFF0D2E9B),
          disabledBackgroundColor: const Color(0xFFF0F0F0),
          disabledForegroundColor: const Color(0xFFB0B3BD),
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black87 : const Color(0xFF8B8E99),
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isTotal ? const Color(0xFF0D2E9B) : Colors.black87,
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF7F7FA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
}
