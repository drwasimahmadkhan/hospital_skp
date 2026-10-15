import 'enums.dart';

class FamilyMemberModel {
  const FamilyMemberModel({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.age,
    required this.gender,
    required this.relation,
  });

  final String id;
  final String ownerUserId;
  final String name;
  final int age;
  final Gender gender;

  /// mother, father, child, spouse, other
  final String relation;

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return FamilyMemberModel(
      id: id ?? json['id'] as String? ?? '',
      ownerUserId: json['ownerUserId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: Gender.values.firstWhere(
        (g) => g.name == json['gender'],
        orElse: () => Gender.other,
      ),
      relation: json['relation'] as String? ?? 'other',
    );
  }

  Map<String, dynamic> toJson() => {
        'ownerUserId': ownerUserId,
        'name': name,
        'age': age,
        'gender': gender.name,
        'relation': relation,
      };
}