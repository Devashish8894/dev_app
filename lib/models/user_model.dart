class UserModel {
  final int id;
  final String email;
  final String role;
  final String roleName;
  final bool requirePasswordChange;
  final int tenantId;
  final String tenantName;
  final String tenantSubdomain;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.roleName,
    required this.requirePasswordChange,
    required this.tenantId,
    required this.tenantName,
    required this.tenantSubdomain,
  });

  bool get isAdmin =>
      role == 'admin' ||
      role == 'org_admin' ||
      role == 'super_admin' ||
      role == 'superadmin' ||
      role == 'hr_admin' ||
      role == 'hr_manager' ||
      role == 'hr';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] as Map<String, dynamic>? ?? {};
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      email: json['email']?.toString() ?? '',
      role: (json['role']?.toString() ?? 'employee').toLowerCase(),
      roleName: json['roleName']?.toString() ?? json['role_name']?.toString() ?? 'Employee',
      requirePasswordChange: json['requirePasswordChange'] == true,
      tenantId: tenant['id'] is int ? tenant['id'] : int.tryParse(tenant['id']?.toString() ?? '1') ?? 1,
      tenantName: tenant['name']?.toString() ?? 'Ramel Techno Solutions',
      tenantSubdomain: tenant['subdomain']?.toString() ?? 'ramel',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'roleName': roleName,
      'requirePasswordChange': requirePasswordChange,
      'tenant': {
        'id': tenantId,
        'name': tenantName,
        'subdomain': tenantSubdomain,
      }
    };
  }
}
