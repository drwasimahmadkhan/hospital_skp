class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.userId,
    required this.departmentId,
    required this.name,
    required this.qualification,
    required this.experienceYears,
    required this.feePkr,
    this.photoUrl,
    this.bio,
    this.avgConsultMinutes = 12,
    this.maxTokensPerDay = 40,
    this.isActive = true,
  });

  final String id;
  final String userId;
  final String departmentId;
  final String name;
  final String qualification;
  final int experienceYears;
  final int feePkr;
  final String? photoUrl;
  final String? bio;
  final int avgConsultMinutes;
  final int maxTokensPerDay;
  final bool isActive;

  factory DoctorModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return DoctorModel(
      id: id ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      departmentId: json['departmentId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      qualification: json['qualification'] as String? ?? '',
      experienceYears: (json['experienceYears'] as num?)?.toInt() ?? 0,
      feePkr: (json['feePkr'] as num?)?.toInt() ?? 0,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      avgConsultMinutes: (json['avgConsultMinutes'] as num?)?.toInt() ?? 12,
      maxTokensPerDay: (json['maxTokensPerDay'] as num?)?.toInt() ?? 40,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'departmentId': departmentId,
        'name': name,
        'qualification': qualification,
        'experienceYears': experienceYears,
        'feePkr': feePkr,
        'photoUrl': photoUrl,
        'bio': bio,
        'avgConsultMinutes': avgConsultMinutes,
        'maxTokensPerDay': maxTokensPerDay,
        'isActive': isActive,
      };
}