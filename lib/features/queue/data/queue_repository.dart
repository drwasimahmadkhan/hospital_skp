import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/token_utils.dart';
import '../../shared/data/mock_data_store.dart';
import '../../shared/models/appointment_model.dart';
import '../../shared/models/queue_state_model.dart';

final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  return QueueRepository();
});

class QueueSnapshot {
  const QueueSnapshot({
    required this.queue,
    required this.appointment,
    required this.patientsAhead,
    required this.estimatedWaitMinutes,
    this.isConnected = true,
  });

  final QueueStateModel queue;
  final AppointmentModel appointment;
  final int patientsAhead;
  final int estimatedWaitMinutes;
  final bool isConnected;
}

class QueueRepository {
  final _mock = MockDataStore.instance;

  Stream<QueueStateModel> watchQueue(String doctorId, String date) {
    if (AppConstants.useMockData) {
      return _mock.watchQueue(doctorId, date);
    }
    // Production: FirebaseFirestore.instance
    //   .collection('queue_state')
    //   .doc(AppDateUtils.queueDocId(doctorId, date))
    //   .snapshots()
    throw UnimplementedError('Firestore realtime listener');
  }

  QueueSnapshot buildSnapshot({
    required QueueStateModel queue,
    required AppointmentModel appointment,
    bool isConnected = true,
  }) {
    final ahead = AppConstants.useMockData
        ? _mock.patientsAheadFor(appointment)
        : TokenUtils.patientsAhead(
            myToken: appointment.tokenNumber,
            activeLowerTokens: const [],
          );
    return QueueSnapshot(
      queue: queue,
      appointment: appointment,
      patientsAhead: ahead,
      estimatedWaitMinutes: TokenUtils.estimatedWaitMinutes(
        patientsAhead: ahead,
        avgConsultMinutes: queue.avgConsultMinutes,
      ),
      isConnected: isConnected,
    );
  }

  Future<void> callNext(String doctorId, {String? date}) async {
    final d = date ?? AppDateUtils.formatDay(DateTime.now());
    if (AppConstants.useMockData) {
      _mock.callNext(doctorId, d);
      return;
    }
    throw UnimplementedError('Cloud Function callNext');
  }

  Future<void> togglePause(String doctorId, {String? date}) async {
    final d = date ?? AppDateUtils.formatDay(DateTime.now());
    if (AppConstants.useMockData) {
      _mock.togglePause(doctorId, d);
      return;
    }
    throw UnimplementedError();
  }

  List<AppointmentModel> todayForDoctor(String doctorId) {
    final today = AppDateUtils.formatDay(DateTime.now());
    if (AppConstants.useMockData) {
      final list = _mock.appointments
          .where((a) => a.doctorId == doctorId && a.date == today)
          .toList()
        ..sort((a, b) => a.tokenNumber.compareTo(b.tokenNumber));
      return list;
    }
    return const [];
  }
}