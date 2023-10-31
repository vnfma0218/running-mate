class UserModel {
  UserModel(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.email});

  final String id;
  final String name;
  final String? imageUrl;
  final String email;
}
