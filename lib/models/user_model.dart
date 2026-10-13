class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePic;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePic,
  });
}