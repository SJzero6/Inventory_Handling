class WarehouseModel {
  final int id;
  final int companyId;
  final int branchId;
  final String branchName;
  final String name;
  final String code;
  final String? address;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WarehouseModel({
    required this.id,
    required this.companyId,
    required this.branchId,
    required this.branchName,
    required this.name,
    required this.code,
    this.address,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['Id'] ?? 0,
      companyId: json['CompanyId'] ?? 0,
      branchId: json['BranchId'] ?? 0,
      branchName: json['BranchName'] ?? '',
      name: json['Name'] ?? '',
      code: json['Code'] ?? '',
      address: json['Address'],
      isActive: json['IsActive'] ?? false,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.tryParse(json['UpdatedAt'])
          : null,
    );
  }
}
