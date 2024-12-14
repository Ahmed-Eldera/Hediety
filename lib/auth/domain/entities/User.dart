class MyUser {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  MyUser({required String this.id,required String this.name,this.phone='',this.email=''});
}