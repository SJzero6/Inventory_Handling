import 'branch_model.dart';
import 'company_model.dart';
import 'permission_model.dart';
import 'role_model.dart';
import 'user_model.dart';

class LoginResponse {
  final bool success;
  final String message;
  final String token;
  final UserModel user;
  final CompanyModel company;
  final BranchModel branch;
  final List<RoleModel> roles;
  final List<PermissionModel> permissions;

  LoginResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
    required this.company,
    required this.branch,
    required this.roles,
    required this.permissions,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      message: json['message'],
      token: json['token'],
      user: UserModel.fromJson(json['user']),
      company: CompanyModel.fromJson(json['company']),
      branch: BranchModel.fromJson(json['branch']),
      roles: (json['roles'] as List)
          .map((item) => RoleModel.fromJson(item))
          .toList(),
      permissions: (json['permissions'] as List)
          .map((item) => PermissionModel.fromJson(item))
          .toList(),
    );
  }
}
