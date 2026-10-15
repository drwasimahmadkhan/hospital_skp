import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../booking/data/booking_repository.dart';

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.read(bookingRepositoryProvider).doctorById(doctorId);
    if (doctor == null) {
      return const Scaffold(body: Center(child: Text('Doctor not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(doctor.name)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => context.push('/book/${doctor.id}'),
            child: const Text('Book appointment'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.accentGreen.withValues(alpha: 0.2),
            child: const Icon(Icons.person, size: 48, color: AppTheme.accentGreen),
          ),
          const SizedBox(height: 16),
          Text(doctor.name, style: Theme.of(context).textTheme.headlineMedium),
          Text(doctor.qualification),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('${doctor.experienceYears} years exp.')),
              Chip(label: Text('Rs ${doctor.feePkr}')),
              Chip(label: Text('~${doctor.avgConsultMinutes} min / patient')),
            ],
          ),
          const SizedBox(height: 16),
          Text('About', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(doctor.bio ?? 'Consultant at City Care Hospital.'),
          const SizedBox(height: 16),
          Text('Timings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text('Mon–Sat · 09:00 – 17:00 (break 13:00–14:00)'),
          Text('Max tokens / day: ${doctor.maxTokensPerDay}'),
        ],
      ),
    );
  }
}