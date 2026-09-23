class BrandModel {
  final int id;
  final int companyId;
  final String name;
  final bool isActive;
  final DateTime? createdAt;

  BrandModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.isActive,
    this.createdAt,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['Id'] ?? 0,
      companyId: json['CompanyId'] ?? 0,
      name: json['Name'] ?? '',
      isActive: json['IsActive'] ?? false,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
    );
  }
}
