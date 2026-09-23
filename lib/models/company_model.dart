class CompanyModel {
  final int id;
  final String name;

  CompanyModel({required this.id, required this.name});

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(id: json['id'], name: json['name']);
  }
}
