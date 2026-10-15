import 'enums.dart';

class TokenModel {
  const TokenModel({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.sequence,
    required this.label,
    required this.date,
    this.status = AppointmentStatus.booked,
    this.checkedInAt,
  });

  final String id;
  final String appointmentId;
  final String doctorId;
  final int sequence;
  final String label;
  final DateTime date;
  final AppointmentStatus status;
  final DateTime? checkedInAt;

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      id: json['id'] as String? ?? '',
      appointmentId: json['appointmentId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      sequence: json['sequence'] as int? ?? 0,
      label: json['label'] as String? ?? '',
      date: DateTime.tryParse(json['date'].toString()) ?? DateTime.now(),
      status: AppointmentStatus.fromString(json['status'] as String?),
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.tryParse(json['checkedInAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'appointmentId': appointmentId,
        'doctorId': doctorId,
        'sequence': sequence,
        'label': label,
        'date': date.toIso8601String(),
        'status': status.toFirestore(),
        'checkedInAt': checkedInAt?.toIso8601String(),
      };
}
