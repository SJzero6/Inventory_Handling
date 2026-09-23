class CategoryModel {
  final int id;
  final int companyId;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  CategoryModel({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['Id'] ?? 0,
      companyId: json['CompanyId'] ?? 0,
      name: json['Name'] ?? '',
      description: json['Description'],
      isActive: json['IsActive'] ?? false,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
    );
  }
}
