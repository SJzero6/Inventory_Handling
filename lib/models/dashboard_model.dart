class DashboardModel {
  final DashboardSummary summary;
  final List<LowStockProduct> lowStockProducts;
  final List<RecentTransaction> recentTransactions;
  final List<RecentPurchaseOrder> recentPurchaseOrders;
  final List<RecentGoodsReceipt> recentGoodsReceipts;

  DashboardModel({
    required this.summary,
    required this.lowStockProducts,
    required this.recentTransactions,
    required this.recentPurchaseOrders,
    required this.recentGoodsReceipts,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      summary: DashboardSummary.fromJson(json['summary']),
      lowStockProducts: (json['lowStockProducts'] as List? ?? [])
          .map((e) => LowStockProduct.fromJson(e))
          .toList(),
      recentTransactions: (json['recentTransactions'] as List? ?? [])
          .map((e) => RecentTransaction.fromJson(e))
          .toList(),
      recentPurchaseOrders: (json['recentPurchaseOrders'] as List? ?? [])
          .map((e) => RecentPurchaseOrder.fromJson(e))
          .toList(),
      recentGoodsReceipts: (json['recentGoodsReceipts'] as List? ?? [])
          .map((e) => RecentGoodsReceipt.fromJson(e))
          .toList(),
    );
  }
}

class DashboardSummary {
  final ProductSummary products;
  final int suppliers;
  final int warehouses;
  final int branches;
  final StockSummary stock;
  final PurchaseSummary purchases;
  final ReceivingSummary receiving;

  DashboardSummary({
    required this.products,
    required this.suppliers,
    required this.warehouses,
    required this.branches,
    required this.stock,
    required this.purchases,
    required this.receiving,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      products: ProductSummary.fromJson(json['products']),
      suppliers: json['suppliers'] ?? 0,
      warehouses: json['warehouses'] ?? 0,
      branches: json['branches'] ?? 0,
      stock: StockSummary.fromJson(json['stock']),
      purchases: PurchaseSummary.fromJson(json['purchases']),
      receiving: ReceivingSummary.fromJson(json['receiving']),
    );
  }
}

class ProductSummary {
  final int total;
  final int active;

  ProductSummary({required this.total, required this.active});

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
    );
  }
}

class StockSummary {
  final int itemCount;
  final num totalQuantity;
  final num totalValue;

  StockSummary({
    required this.itemCount,
    required this.totalQuantity,
    required this.totalValue,
  });

  factory StockSummary.fromJson(Map<String, dynamic> json) {
    return StockSummary(
      itemCount: json['itemCount'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
      totalValue: json['totalValue'] ?? 0,
    );
  }
}

class PurchaseSummary {
  final int total;
  final int draft;
  final int approved;
  final int partiallyReceived;
  final int fullyReceived;

  PurchaseSummary({
    required this.total,
    required this.draft,
    required this.approved,
    required this.partiallyReceived,
    required this.fullyReceived,
  });

  factory PurchaseSummary.fromJson(Map<String, dynamic> json) {
    return PurchaseSummary(
      total: json['total'] ?? 0,
      draft: json['draft'] ?? 0,
      approved: json['approved'] ?? 0,
      partiallyReceived: json['partiallyReceived'] ?? 0,
      fullyReceived: json['fullyReceived'] ?? 0,
    );
  }
}

class ReceivingSummary {
  final int total;
  final int received;
  final int approved;
  final int cancelled;

  ReceivingSummary({
    required this.total,
    required this.received,
    required this.approved,
    required this.cancelled,
  });

