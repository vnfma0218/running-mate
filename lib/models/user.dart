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

class JoinUserModel {
  JoinUserModel({required this.id, required this.name, required this.imageUrl});
  final String id;
  final String name;
  final String imageUrl;

  JoinUserModel.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        id = json['id'] as String,
        imageUrl = json['imageUrl'] as String;

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'imageUrl': imageUrl,
      };
}
