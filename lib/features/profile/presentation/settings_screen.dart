import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_off_outlined),
            title: const Text('Backend'),
            subtitle: Text(AppConstants.backendLabel),
          ),
          const Divider(),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: locale.languageCode,
            onChanged: (v) =>
                ref.read(localeProvider.notifier).setLanguage(v!),
          ),
          RadioListTile<String>(
            title: const Text('اردو (Urdu)'),
            value: 'ur',
            groupValue: locale.languageCode,
            onChanged: (v) =>
                ref.read(localeProvider.notifier).setLanguage(v!),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Urdu enables RTL layout across the app. '
              'Full docs: open docs/index.html in a browser.',
            ),
          ),
        ],
      ),
    );
  }
}