import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/token_utils.dart';
import '../../auth/data/auth_repository.dart';
import '../../queue/data/queue_repository.dart';
import '../../shared/data/mock_data_store.dart';
import '../../shared/models/enums.dart';

class DoctorDashboard extends ConsumerWidget {
  const DoctorDashboard({super.key});

  static const _doctorId = 'doc_ahmed';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = AppDateUtils.formatDay(DateTime.now());
    final repo = ref.watch(queueRepositoryProvider);
    final list = repo.todayForDoctor(_doctorId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor — Today'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              ref.read(authStateProvider.notifier).state = null;
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: repo.watchQueue(_doctorId, today),
            builder: (context, snap) {
              final q = snap.data;
              return Container(
                width: double.infinity,
                color: AppTheme.primaryBlue,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Now serving',
                        style: TextStyle(color: Colors.white70)),
                    Text(
                      q == null || q.currentTokenNumber == 0
                          ? '—'
                          : TokenUtils.format(q.currentTokenNumber),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (q?.paused == true)
                      const Text('PAUSED',
                          style: TextStyle(color: Colors.orangeAccent)),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await repo.callNext(_doctorId);
                  },
                  icon: const Icon(Icons.navigate_next),
                  label: const Text('Call next'),
                ),
                OutlinedButton.icon(
                  onPressed: () => repo.togglePause(_doctorId),
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause / break'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Marked on leave — patients would be notified in production',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.event_busy),
                  label: const Text('On leave today'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final a = list[i];
                return ListTile(
                  leading: Text(a.tokenLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  title: Text(a.patientName),
                  subtitle: Text(a.status.firestoreValue),
                  trailing: a.status == AppointmentStatus.inProgress
                      ? IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: AppTheme.accentGreen),
                          onPressed: () {
                            MockDataStore.instance.setAppointmentStatus(
                              a.id,
                              AppointmentStatus.completed,
                            );
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: () {
                            MockDataStore.instance.setAppointmentStatus(
                              a.id,
                              AppointmentStatus.skipped,
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}