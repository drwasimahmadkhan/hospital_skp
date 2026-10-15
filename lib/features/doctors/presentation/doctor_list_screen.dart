import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/iterable_extensions.dart';
import '../../shared/data/mock_data_store.dart';

class DoctorListScreen extends ConsumerWidget {
  const DoctorListScreen({super.key, required this.departmentId});

  final String departmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dept = MockDataStore.instance.departments
        .where((d) => d.id == departmentId)
        .firstOrNull;
    final doctors = MockDataStore.instance.doctors
        .where((d) => d.departmentId == departmentId && d.isActive)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(dept?.nameEn ?? 'Doctors')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final d = doctors[i];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
                child: Text(
                  d.name.split(' ').last.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              title: Text(d.name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                '${d.qualification}\n${d.experienceYears} yrs · Fee Rs ${d.feePkr}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/doctor-profile/${d.id}'),
            ),
          );
        },
      ),
    );
  }
}