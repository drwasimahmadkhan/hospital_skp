import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../shared/data/mock_data_store.dart';
import '../data/booking_repository.dart';

class DateSlotScreen extends ConsumerStatefulWidget {
  const DateSlotScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  ConsumerState<DateSlotScreen> createState() => _DateSlotScreenState();
}

class _DateSlotScreenState extends ConsumerState<DateSlotScreen> {
  late String _selected;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = AppDateUtils.formatDay(DateTime.now());
  }

  Future<void> _book() async {
    final user = ref.read(authStateProvider);
    final patient = MockDataStore.instance.currentPatient;
    final doctor =
        ref.read(bookingRepositoryProvider).doctorById(widget.doctorId);
    if (user == null || patient == null || doctor == null) {
      setState(() => _error = 'Please login as patient first.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final appt = await ref.read(bookingRepositoryProvider).book(
            doctor: doctor,
            date: _selected,
            patientId: patient.id,
            patientName: patient.name,
            bookedByUserId: user.id,
            phone: user.phone,
          );
      if (!mounted) return;
      context.go('/booking-confirmation/${appt.id}');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor =
        ref.read(bookingRepositoryProvider).doctorById(widget.doctorId);
    final days = AppDateUtils.nextDays(7);

    return Scaffold(
      appBar: AppBar(title: const Text('Select date')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _loading ? null : _book,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm booking'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(doctor?.name ?? '',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Tokens are issued in order. Remaining capacity is shown per day.',
          ),
          const SizedBox(height: 16),
          ...days.map((d) {
            final key = AppDateUtils.formatDay(d);
            final qid = AppDateUtils.queueDocId(widget.doctorId, key);
            final q = MockDataStore.instance.queueStates[qid];
            final remaining = q?.remainingCapacity ?? doctor?.maxTokensPerDay ?? 0;
            final selected = _selected == key;
            return Card(
              color: selected ? AppTheme.primaryBlue.withValues(alpha: 0.08) : null,
              child: ListTile(
                title: Text(key),
                subtitle: Text(
                  remaining > 0
                      ? '$remaining tokens remaining'
                      : 'Fully booked',
                ),
                trailing: selected
                    ? const Icon(Icons.check_circle, color: AppTheme.accentGreen)
                    : null,
                enabled: remaining > 0,
                onTap: remaining > 0
                    ? () => setState(() => _selected = key)
                    : null,
              ),
            );
          }),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppTheme.danger)),
          ],
        ],
      ),
    );
  }
}