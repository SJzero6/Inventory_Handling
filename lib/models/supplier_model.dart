class SupplierModel {
  final int id;
  final int companyId;
  final String supplierCode;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxNumber;
  final String? paymentTerms;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SupplierModel({
    required this.id,
    required this.companyId,
    required this.supplierCode,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.taxNumber,
    this.paymentTerms,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['Id'] ?? 0,
      companyId: json['CompanyId'] ?? 0,
      supplierCode: json['SupplierCode'] ?? '',
      name: json['Name'] ?? '',
      contactPerson: json['ContactPerson'],
      phone: json['Phone'],
      email: json['Email'],
      address: json['Address'],
      taxNumber: json['TaxNumber'],
      paymentTerms: json['PaymentTerms'],
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
