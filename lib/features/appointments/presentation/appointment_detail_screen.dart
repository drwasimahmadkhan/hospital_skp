import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/data/mock_data_store.dart';
import '../../shared/models/appointment_model.dart';
import '../../../l10n/app_localizations.dart';

class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({required this.appointmentId, super.key});

  final String appointmentId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final AppointmentModel? a = MockDataStore.instance.appointments
        .where((x) => x.id == appointmentId)
        .firstOrNull;

    if (a == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Appointment not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              a.tokenLabel,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text('${a.doctorName} · ${a.date}'),
            Text('Status: ${a.status.toFirestore()}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.push('/queue/${a.id}'),
              child: Text(l10n.liveQueue),
            ),
            OutlinedButton(
              onPressed: () => context.push('/feedback/${a.id}'),
              child: Text(l10n.feedback),
            ),
          ],
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
