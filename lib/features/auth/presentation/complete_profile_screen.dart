import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../shared/models/enums.dart';
import '../data/auth_repository.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: '30');
  Gender _gender = Gender.male;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            TextField(
              controller: _ageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            DropdownButtonFormField<Gender>(
              value: _gender,
              items: Gender.values
                  .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                  .toList(),
              onChanged: (v) => setState(() => _gender = v ?? Gender.male),
              decoration: const InputDecoration(labelText: 'Gender'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authRepositoryProvider).completeProfile(
                      name: _nameCtrl.text.trim(),
                      age: int.tryParse(_ageCtrl.text) ?? 30,
                      gender: _gender,
                    );
                final user = ref.read(authRepositoryProvider).currentUser;
                ref.read(authStateProvider.notifier).state = user;
                if (context.mounted) context.go('/home');
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
