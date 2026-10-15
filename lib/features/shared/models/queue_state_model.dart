/// Live queue document: one per doctor per calendar day.
/// Doc id pattern: `{doctorId}_{yyyy-MM-dd}`
class QueueStateModel {
  const QueueStateModel({
    required this.id,
    required this.doctorId,
    required this.date,
    required this.currentTokenNumber,
    required this.lastIssuedToken,
    required this.maxTokens,
    this.avgConsultMinutes = 12,
    this.paused = false,
    this.pauseReason,
    this.updatedAt,
  });

  final String id;
  final String doctorId;
  final String date;
  final int currentTokenNumber;
  final int lastIssuedToken;
  final int maxTokens;
  final int avgConsultMinutes;
  final bool paused;
  final String? pauseReason;
  final DateTime? updatedAt;

  int get remainingCapacity =>
      (maxTokens - lastIssuedToken).clamp(0, maxTokens);

  factory QueueStateModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return QueueStateModel(
      id: id ?? json['id'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      currentTokenNumber: (json['currentTokenNumber'] as num?)?.toInt() ?? 0,
      lastIssuedToken: (json['lastIssuedToken'] as num?)?.toInt() ?? 0,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 40,
      avgConsultMinutes: (json['avgConsultMinutes'] as num?)?.toInt() ?? 12,
      paused: json['paused'] as bool? ?? false,
      pauseReason: json['pauseReason'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        'date': date,
        'currentTokenNumber': currentTokenNumber,
        'lastIssuedToken': lastIssuedToken,
        'maxTokens': maxTokens,
        'avgConsultMinutes': avgConsultMinutes,
        'paused': paused,
        'pauseReason': pauseReason,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  QueueStateModel copyWith({
    int? currentTokenNumber,
    int? lastIssuedToken,
    int? avgConsultMinutes,
    bool? paused,
    String? pauseReason,
  }) {
    return QueueStateModel(
      id: id,
      doctorId: doctorId,
      date: date,
      currentTokenNumber: currentTokenNumber ?? this.currentTokenNumber,
      lastIssuedToken: lastIssuedToken ?? this.lastIssuedToken,
      maxTokens: maxTokens,
      avgConsultMinutes: avgConsultMinutes ?? this.avgConsultMinutes,
      paused: paused ?? this.paused,
      pauseReason: pauseReason ?? this.pauseReason,
      updatedAt: DateTime.now(),
    );
  }
}