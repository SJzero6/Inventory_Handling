class UnitModel {
  final int id;
  final int companyId;
  final String name;
  final String? shortName;
  final bool isActive;
  final DateTime? createdAt;

  UnitModel({
    required this.id,
    required this.companyId,
    required this.name,
    this.shortName,
    required this.isActive,
    this.createdAt,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['Id'] ?? 0,
      companyId: json['CompanyId'] ?? 0,
      name: json['Name'] ?? '',
      shortName: json['ShortName'],
      isActive: json['IsActive'] ?? false,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
    );
  }
}
