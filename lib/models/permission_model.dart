class PermissionModel {
  final int id;
  final String code;
  final String name;
  final String module;

  PermissionModel({
    required this.id,
    required this.code,
    required this.name,
    required this.module,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['Id'],
      code: json['Code'],
      name: json['Name'],
      module: json['Module'],
    );
  }
}
