class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? city;
  final String? profilePic;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.city,
    this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'profilePic': profilePic,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      city: map['city'],
      profilePic: map['profilePic'],
    );
  }
}
