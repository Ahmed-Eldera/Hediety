class MyUser {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  String? pic;
  MyUser({required String this.id,required String this.name,this.phone='',this.email='',this.pic = ''});
  MyUser copyWith({
    String? name,
    String? phone,
    // String? password,
    String? pic,
  }) {
    return MyUser(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      // password: password ?? this.password,
      pic: pic ?? this.pic,
    );
  }
}