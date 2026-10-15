import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/phone_utils.dart';
import '../../auth/data/auth_repository.dart';
import '../../shared/data/mock_data_store.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final patient = MockDataStore.instance.currentPatient;
    final family = MockDataStore.instance.familyMembers;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user?.displayName ?? 'Patient'),
            subtitle: Text(
              user == null ? '' : PhoneUtils.display(user.phone),
            ),
          ),
          if (patient != null)
            ListTile(
              title: const Text('Details'),
              subtitle: Text(
                'Age ${patient.age} · ${patient.gender.name}',
              ),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.family_restroom),
            title: const Text('Family members'),
            subtitle: Text('${family.length} saved'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/family'),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language / زبان'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings'),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              ref.read(authStateProvider.notifier).state = null;
              if (context.mounted) context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}