import 'dart:async';

import '../models/appointment_model.dart';
import '../models/department_model.dart';
import '../models/doctor_model.dart';
import '../models/doctor_schedule_model.dart';
import '../models/enums.dart';
import '../models/family_member_model.dart';
import '../models/notification_model.dart';
import '../models/patient_model.dart';
import '../models/queue_state_model.dart';
import '../models/user_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/token_utils.dart';

/// In-memory hospital data so the app runs without Firebase (useMockData=true).
class MockDataStore {
  MockDataStore._() {
    _seed();
  }

  static final MockDataStore instance = MockDataStore._();

  UserModel? currentUser;
  PatientModel? currentPatient;

  final departments = <DepartmentModel>[];
  final doctors = <DoctorModel>[];
  final schedules = <DoctorScheduleModel>[];
  final appointments = <AppointmentModel>[];
  final familyMembers = <FamilyMemberModel>[];
  final notifications = <NotificationModel>[];
  final queueStates = <String, QueueStateModel>{};

  final _queueControllers = <String, StreamController<QueueStateModel>>{};
  final _apptController =
      StreamController<List<AppointmentModel>>.broadcast();

  void _seed() {
    departments.addAll([
      const DepartmentModel(
        id: 'dept_cardio',
        nameEn: 'Cardiology',
        nameUr: 'دل کے امراض',
        icon: 'favorite',
        sortOrder: 1,
      ),
      const DepartmentModel(
        id: 'dept_gm',
        nameEn: 'General Medicine',
        nameUr: 'جنرل میڈیسن',
        icon: 'medical_services',
        sortOrder: 2,
      ),
      const DepartmentModel(
        id: 'dept_pedia',
        nameEn: 'Pediatrics',
        nameUr: 'اطفال',
        icon: 'child_care',
        sortOrder: 3,
      ),
      const DepartmentModel(
        id: 'dept_ortho',
        nameEn: 'Orthopedics',
        nameUr: 'ہڈیاں اور جوڑ',
        icon: 'accessibility_new',
        sortOrder: 4,
      ),
    ]);

    doctors.addAll([
      const DoctorModel(
        id: 'doc_ahmed',
        userId: 'staff_doc_ahmed',
        departmentId: 'dept_cardio',
        name: 'Dr. Ahmed Khan',
        qualification: 'MBBS, FCPS (Cardiology)',
        experienceYears: 15,
        feePkr: 2500,
        bio: 'Senior consultant cardiologist.',
        avgConsultMinutes: 12,
        maxTokensPerDay: 30,
      ),
      const DoctorModel(
        id: 'doc_sara',
        userId: 'staff_doc_sara',
        departmentId: 'dept_gm',
        name: 'Dr. Sara Malik',
        qualification: 'MBBS, MD',
        experienceYears: 10,
        feePkr: 1800,
        bio: 'General physician.',
        avgConsultMinutes: 10,
        maxTokensPerDay: 40,
      ),
      const DoctorModel(
        id: 'doc_bilal',
        userId: 'staff_doc_bilal',
        departmentId: 'dept_pedia',
        name: 'Dr. Bilal Hussain',
        qualification: 'MBBS, DCH',
        experienceYears: 8,
        feePkr: 1500,
        avgConsultMinutes: 10,
        maxTokensPerDay: 35,
      ),
    ]);

    final today = AppDateUtils.formatDay(DateTime.now());
    for (final d in doctors) {
      final qid = AppDateUtils.queueDocId(d.id, today);
      queueStates[qid] = QueueStateModel(
        id: qid,
        doctorId: d.id,
        date: today,
        currentTokenNumber: 3,
        lastIssuedToken: 8,
        maxTokens: d.maxTokensPerDay,
        avgConsultMinutes: d.avgConsultMinutes,
      );
    }
  }

