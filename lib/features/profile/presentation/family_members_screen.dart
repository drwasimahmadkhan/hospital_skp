import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/data/mock_data_store.dart';
import '../../shared/models/enums.dart';
import '../../shared/models/family_member_model.dart';

class FamilyMembersScreen extends ConsumerStatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  ConsumerState<FamilyMembersScreen> createState() =>
      _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends ConsumerState<FamilyMembersScreen> {
  Future<void> _add() async {
    final name = TextEditingController();
    final age = TextEditingController(text: '30');
    String relation = 'child';
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add family member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(
              controller: age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            DropdownButtonFormField<String>(
              value: relation,
              items: const [
                DropdownMenuItem(value: 'mother', child: Text('Mother')),
                DropdownMenuItem(value: 'father', child: Text('Father')),
                DropdownMenuItem(value: 'child', child: Text('Child')),
                DropdownMenuItem(value: 'spouse', child: Text('Spouse')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => relation = v ?? 'other',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final user = MockDataStore.instance.currentUser;
              if (user != null && name.text.trim().isNotEmpty) {
                MockDataStore.instance.familyMembers.add(
                  FamilyMemberModel(
                    id: 'fam_${DateTime.now().millisecondsSinceEpoch}',
                    ownerUserId: user.id,
                    name: name.text.trim(),
                    age: int.tryParse(age.text) ?? 0,
                    gender: Gender.other,
                    relation: relation,
                  ),
                );
              }
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final family = MockDataStore.instance.familyMembers;
    return Scaffold(
      appBar: AppBar(title: const Text('Family members')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
      body: family.isEmpty
          ? const Center(child: Text('No family members yet'))
          : ListView.builder(
              itemCount: family.length,
              itemBuilder: (_, i) {
                final f = family[i];
                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(f.name),
                  subtitle: Text('${f.relation} · age ${f.age}'),
                );
              },
            ),
    );
  }
}