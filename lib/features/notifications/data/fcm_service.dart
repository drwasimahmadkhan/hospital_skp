import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/constants/app_constants.dart';

class FcmService {
  FcmService({FirebaseMessaging? messaging}) : _messaging = messaging;

  final FirebaseMessaging? _messaging;

  Future<void> initialize() async {
    if (AppConstants.useMockData) return;
    await _messaging!.requestPermission();
    final token = await _messaging.getToken();
    // TODO: persist token to Firestore users/{uid}/fcmTokens
    assert(token != null);
  }

  Future<void> subscribeDoctorQueue(String doctorId) async {
    if (AppConstants.useMockData) return;
    await _messaging!.subscribeToTopic('queue_$doctorId');
  }
}
