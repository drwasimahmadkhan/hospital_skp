import 'enums.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.phone,
    required this.role,
    this.displayName,
    this.fcmTokens = const [],
    this.languageCode = 'en',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String phone;
  final UserRole role;
  final String? displayName;
  final List<String> fcmTokens;
  final String languageCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return UserModel(
      id: id ?? json['id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: UserRoleX.fromString(json['role'] as String?),
      displayName: json['displayName'] as String?,
      fcmTokens: (json['fcmTokens'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      languageCode: json['languageCode'] as String? ?? 'en',
      createdAt: _dt(json['createdAt']),
      updatedAt: _dt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'role': role.firestoreValue,
        'displayName': displayName,
        'fcmTokens': fcmTokens,
        'languageCode': languageCode,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  UserModel copyWith({
    String? displayName,
    UserRole? role,
    String? languageCode,
    List<String>? fcmTokens,
  }) {
    return UserModel(
      id: id,
      phone: phone,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      languageCode: languageCode ?? this.languageCode,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    // Firestore Timestamp duck-typing
    try {
      return (v as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}