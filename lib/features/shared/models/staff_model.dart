import 'enums.dart';

class StaffModel {
  const StaffModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.role,
    this.departmentId,
    this.doctorId,
  });

  final String id;
  final String userId;
  final String fullName;
  final UserRole role;
  final String? departmentId;
  final String? doctorId;

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      departmentId: json['departmentId'] as String?,
      doctorId: json['doctorId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'fullName': fullName,
        'role': role.name,
        'departmentId': departmentId,
        'doctorId': doctorId,
      };
}
