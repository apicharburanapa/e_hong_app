class UserModel {
  final String uid;
  final String email;
  // final String? name;
  // final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.email,
    // this.name,
    // this.profileImageUrl,
  });

  // แปลงจาก Firestore document -> UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      // name: map['name'],
      // profileImageUrl: map['profileImageUrl'],
    );
  }

  // แปลงกลับเป็น Map สำหรับบันทึกเข้า Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      // 'name': name,
      // 'profileImageUrl': profileImageUrl,
    };
  }
}
