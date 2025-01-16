class UserModel {
  final String id;
  final String name;
  final String surname;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'email': email,
    };
  }
}