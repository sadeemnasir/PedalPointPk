enum UserRole { customer, business }

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? cnic;
  final UserRole role;
  final String? businessName;
  final String? cityHub;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.cnic,
    required this.role,
    this.businessName,
    this.cityHub,
  });

  bool get isBusiness => role == UserRole.business;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Rider',
      phone: json['phone'] as String?,
      cnic: json['cnic'] as String?,
      role: json['role'] == 'business' ? UserRole.business : UserRole.customer,
      businessName: json['business_name'] as String?,
      cityHub: json['city_hub'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'cnic': cnic,
        'role': role.name,
        'business_name': businessName,
        'city_hub': cityHub,
      };
}
