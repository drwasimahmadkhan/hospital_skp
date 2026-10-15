import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/iterable_extensions.dart';
import '../../../core/utils/token_utils.dart';
import '../../shared/data/mock_data_store.dart';
import '../../shared/models/appointment_model.dart';
import '../../shared/models/queue_state_model.dart';
import '../data/queue_repository.dart';

/// Most important patient screen — large token + patients ahead + ETA.
class LiveQueueScreen extends ConsumerStatefulWidget {
  const LiveQueueScreen({super.key, required this.appointmentId});

  final String appointmentId;

  @override
  ConsumerState<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends ConsumerState<LiveQueueScreen> {
  AppointmentModel? _appt;
  bool _connected = true;

  @override
  void initState() {
    super.initState();
    _appt = MockDataStore.instance.appointments
        .where((a) => a.id == widget.appointmentId)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final appt = _appt;
    if (appt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live queue')),
        body: const Center(child: Text('Appointment not found')),
      );
    }

    final repo = ref.watch(queueRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Live queue')),
      body: StreamBuilder<QueueStateModel>(
        stream: repo.watchQueue(appt.doctorId, appt.date),
        builder: (context, snap) {
          final queue = snap.data;
          if (queue == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Refresh appointment from store (status may change).
          final latest = MockDataStore.instance.appointments
                  .where((a) => a.id == appt.id)
                  .firstOrNull ??
              appt;
          final ahead = MockDataStore.instance.patientsAheadFor(latest);
          final eta = TokenUtils.estimatedWaitMinutes(
            patientsAhead: ahead,
            avgConsultMinutes: queue.avgConsultMinutes,
          );

          return Column(
            children: [
              if (!_connected || queue.paused)
                MaterialBanner(
                  content: Text(
                    !_connected
                        ? 'Reconnecting… showing last known queue state'
                        : 'Doctor is on a short break',
                  ),
                  backgroundColor: Colors.orange.shade100,
                  actions: [
                    TextButton(
                      onPressed: () => setState(() => _connected = true),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      latest.doctorName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      latest.date,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _bigTile(
                      label: 'Now serving',
                      value: queue.currentTokenNumber == 0
                          ? '—'
                          : TokenUtils.format(queue.currentTokenNumber),
                      color: AppTheme.accentGreen,
                    ),
                    const SizedBox(height: 12),
                    _bigTile(
                      label: 'Your token',
                      value: latest.tokenLabel,
                      color: AppTheme.primaryBlue,
                      huge: true,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Patients ahead',
                            '$ahead',
                            Icons.groups,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            'Est. wait',
                            '~$eta min',
                            Icons.schedule,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Status: ${latest.status.firestoreValue}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This screen updates automatically. Stay nearby when fewer than 3 patients are ahead.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bigTile({
    required String label,
    required String value,
    required Color color,
    bool huge = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: huge ? 64 : 40,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}