  factory ReceivingSummary.fromJson(Map<String, dynamic> json) {
    return ReceivingSummary(
      total: json['total'] ?? 0,
      received: json['received'] ?? 0,
      approved: json['approved'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }
}

class LowStockProduct {
  final int? productId;
  final String? productCode;
  final String? productName;
  final num? quantity;

  LowStockProduct({
    this.productId,
    this.productCode,
    this.productName,
    this.quantity,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      productId: json['ProductId'],
      productCode: json['ProductCode'],
      productName: json['ProductName'],
      quantity: json['Quantity'],
    );
  }
}

class RecentTransaction {
  final String id;
  final String productCode;
  final String productName;
  final String warehouseName;
  final String? batchNumber;
  final String transactionType;
  final String referenceType;
  final String referenceId;
  final num quantity;
  final num unitCost;
  final DateTime? transactionDate;
  final String createdByName;
  final String? notes;

  RecentTransaction({
    required this.id,
    required this.productCode,
    required this.productName,
    required this.warehouseName,
    this.batchNumber,
    required this.transactionType,
    required this.referenceType,
    required this.referenceId,
    required this.quantity,
    required this.unitCost,
    this.transactionDate,
    required this.createdByName,
    this.notes,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      id: json['Id']?.toString() ?? '',
      productCode: json['ProductCode'] ?? '',
      productName: json['ProductName'] ?? '',
      warehouseName: json['WarehouseName'] ?? '',
      batchNumber: json['BatchNumber'],
      transactionType: json['TransactionType'] ?? '',
      referenceType: json['ReferenceType'] ?? '',
      referenceId: json['ReferenceId']?.toString() ?? '',
      quantity: json['Quantity'] ?? 0,
      unitCost: json['UnitCost'] ?? 0,
      transactionDate: json['TransactionDate'] != null
          ? DateTime.tryParse(json['TransactionDate'])
          : null,
      createdByName: json['CreatedByName'] ?? '',
      notes: json['Notes'],
    );
  }
}

class RecentPurchaseOrder {
  final String id;
  final String purchaseOrderNumber;
  final DateTime? orderDate;
  final String status;
  final String supplierName;
  final String warehouseName;
  final num totalAmount;
  final DateTime? createdAt;

  RecentPurchaseOrder({
    required this.id,
    required this.purchaseOrderNumber,
    this.orderDate,
    required this.status,
    required this.supplierName,
    required this.warehouseName,
    required this.totalAmount,
    this.createdAt,
  });

  factory RecentPurchaseOrder.fromJson(Map<String, dynamic> json) {
    return RecentPurchaseOrder(
      id: json['Id']?.toString() ?? '',
      purchaseOrderNumber: json['PurchaseOrderNumber'] ?? '',
      orderDate: json['OrderDate'] != null
          ? DateTime.tryParse(json['OrderDate'])
          : null,
      status: json['Status'] ?? '',
      supplierName: json['SupplierName'] ?? '',
      warehouseName: json['WarehouseName'] ?? '',
      totalAmount: json['TotalAmount'] ?? 0,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
    );
  }
}

class RecentGoodsReceipt {
  final String id;
  final String receiptNumber;
  final DateTime? receiptDate;
  final String status;
  final String supplierName;
  final String warehouseName;
  final String purchaseOrderNumber;
  final DateTime? createdAt;

  RecentGoodsReceipt({
    required this.id,
    required this.receiptNumber,
    this.receiptDate,
    required this.status,
    required this.supplierName,
    required this.warehouseName,
    required this.purchaseOrderNumber,
    this.createdAt,
  });

  factory RecentGoodsReceipt.fromJson(Map<String, dynamic> json) {
    return RecentGoodsReceipt(
      id: json['Id']?.toString() ?? '',
      receiptNumber: json['ReceiptNumber'] ?? '',
      receiptDate: json['ReceiptDate'] != null
          ? DateTime.tryParse(json['ReceiptDate'])
          : null,
      status: json['Status'] ?? '',
      supplierName: json['SupplierName'] ?? '',
      warehouseName: json['WarehouseName'] ?? '',
      purchaseOrderNumber: json['PurchaseOrderNumber'] ?? '',
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
    );
  }
}
