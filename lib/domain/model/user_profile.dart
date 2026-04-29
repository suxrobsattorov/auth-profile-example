import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String phone;
  final String? email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? avatar;
  final String country;
  final List<String> authMethods;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  const UserProfile({
    required this.id,
    required this.phone,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.avatar,
    required this.country,
    required this.authMethods,
    required this.createdAt,
    required this.lastLogin,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: _nullableString(json['email']),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      avatar: _nullableString(json['avatar']),
      country: json['country']?.toString() ?? '',
      authMethods: (json['auth_methods'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      createdAt: _parseDate(json['created_at']),
      lastLogin: _parseDate(json['last_login']),
    );
  }

  String get resolvedFullName {
    final full = fullName.trim();
    if (full.isNotEmpty) return full;

    final fallback = [firstName.trim(), lastName.trim()]
        .where((value) => value.isNotEmpty)
        .join(' ');
    return fallback;
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static DateTime? _parseDate(dynamic value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw);
  }

  @override
  List<Object?> get props => [
        id,
        phone,
        email,
        firstName,
        lastName,
        fullName,
        avatar,
        country,
        authMethods,
        createdAt,
        lastLogin,
      ];
}
