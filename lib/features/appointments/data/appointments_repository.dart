import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../shared/data/mock_data_store.dart';
import '../../shared/models/appointment_model.dart';

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  return AppointmentsRepository();
});

class AppointmentsRepository {
  final _mock = MockDataStore.instance;

  Future<AppointmentModel?> getById(String id) async {
    if (AppConstants.useMockData) {
      for (final a in _mock.appointments) {
        if (a.id == id) return a;
      }
      return null;
    }
    throw UnimplementedError('Firestore get appointment');
  }

  Future<List<AppointmentModel>> listForPatient(String patientId) async {
    if (AppConstants.useMockData) {
      return _mock.appointments.where((a) => a.patientId == patientId).toList();
    }
    throw UnimplementedError();
  }
}
