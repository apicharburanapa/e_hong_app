import 'package:get/get.dart';
import '../views/home_page.dart';
import '../views/login_page.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _firebaseService = FirebaseService();
  Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onReady() async {
    super.onReady();
    final user = _firebaseService.currentUser;
    if (user != null) {
      currentUser.value = await _firebaseService.getUserData(user.uid);
       Get.offAllNamed('/home');
    } else {
      Get.offAll(() => LoginPage());
    }
  }

  Future<void> register(String email, String password) async {
    try {
      final user = await _firebaseService.registerWithEmail(email, password);
      if (user != null) {
        final userModel = UserModel(uid: user.uid, email: user.email ?? '');
        await _firebaseService.saveUserData(userModel);
        currentUser.value = userModel;
          Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar("สมัครสมาชิกล้มเหลว", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final user = await _firebaseService.loginWithEmail(email, password);
      if (user != null) {
        final userModel = await _firebaseService.getUserData(user.uid);
        currentUser.value = userModel;
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar("เข้าสู่ระบบล้มเหลว", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    await _firebaseService.logout();
    currentUser.value = null;
    Get.offAll(() => LoginPage());
  }
}
