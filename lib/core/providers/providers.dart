/// Central DI exports — avoid duplicating providers defined in feature modules.
library;

export 'app_providers.dart';
export '../../features/appointments/data/appointments_repository.dart';
export '../../features/auth/data/auth_repository.dart';
export '../../features/booking/data/booking_repository.dart';
export '../../features/queue/data/queue_repository.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../../features/notifications/data/fcm_service.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(
    messaging: AppConstants.useMockData ? null : FirebaseMessaging.instance,
  );
});
