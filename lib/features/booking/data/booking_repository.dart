import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../shared/data/mock_data_store.dart';
import '../../shared/models/appointment_model.dart';
import '../../shared/models/doctor_model.dart';
import '../../shared/models/enums.dart';
import '../../shared/models/queue_state_model.dart';
import '../../../core/utils/date_utils.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

class BookingRepository {
  final _mock = MockDataStore.instance;

  Future<QueueStateModel> getQueueState(String doctorId, String date) async {
    if (AppConstants.useMockData) {
      final id = AppDateUtils.queueDocId(doctorId, date);
      return _mock.queueStates[id] ??
          QueueStateModel(
            id: id,
            doctorId: doctorId,
            date: date,
            currentTokenNumber: 0,
            lastIssuedToken: 0,
            maxTokens: 40,
          );
    }
    throw UnimplementedError('Use Firestore in production');
  }

  /// Allocates token via mock store or Cloud Function `allocateToken`.
  Future<AppointmentModel> book({
    required DoctorModel doctor,
    required String date,
    required String patientId,
    required String patientName,
    required String bookedByUserId,
    required String phone,
    String? familyMemberId,
    String source = 'app',
    bool isEmergency = false,
  }) async {
    if (AppConstants.useMockData) {
      return _mock.allocateToken(
        doctor: doctor,
        date: date,
        patientId: patientId,
        patientName: patientName,
        bookedByUserId: bookedByUserId,
        phone: phone,
        familyMemberId: familyMemberId,
        source: source,
        isEmergency: isEmergency,
      );
    }
    // Production: FirebaseFunctions.instance.httpsCallable('allocateToken')
    throw UnimplementedError('Call Cloud Function allocateToken');
  }

  Future<void> cancel(String appointmentId) async {
    if (AppConstants.useMockData) {
      _mock.setAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
      return;
    }
    throw UnimplementedError();
  }

  Future<List<DoctorModel>> doctorsByDepartment(String departmentId) async {
    if (AppConstants.useMockData) {
      return _mock.doctors
          .where((d) => d.departmentId == departmentId && d.isActive)
          .toList();
    }
    throw UnimplementedError();
  }

  Future<List<DoctorModel>> allDoctors() async {
    if (AppConstants.useMockData) return List.of(_mock.doctors);
    throw UnimplementedError();
  }

  DoctorModel? doctorById(String id) {
    if (AppConstants.useMockData) {
      try {
        return _mock.doctors.firstWhere((d) => d.id == id);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}