import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> user;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    user = Rx<User?>(auth.currentUser);
    user.bindStream(auth.userChanges());
    ever(user, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) {
    if (user == null) {
      Get.offAll(() => LoginPage());
    } else {
      Get.offAll(() => HomePage());
    }
  }

  void register(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void logout() async {
    await auth.signOut();
  }
}
