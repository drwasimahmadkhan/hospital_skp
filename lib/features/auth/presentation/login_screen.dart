import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/phone_utils.dart';
import '../../shared/models/enums.dart';
import '../data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController(text: '03001234567');
  UserRole _demoRole = UserRole.patient;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (!PhoneUtils.isValidPk(_phone.text)) {
        throw ArgumentError('Enter a valid PK mobile (e.g. 03xxxxxxxxx)');
      }
      await ref.read(authRepositoryProvider).sendOtp(_phone.text);
      if (!mounted) return;
      context.push(
        '/otp',
        extra: {'phone': _phone.text, 'role': _demoRole},
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.local_hospital,
                size: 64, color: AppTheme.primaryBlue),
            const SizedBox(height: 12),
            Text(
              'Sign in with mobile',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'We will send a one-time password (OTP) to your number.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Mobile number',
                prefixText: '+92  ',
                hintText: '3xx xxxxxxx',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: _demoRole,
              decoration: const InputDecoration(
                labelText: 'Demo role (mock mode)',
              ),
              items: UserRole.values
                  .map(
                    (r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _demoRole = v ?? UserRole.patient),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppTheme.danger)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _continue,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}