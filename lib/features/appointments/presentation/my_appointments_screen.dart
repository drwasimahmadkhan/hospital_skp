import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../booking/data/booking_repository.dart';
import '../../shared/models/enums.dart';

class MyAppointmentsScreen extends ConsumerWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }
    final appts = ref.watch(myAppointmentsProvider(user.id));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My appointments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: appts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (list) {
            final upcoming = list
                .where(
                  (a) =>
                      a.status == AppointmentStatus.booked ||
                      a.status == AppointmentStatus.checkedIn ||
                      a.status == AppointmentStatus.inProgress,
                )
                .toList();
            final completed = list
                .where((a) => a.status == AppointmentStatus.completed)
                .toList();
            final cancelled = list
                .where(
                  (a) =>
                      a.status == AppointmentStatus.cancelled ||
                      a.status == AppointmentStatus.noShow,
                )
                .toList();

            Widget buildList(List items, {bool canCancel = false}) {
              if (items.isEmpty) {
                return const Center(child: Text('No appointments'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final a = items[i];
                  return Card(
                    child: ListTile(
                      title: Text('${a.tokenLabel} · ${a.doctorName}'),
                      subtitle: Text('${a.date} · ${a.status.firestoreValue}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/queue/${a.id}'),
                      onLongPress: canCancel
                          ? () async {
                              await ref
                                  .read(bookingRepositoryProvider)
                                  .cancel(a.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cancelled')),
                                );
                              }
                            }
                          : null,
                    ),
                  );
                },
              );
            }

            return TabBarView(
              children: [
                buildList(upcoming, canCancel: true),
                Column(
                  children: [
                    Expanded(child: buildList(completed)),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextButton.icon(
                        onPressed: () => context.push('/feedback'),
                        icon: const Icon(Icons.star, color: AppTheme.accentGreen),
                        label: const Text('Leave feedback'),
                      ),
                    ),
                  ],
                ),
                buildList(cancelled),
              ],
            );
          },
        ),
      ),
    );
  }
}