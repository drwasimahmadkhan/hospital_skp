class DepartmentModel {
  const DepartmentModel({
    required this.id,
    required this.nameEn,
    required this.nameUr,
    this.icon = 'local_hospital',
    this.sortOrder = 0,
    this.isActive = true,
  });

  final String id;
  final String nameEn;
  final String nameUr;
  final String icon;
  final int sortOrder;
  final bool isActive;

  String localizedName(String languageCode) =>
      languageCode == 'ur' ? nameUr : nameEn;

  factory DepartmentModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return DepartmentModel(
      id: id ?? json['id'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      nameUr: json['nameUr'] as String? ?? '',
      icon: json['icon'] as String? ?? 'local_hospital',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'nameEn': nameEn,
        'nameUr': nameUr,
        'icon': icon,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };
}