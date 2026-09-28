class WarehouseLocationModel {
  final int id;
  final int warehouseId;
  final String warehouseName;
  final String warehouseCode;
  final String name;
  final String code;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  WarehouseLocationModel({
    required this.id,
    required this.warehouseId,
    required this.warehouseName,
    required this.warehouseCode,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
    this.createdAt,
  });

  factory WarehouseLocationModel.fromJson(Map<String, dynamic> json) {
    return WarehouseLocationModel(
      id: json['Id'] ?? 0,
      warehouseId: json['WarehouseId'] ?? 0,
      warehouseName: json['WarehouseName'] ?? '',
      warehouseCode: json['WarehouseCode'] ?? '',
      name: json['Name'] ?? '',
      code: json['Code'] ?? '',
      description: json['Description'],
      isActive: json['IsActive'] ?? false,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
    );
  }
}
