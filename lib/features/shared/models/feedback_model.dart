class FeedbackModel {
  const FeedbackModel({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.userId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  final String id;
  final String appointmentId;
  final String doctorId;
  final String userId;
  final int rating; // 1-5
  final String? comment;
  final DateTime? createdAt;

  factory FeedbackModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return FeedbackModel(
      id: id ?? json['id'] as String? ?? '',
      appointmentId: json['appointmentId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'appointmentId': appointmentId,
        'doctorId': doctorId,
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt?.toIso8601String(),
      };
}