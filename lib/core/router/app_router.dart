import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_dashboard.dart';
import '../../features/appointments/presentation/my_appointments_screen.dart';
import '../../features/auth/presentation/complete_profile_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/booking/presentation/booking_confirmation_screen.dart';
import '../../features/booking/presentation/date_slot_screen.dart';
import '../../features/doctor/presentation/doctor_dashboard.dart';
import '../../features/doctors/presentation/doctor_list_screen.dart';
import '../../features/doctors/presentation/doctor_profile_screen.dart';
import '../../features/feedback/presentation/feedback_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/family_members_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/queue/presentation/live_queue_screen.dart';
import '../../features/receptionist/presentation/receptionist_dashboard.dart';
import '../../features/shared/models/enums.dart';
import '../providers/app_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login' || loc == '/otp' || loc == '/onboarding' || loc == '/';
      if (auth == null && !loggingIn) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/complete-profile',
        builder: (_, __) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpScreen(
            phone: extra['phone'] as String? ?? '',
            demoRole: extra['role'] as UserRole? ?? UserRole.patient,
          );
        },
      ),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/doctors/:departmentId',
        builder: (_, state) => DoctorListScreen(
          departmentId: state.pathParameters['departmentId']!,
        ),
      ),
      GoRoute(
        path: '/doctor-profile/:doctorId',
        builder: (_, state) => DoctorProfileScreen(
          doctorId: state.pathParameters['doctorId']!,
        ),
      ),
      GoRoute(
        path: '/book/:doctorId',
        builder: (_, state) => DateSlotScreen(
          doctorId: state.pathParameters['doctorId']!,
        ),
      ),
      GoRoute(
        path: '/booking-confirmation/:appointmentId',
        builder: (_, state) => BookingConfirmationScreen(
          appointmentId: state.pathParameters['appointmentId']!,
        ),
      ),
      GoRoute(
        path: '/appointments',
        builder: (_, __) => const MyAppointmentsScreen(),
      ),
      GoRoute(
        path: '/queue/:appointmentId',
        builder: (_, state) => LiveQueueScreen(
          appointmentId: state.pathParameters['appointmentId']!,
        ),
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/family', builder: (_, __) => const FamilyMembersScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(path: '/feedback', builder: (_, __) => const FeedbackScreen()),
      GoRoute(
        path: '/receptionist',
        builder: (_, __) => const ReceptionistDashboard(),
      ),
      GoRoute(path: '/doctor', builder: (_, __) => const DoctorDashboard()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
    ],
  );
});

/// Notifies GoRouter when auth changes.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this.ref) {
    ref.listen<dynamic>(authStateProvider, (_, __) => notifyListeners());
  }
  final Ref ref;
}