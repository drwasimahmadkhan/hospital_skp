enum UserRole {
  patient,
  receptionist,
  doctor,
  admin;

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.patient,
    );
  }

  String get firestoreValue => name;
}

/// Parsing helper used by [UserModel.fromJson].
abstract final class UserRoleX {
  static UserRole fromString(String? value) => UserRole.fromString(value);
}

enum AppointmentStatus {
  booked,
  checkedIn,
  inProgress,
  completed,
  cancelled,
  noShow,
  skipped;

  static AppointmentStatus fromString(String? value) {
    switch (value) {
      case 'CHECKED_IN':
      case 'checkedIn':
        return AppointmentStatus.checkedIn;
      case 'IN_PROGRESS':
      case 'inProgress':
      case 'IN_CONSULTATION':
        return AppointmentStatus.inProgress;
      case 'COMPLETED':
      case 'completed':
        return AppointmentStatus.completed;
      case 'CANCELLED':
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'NO_SHOW':
      case 'noShow':
        return AppointmentStatus.noShow;
      case 'SKIPPED':
      case 'skipped':
        return AppointmentStatus.skipped;
      case 'BOOKED':
      case 'booked':
      default:
        return AppointmentStatus.booked;
    }
  }

  String get firestoreValue {
    switch (this) {
      case AppointmentStatus.booked:
        return 'BOOKED';
      case AppointmentStatus.checkedIn:
        return 'CHECKED_IN';
      case AppointmentStatus.inProgress:
        return 'IN_PROGRESS';
      case AppointmentStatus.completed:
        return 'COMPLETED';
      case AppointmentStatus.cancelled:
        return 'CANCELLED';
      case AppointmentStatus.noShow:
        return 'NO_SHOW';
      case AppointmentStatus.skipped:
        return 'SKIPPED';
    }
  }

  String toFirestore() => firestoreValue;

  /// Counts toward "patients ahead" in the live queue.
  bool get countsAsAhead =>
      this == AppointmentStatus.booked || this == AppointmentStatus.checkedIn;

  bool get isTerminal =>
      this == AppointmentStatus.completed ||
      this == AppointmentStatus.cancelled ||
      this == AppointmentStatus.noShow ||
      this == AppointmentStatus.skipped;
}

abstract final class AppointmentStatusX {
  static AppointmentStatus fromString(String? value) =>
      AppointmentStatus.fromString(value);
}

enum QueueDoctorStatus {
  active,
  paused,
  onBreak,
  left;

  static QueueDoctorStatus fromString(String? value) {
    return QueueDoctorStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => QueueDoctorStatus.active,
    );
  }
}

enum Gender { male, female, other }

enum NotificationType {
  bookingConfirmed,
  reminderDay,
  reminderHour,
  turnNear,
  turnNow,
  doctorLeave,
  doctorDelayed,
  turnReminder,
  appointmentConfirmed,
  queueUpdate,
  general;

  static NotificationType fromString(String? value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.general,
    );
  }
}