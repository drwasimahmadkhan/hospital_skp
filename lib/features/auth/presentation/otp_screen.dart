import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/models/enums.dart';
import '../data/auth_repository.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    this.demoRole = UserRole.patient,
  });

  final String phone;
  final UserRole demoRole;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otp = TextEditingController(text: '123456');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await ref.read(authRepositoryProvider).verifyOtp(
            phoneInput: widget.phone,
            otp: _otp.text.trim(),
            demoRole: widget.demoRole,
          );
      ref.read(authStateProvider.notifier).state = user;
      if (!mounted) return;
      switch (user.role) {
        case UserRole.receptionist:
          context.go('/receptionist');
        case UserRole.doctor:
          context.go('/doctor');
        case UserRole.admin:
          context.go('/admin');
        case UserRole.patient:
          context.go('/home');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Code sent to ${widget.phone}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Demo mode: enter any 4+ digit code (prefilled 123456).'),
            const SizedBox(height: 24),
            TextField(
              controller: _otp,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 28,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(labelText: 'OTP'),
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: AppTheme.danger)),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _verify,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Verify & continue'),
            ),
          ],
        ),
      ),
    );
  }
}