import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../../shared/data/mock_data_store.dart';

/// Lightweight admin panel (same Flutter app / Flutter Web).
class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = MockDataStore.instance.doctors;
    final departments = MockDataStore.instance.departments;
    final appts = MockDataStore.instance.appointments;
    final completed =
        appts.where((a) => a.status.name == 'completed').length;
    final noShow = appts.where((a) => a.status.name == 'noShow').length;
    final revenue = appts
        .where((a) => a.status.name == 'completed' || a.status.name == 'booked')
        .fold<int>(0, (sum, a) => sum + a.feePkr);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _kpi('Doctors', '${doctors.length}', Icons.medical_services),
              _kpi('Departments', '${departments.length}', Icons.apartment),
              _kpi('Appointments', '${appts.length}', Icons.event),
              _kpi('Completed', '$completed', Icons.check),
              _kpi('No-shows', '$noShow', Icons.person_off),
              _kpi('Revenue (PKR)', '$revenue', Icons.payments),
            ],
          ),
          const SizedBox(height: 24),
          Text('Doctors', style: Theme.of(context).textTheme.titleLarge),
          ...doctors.map(
            (d) => Card(
              child: ListTile(
                title: Text(d.name),
                subtitle: Text(
                  '${d.qualification} · Fee ${d.feePkr} · max ${d.maxTokensPerDay}/day',
                ),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit doctor — wire to Firestore in production'),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Departments', style: Theme.of(context).textTheme.titleLarge),
          ...departments.map(
            (d) => ListTile(
              leading: const Icon(Icons.local_hospital, color: AppTheme.accentGreen),
              title: Text(d.nameEn),
              subtitle: Text(d.nameUr),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Staff roles, schedules, blocked dates — see docs/02-DATABASE_SCHEMA.md',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            label: const Text('Manage schedules & staff'),
          ),
        ],
      ),
    );
  }

  Widget _kpi(String label, String value, IconData icon) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.primaryBlue),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}