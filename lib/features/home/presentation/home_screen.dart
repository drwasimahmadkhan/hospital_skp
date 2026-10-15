import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../shared/models/enums.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final locale = ref.watch(localeProvider);
    final departments = ref.watch(departmentsProvider);
    final appts = user == null
        ? const AsyncValue<List<dynamic>>.data([])
        : ref.watch(myAppointmentsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.hospitalName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Assalam-o-Alaikum, ${user?.displayName ?? 'Patient'}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            locale.languageCode == 'ur'
                ? 'اپوائنٹمنٹ بک کریں اور لائیو ٹوکن دیکھیں'
                : 'Book an appointment and track your live token',
          ),
          const SizedBox(height: 16),
          appts.when(
            data: (list) {
              final upcoming = list
                  .where(
                    (a) =>
                        a.status == AppointmentStatus.booked ||
                        a.status == AppointmentStatus.checkedIn ||
                        a.status == AppointmentStatus.inProgress,
                  )
                  .toList();
              if (upcoming.isEmpty) {
                return const SizedBox.shrink();
              }
              final a = upcoming.first;
              return Card(
                color: AppTheme.primaryBlue,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upcoming appointment',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.tokenLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${a.doctorName} · ${a.date}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                              ),
                              onPressed: () => context.push('/queue/${a.id}'),
                              child: const Text('Live queue'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.primaryBlue,
                              ),
                              onPressed: () => context.push('/appointments'),
                              child: const Text('Details'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
          ),
          const SizedBox(height: 20),
          Text('Departments', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: departments.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (_, i) {
              final d = departments[i];
              return InkWell(
                onTap: () => context.push('/doctors/${d.id}'),
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_icon(d.icon),
                          size: 36, color: AppTheme.accentGreen),
                      const SizedBox(height: 8),
                      Text(
                        d.localizedName(locale.languageCode),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: const Icon(Icons.calendar_month),
            title: const Text('My appointments'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/appointments'),
          ),
          const SizedBox(height: 24),
          Text(
            'Today: ${AppDateUtils.formatDay(DateTime.now())}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  IconData _icon(String name) {
    switch (name) {
      case 'favorite':
        return Icons.favorite;
      case 'child_care':
        return Icons.child_care;
      case 'accessibility_new':
        return Icons.accessibility_new;
      default:
        return Icons.medical_services;
    }
  }
}