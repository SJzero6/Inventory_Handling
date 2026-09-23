class ProductModel {
  final int id;
  final int companyId;
  final int? categoryId;
  final String? categoryName;
  final int? brandId;
  final String? brandName;
  final int? unitId;
  final String? unitName;
  final String productCode;
  final String? barcode;
  final String name;
  final String? description;
  final num purchasePrice;
  final num sellingPrice;
  final num taxPercent;
  final num minimumStock;
  final bool hasBatch;
  final bool hasExpiry;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.companyId,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.unitId,
    this.unitName,
    required this.productCode,
    this.barcode,
    required this.name,
    this.description,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.taxPercent,
    required this.minimumStock,
    required this.hasBatch,
    required this.hasExpiry,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['Id'] ?? 0,
      companyId: json['CompanyId'] ?? 0,
      categoryId: json['CategoryId'],
      categoryName: json['CategoryName'],
      brandId: json['BrandId'],
      brandName: json['BrandName'],
      unitId: json['UnitId'],
      unitName: json['UnitName'],
      productCode: json['ProductCode'] ?? '',
      barcode: json['Barcode'],
      name: json['Name'] ?? '',
      description: json['Description'],
      purchasePrice: json['PurchasePrice'] ?? 0,
      sellingPrice: json['SellingPrice'] ?? 0,
      taxPercent: json['TaxPercent'] ?? 0,
      minimumStock: json['MinimumStock'] ?? 0,
      hasBatch: json['HasBatch'] ?? false,
      hasExpiry: json['HasExpiry'] ?? false,
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
