import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../auth/data/auth_repository.dart';
import '../../queue/data/queue_repository.dart';
import '../../shared/data/mock_data_store.dart';
import '../../shared/models/enums.dart';
import '../../booking/data/booking_repository.dart';

class ReceptionistDashboard extends ConsumerStatefulWidget {
  const ReceptionistDashboard({super.key});

  @override
  ConsumerState<ReceptionistDashboard> createState() =>
      _ReceptionistDashboardState();
}

class _ReceptionistDashboardState extends ConsumerState<ReceptionistDashboard> {
  String _doctorId = 'doc_ahmed';

  @override
  Widget build(BuildContext context) {
    final doctors = MockDataStore.instance.doctors;
    final today = AppDateUtils.formatDay(DateTime.now());
    final queue = ref.watch(queueRepositoryProvider).todayForDoctor(_doctorId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reception'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bookWalkIn(context),
        icon: const Icon(Icons.add),
        label: const Text('Book walk-in / phone'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: _doctorId,
              decoration: const InputDecoration(labelText: 'Doctor'),
              items: doctors
                  .map(
                    (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _doctorId = v ?? _doctorId),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Today ($today) queue',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: queue.length,
              itemBuilder: (_, i) {
                final a = queue[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: a.isEmergency
                          ? AppTheme.danger
                          : AppTheme.primaryBlue,
                      child: Text(
                        a.tokenLabel.replaceAll('T-', ''),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    title: Text(a.patientName),
                    subtitle: Text('${a.status.firestoreValue} · ${a.source}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        final repo = ref.read(bookingRepositoryProvider);
                        switch (v) {
                          case 'checkin':
                            MockDataStore.instance.setAppointmentStatus(
                              a.id,
                              AppointmentStatus.checkedIn,
                            );
                          case 'skip':
                            MockDataStore.instance.setAppointmentStatus(
                              a.id,
                              AppointmentStatus.skipped,
                            );
                          case 'noshow':
                            MockDataStore.instance.setAppointmentStatus(
                              a.id,
                              AppointmentStatus.noShow,
                            );
                          case 'emergency':
                            await repo.book(
                              doctor: doctors.firstWhere((d) => d.id == _doctorId),
                              date: today,
                              patientId: 'walkin_${DateTime.now().millisecondsSinceEpoch}',
                              patientName: 'Emergency Patient',
                              bookedByUserId:
                                  ref.read(authStateProvider)?.id ?? 'reception',
                              phone: '923000000000',
                              source: 'walk_in',
                              isEmergency: true,
                            );
                        }
                        setState(() {});
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'checkin', child: Text('Checked-in')),
                        PopupMenuItem(value: 'skip', child: Text('Skip')),
                        PopupMenuItem(value: 'noshow', child: Text('No-show')),
                        PopupMenuItem(
                          value: 'emergency',
                          child: Text('Insert emergency'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bookWalkIn(BuildContext context) async {
    final name = TextEditingController();
    final phone = TextEditingController(text: '03009876543');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Book for patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Patient name'),
            ),
            TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final doctor = MockDataStore.instance.doctors
                  .firstWhere((d) => d.id == _doctorId);
              final today = AppDateUtils.formatDay(DateTime.now());
              try {
                await ref.read(bookingRepositoryProvider).book(
                      doctor: doctor,
                      date: today,
                      patientId:
                          'walkin_${DateTime.now().millisecondsSinceEpoch}',
                      patientName: name.text.trim().isEmpty
                          ? 'Walk-in Patient'
                          : name.text.trim(),
                      bookedByUserId:
                          ref.read(authStateProvider)?.id ?? 'reception',
                      phone: phone.text,
                      source: 'phone',
                    );
                if (ctx.mounted) Navigator.pop(ctx);
                setState(() {});
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              }
            },
            child: const Text('Book + token'),
          ),
        ],
      ),
    );
  }
}