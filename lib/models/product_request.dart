class ProductRequest {
  final int? categoryId;
  final int? brandId;
  final int unitId;
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

  ProductRequest({
    this.categoryId,
    this.brandId,
    required this.unitId,
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
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'brandId': brandId,
      'unitId': unitId,
      'productCode': productCode,
      'barcode': barcode,
      'name': name,
      'description': description,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'taxPercent': taxPercent,
      'minimumStock': minimumStock,
      'hasBatch': hasBatch,
      'hasExpiry': hasExpiry,
    };
  }
}
