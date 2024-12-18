class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
    final String? pic;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
        this.pic,
  });

  // Convert UserModel to domain MyUser
  // MyUser toEntity() {
  //   return MyUser(
  //     id: id,
  //     name: name,
  //   );
  // }

  // Factory constructor to create UserModel from JSON (if needed)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      phone: json['phone'],
    );
  }

  // Convert UserModel to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
    };
  }
}
