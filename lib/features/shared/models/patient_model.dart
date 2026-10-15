import 'enums.dart';

class PatientModel {
  const PatientModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.age,
    required this.gender,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final String phone;
  final int age;
  final Gender gender;
  final DateTime? createdAt;

  factory PatientModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return PatientModel(
      id: id ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: Gender.values.firstWhere(
        (g) => g.name == json['gender'],
        orElse: () => Gender.other,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'phone': phone,
        'age': age,
        'gender': gender.name,
        'createdAt': createdAt?.toIso8601String(),
      };
}