  void loginAsDemoPatient() {
    currentUser = const UserModel(
      id: 'user_demo',
      phone: '923001234567',
      role: UserRole.patient,
      displayName: 'Ali Raza',
      languageCode: 'en',
    );
    currentPatient = const PatientModel(
      id: 'pat_demo',
      userId: 'user_demo',
      name: 'Ali Raza',
      phone: '923001234567',
      age: 34,
      gender: Gender.male,
    );
    familyMembers
      ..clear()
      ..add(
        const FamilyMemberModel(
          id: 'fam_1',
          ownerUserId: 'user_demo',
          name: 'Fatima Raza',
          age: 58,
          gender: Gender.female,
          relation: 'mother',
        ),
      );

    final today = AppDateUtils.formatDay(DateTime.now());
    if (!appointments.any((a) => a.id == 'appt_demo')) {
      appointments.add(
        AppointmentModel(
          id: 'appt_demo',
          doctorId: 'doc_ahmed',
          doctorName: 'Dr. Ahmed Khan',
          departmentId: 'dept_cardio',
          patientId: 'pat_demo',
          patientName: 'Ali Raza',
          bookedByUserId: 'user_demo',
          phone: '923001234567',
          date: today,
          tokenNumber: 7,
          tokenLabel: TokenUtils.format(7),
          status: AppointmentStatus.booked,
          feePkr: 2500,
          expectedWindowStart: '11:00',
          createdAt: DateTime.now(),
        ),
      );
    }
    _apptController.add(List.unmodifiable(appointments));
  }

  void loginAsRole(UserRole role) {
    switch (role) {
      case UserRole.receptionist:
        currentUser = const UserModel(
          id: 'user_reception',
          phone: '923009998887',
          role: UserRole.receptionist,
          displayName: 'Reception Desk',
        );
        break;
      case UserRole.doctor:
        currentUser = const UserModel(
          id: 'staff_doc_ahmed',
          phone: '923007776665',
          role: UserRole.doctor,
          displayName: 'Dr. Ahmed Khan',
        );
        break;
      case UserRole.admin:
        currentUser = const UserModel(
          id: 'user_admin',
          phone: '923001111111',
          role: UserRole.admin,
          displayName: 'Hospital Admin',
        );
        break;
      case UserRole.patient:
        loginAsDemoPatient();
        break;
    }
  }

  void logout() {
    currentUser = null;
    currentPatient = null;
  }

  Stream<QueueStateModel> watchQueue(String doctorId, String date) {
    final id = AppDateUtils.queueDocId(doctorId, date);
    queueStates.putIfAbsent(
      id,
      () => QueueStateModel(
        id: id,
        doctorId: doctorId,
        date: date,
        currentTokenNumber: 0,
        lastIssuedToken: 0,
        maxTokens: doctors
            .firstWhere(
              (d) => d.id == doctorId,
              orElse: () => doctors.first,
            )
            .maxTokensPerDay,
      ),
    );
    final controller = _queueControllers.putIfAbsent(
      id,
      () => StreamController<QueueStateModel>.broadcast(),
    );
    // Emit current then keep open for updates.
    scheduleMicrotask(() => controller.add(queueStates[id]!));
    return controller.stream;
  }

  void _emitQueue(String id) {
    final q = queueStates[id];
    if (q != null) _queueControllers[id]?.add(q);
  }

  Stream<List<AppointmentModel>> watchMyAppointments(String userId) {
    scheduleMicrotask(
      () => _apptController.add(
        appointments.where((a) => a.bookedByUserId == userId).toList(),
      ),
    );
    return _apptController.stream.map(
      (all) => all.where((a) => a.bookedByUserId == userId).toList(),
    );
  }

