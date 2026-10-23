import 'user_model.dart';

class SignUpModel {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? city;
  final DateTime createdAt;

  SignUpModel({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.city,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'city': city,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SignUpModel.fromMap(Map<String, dynamic> map) {
    return SignUpModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'],
      city: map['city'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
    );
  }

  UserModel toUserModel({String? id}) {
    return UserModel(
      id: id ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      city: city,
    );
  }
}

