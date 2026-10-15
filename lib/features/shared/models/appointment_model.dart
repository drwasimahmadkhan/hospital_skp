import 'enums.dart';

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.departmentId,
    required this.patientId,
    required this.patientName,
    required this.bookedByUserId,
    required this.phone,
    required this.date,
    required this.tokenNumber,
    required this.tokenLabel,
    required this.status,
    this.familyMemberId,
    this.feePkr = 0,
    this.isEmergency = false,
    this.expectedWindowStart,
    this.checkedInAt,
    this.calledAt,
    this.completedAt,
    this.createdAt,
    this.source = 'app',
  });

  final String id;
  final String doctorId;
  final String doctorName;
  final String departmentId;
  final String patientId;
  final String patientName;
  final String bookedByUserId;
  final String phone;
  final String date; // yyyy-MM-dd
  final int tokenNumber;
  final String tokenLabel; // T-01
  final AppointmentStatus status;
  final String? familyMemberId;
  final int feePkr;
  final bool isEmergency;
  final String? expectedWindowStart;
  final DateTime? checkedInAt;
  final DateTime? calledAt;
  final DateTime? completedAt;
  final DateTime? createdAt;

  /// app | phone | walk_in
  final String source;

  factory AppointmentModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return AppointmentModel(
      id: id ?? json['id'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      departmentId: json['departmentId'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      bookedByUserId: json['bookedByUserId'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      date: json['date'] as String? ?? '',
      tokenNumber: (json['tokenNumber'] as num?)?.toInt() ?? 0,
      tokenLabel: json['tokenLabel'] as String? ?? '',
      status: AppointmentStatusX.fromString(json['status'] as String?),
      familyMemberId: json['familyMemberId'] as String?,
      feePkr: (json['feePkr'] as num?)?.toInt() ?? 0,
      isEmergency: json['isEmergency'] as bool? ?? false,
      expectedWindowStart: json['expectedWindowStart'] as String?,
      checkedInAt: _dt(json['checkedInAt']),
      calledAt: _dt(json['calledAt']),
      completedAt: _dt(json['completedAt']),
      createdAt: _dt(json['createdAt']),
      source: json['source'] as String? ?? 'app',
    );
  }

  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        'doctorName': doctorName,
        'departmentId': departmentId,
        'patientId': patientId,
        'patientName': patientName,
        'bookedByUserId': bookedByUserId,
        'phone': phone,
        'date': date,
        'tokenNumber': tokenNumber,
        'tokenLabel': tokenLabel,
        'status': status.firestoreValue,
        'familyMemberId': familyMemberId,
        'feePkr': feePkr,
        'isEmergency': isEmergency,
        'expectedWindowStart': expectedWindowStart,
        'checkedInAt': checkedInAt?.toIso8601String(),
        'calledAt': calledAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'source': source,
      };

  AppointmentModel copyWith({AppointmentStatus? status}) {
    return AppointmentModel(
      id: id,
      doctorId: doctorId,
      doctorName: doctorName,
      departmentId: departmentId,
      patientId: patientId,
      patientName: patientName,
      bookedByUserId: bookedByUserId,
      phone: phone,
      date: date,
      tokenNumber: tokenNumber,
      tokenLabel: tokenLabel,
      status: status ?? this.status,
      familyMemberId: familyMemberId,
      feePkr: feePkr,
      isEmergency: isEmergency,
      expectedWindowStart: expectedWindowStart,
      checkedInAt: checkedInAt,
      calledAt: calledAt,
      completedAt: completedAt,
      createdAt: createdAt,
      source: source,
    );
  }

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    try {
      return (v as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}