  /// Transactional-style token allocation (mock).
  AppointmentModel allocateToken({
    required DoctorModel doctor,
    required String date,
    required String patientId,
    required String patientName,
    required String bookedByUserId,
    required String phone,
    String? familyMemberId,
    String source = 'app',
    bool isEmergency = false,
  }) {
    // Prevent same patient + doctor + day (active).
    final duplicate = appointments.any(
      (a) =>
          a.doctorId == doctor.id &&
          a.date == date &&
          a.patientId == patientId &&
          !a.status.isTerminal,
    );
    if (duplicate) {
      throw StateError('Already booked with this doctor today.');
    }

    final phoneDayCount = appointments
        .where(
          (a) =>
              a.phone == phone &&
              a.date == date &&
              a.status != AppointmentStatus.cancelled,
        )
        .length;
    if (phoneDayCount >= AppConstants.maxBookingsPerPhonePerDay) {
      throw StateError('Daily booking limit reached for this phone.');
    }

    final qid = AppDateUtils.queueDocId(doctor.id, date);
    final queue = queueStates[qid] ??
        QueueStateModel(
          id: qid,
          doctorId: doctor.id,
          date: date,
          currentTokenNumber: 0,
          lastIssuedToken: 0,
          maxTokens: doctor.maxTokensPerDay,
          avgConsultMinutes: doctor.avgConsultMinutes,
        );

    if (queue.lastIssuedToken >= queue.maxTokens && !isEmergency) {
      throw StateError('No tokens left for this doctor today.');
    }

    final next = isEmergency
        ? (queue.currentTokenNumber + 1) // insert near front (simplified)
        : queue.lastIssuedToken + 1;
    final tokenLabel = TokenUtils.format(next);

    final appt = AppointmentModel(
      id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
      doctorId: doctor.id,
      doctorName: doctor.name,
      departmentId: doctor.departmentId,
      patientId: patientId,
      patientName: patientName,
      bookedByUserId: bookedByUserId,
      phone: phone,
      date: date,
      tokenNumber: next,
      tokenLabel: tokenLabel,
      status: AppointmentStatus.booked,
      familyMemberId: familyMemberId,
      feePkr: doctor.feePkr,
      isEmergency: isEmergency,
      expectedWindowStart: _estimateWindow(queue, next),
      createdAt: DateTime.now(),
      source: source,
    );

    appointments.add(appt);
    if (!isEmergency) {
      queueStates[qid] = queue.copyWith(lastIssuedToken: next);
    } else {
      queueStates[qid] = queue;
    }
    _emitQueue(qid);
    _apptController.add(List.unmodifiable(appointments));

    notifications.insert(
      0,
      NotificationModel(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        userId: bookedByUserId,
        title: 'Booking confirmed',
        body: 'Token $tokenLabel with ${doctor.name} on $date',
        type: NotificationType.bookingConfirmed,
        createdAt: DateTime.now(),
        data: {'appointmentId': appt.id},
      ),
    );
    return appt;
  }

  String _estimateWindow(QueueStateModel queue, int token) {
    final ahead = (token - queue.currentTokenNumber - 1).clamp(0, 999);
    final mins = ahead * queue.avgConsultMinutes;
    final start = DateTime.now().add(Duration(minutes: mins));
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  }

  int patientsAheadFor(AppointmentModel appt) {
    return appointments
        .where(
          (a) =>
              a.doctorId == appt.doctorId &&
              a.date == appt.date &&
              a.tokenNumber < appt.tokenNumber &&
              a.status.countsAsAhead,
        )
        .length;
  }

  void callNext(String doctorId, String date) {
    final qid = AppDateUtils.queueDocId(doctorId, date);
    final queue = queueStates[qid];
    if (queue == null || queue.paused) return;

    // Complete current in-progress if any.
    for (var i = 0; i < appointments.length; i++) {
      final a = appointments[i];
      if (a.doctorId == doctorId &&
          a.date == date &&
          a.status == AppointmentStatus.inProgress) {
        appointments[i] = a.copyWith(status: AppointmentStatus.completed);
      }
    }

    final next = appointments
        .where(
          (a) =>
              a.doctorId == doctorId &&
              a.date == date &&
              a.status.countsAsAhead,
        )
        .toList()
      ..sort((a, b) {
        if (a.isEmergency != b.isEmergency) {
          return a.isEmergency ? -1 : 1;
        }
        return a.tokenNumber.compareTo(b.tokenNumber);
      });

    if (next.isEmpty) return;
    final chosen = next.first;
    final idx = appointments.indexWhere((a) => a.id == chosen.id);
    appointments[idx] = chosen.copyWith(status: AppointmentStatus.inProgress);

    queueStates[qid] = queue.copyWith(currentTokenNumber: chosen.tokenNumber);
    _emitQueue(qid);
    _apptController.add(List.unmodifiable(appointments));

    notifications.insert(
      0,
      NotificationModel(
        id: 'n_turn_${DateTime.now().millisecondsSinceEpoch}',
        userId: chosen.bookedByUserId,
        title: 'Your turn is now',
        body: 'Please proceed to the doctor. Token ${chosen.tokenLabel}',
        type: NotificationType.turnNow,
        createdAt: DateTime.now(),
      ),
    );
  }

  void setAppointmentStatus(String appointmentId, AppointmentStatus status) {
    final idx = appointments.indexWhere((a) => a.id == appointmentId);
    if (idx < 0) return;
    appointments[idx] = appointments[idx].copyWith(status: status);
    _apptController.add(List.unmodifiable(appointments));
  }

  void togglePause(String doctorId, String date, {String? reason}) {
    final qid = AppDateUtils.queueDocId(doctorId, date);
    final q = queueStates[qid];
    if (q == null) return;
    queueStates[qid] = q.copyWith(
      paused: !q.paused,
      pauseReason: reason ?? (q.paused ? null : 'Break'),
    );
    _emitQueue(qid);
  }
}