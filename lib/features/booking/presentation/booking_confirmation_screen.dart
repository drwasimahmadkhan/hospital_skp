import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/iterable_extensions.dart';
import '../../shared/data/mock_data_store.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appt = MockDataStore.instance.appointments
        .where((a) => a.id == appointmentId)
        .firstOrNull;

    if (appt == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Appointment not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Booking confirmed')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 72, color: AppTheme.accentGreen),
            const SizedBox(height: 12),
            Text('Your token', style: Theme.of(context).textTheme.titleLarge),
            Text(
              appt.tokenLabel,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(appt.doctorName, style: Theme.of(context).textTheme.titleLarge),
            Text('Date: ${appt.date}'),
            if (appt.expectedWindowStart != null)
              Text('Expected around: ${appt.expectedWindowStart}'),
            Text('Fee: Rs ${appt.feePkr}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.go('/queue/${appt.id}'),
              child: const Text('Open live queue'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Back to home'),
            ),
          ],
        ),
      ),
    );
  }
}