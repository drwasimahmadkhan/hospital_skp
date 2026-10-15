class DoctorScheduleModel {
  const DoctorScheduleModel({
    required this.id,
    required this.doctorId,
    /// 1=Mon … 7=Sun
    required this.weekday,
    required this.startTime,
    required this.endTime,
    this.breakStart,
    this.breakEnd,
    this.maxTokens,
    this.isOff = false,
  });

  final String id;
  final String doctorId;
  final int weekday;
  final String startTime; // "09:00"
  final String endTime; // "17:00"
  final String? breakStart;
  final String? breakEnd;
  final int? maxTokens;
  final bool isOff;

  factory DoctorScheduleModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return DoctorScheduleModel(
      id: id ?? json['id'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      weekday: (json['weekday'] as num?)?.toInt() ?? 1,
      startTime: json['startTime'] as String? ?? '09:00',
      endTime: json['endTime'] as String? ?? '17:00',
      breakStart: json['breakStart'] as String?,
      breakEnd: json['breakEnd'] as String?,
      maxTokens: (json['maxTokens'] as num?)?.toInt(),
      isOff: json['isOff'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        'weekday': weekday,
        'startTime': startTime,
        'endTime': endTime,
        'breakStart': breakStart,
        'breakEnd': breakEnd,
        'maxTokens': maxTokens,
        'isOff': isOff,
      };
}

/// Holiday / leave block for a specific calendar date.
class DoctorDateBlockModel {
  const DoctorDateBlockModel({
    required this.id,
    required this.doctorId,
    required this.date,
    required this.reason,
  });

  final String id;
  final String doctorId;
  final String date; // yyyy-MM-dd
  final String reason;

  factory DoctorDateBlockModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return DoctorDateBlockModel(
      id: id ?? json['id'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      reason: json['reason'] as String? ?? 'leave',
    );
  }

  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        'date': date,
        'reason': reason,
      };
}