import '../../shared/models/appointment_model.dart';
import '../../shared/models/enums.dart';
import '../../shared/models/queue_state_model.dart';
import '../../../core/utils/token_utils.dart';

/// Pure queue math — shared by mock store and (later) Firestore mappers.
class QueueLogic {
  QueueLogic._();

  static int patientsAhead({
    required AppointmentModel mine,
    required List<AppointmentModel> sameDoctorDay,
  }) {
    return sameDoctorDay
        .where(
          (a) =>
              a.tokenNumber < mine.tokenNumber &&
              a.status.countsAsAhead,
        )
        .length;
  }

  static int estimatedWaitMinutes({
    required int patientsAheadCount,
    required QueueStateModel queue,
  }) {
    return TokenUtils.estimatedWaitMinutes(
      patientsAhead: patientsAheadCount,
      avgConsultMinutes: queue.avgConsultMinutes,
    );
  }

  /// Next patient: emergencies first, then lowest token among BOOKED/CHECKED_IN.
  static AppointmentModel? pickNext(List<AppointmentModel> candidates) {
    final open = candidates.where((a) => a.status.countsAsAhead).toList()
      ..sort((a, b) {
        if (a.isEmergency != b.isEmergency) {
          return a.isEmergency ? -1 : 1;
        }
        return a.tokenNumber.compareTo(b.tokenNumber);
      });
    return open.isEmpty ? null : open.first;
  }

  static bool canCancel({
    required DateTime now,
    required DateTime appointmentDayStart,
    required int cutoffHours,
  }) {
    return now.isBefore(
      appointmentDayStart.subtract(Duration(hours: cutoffHours)),
    );
  }
}