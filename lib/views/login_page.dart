import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthController authController = Get.find();

  String? emailError;
  String? passwordError;

  bool isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  bool validate() {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    bool hasError = false;

    if (!isValidEmail(email)) {
      emailError = "กรุณากรอกอีเมลให้ถูกต้อง เช่น name@example.com";
      hasError = true;
    }

    if (!isValidPassword(password)) {
      passwordError = "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร";
      hasError = true;
    }

    return hasError;
  }

  void validateAndLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (!validate()) {
      authController.login(email, password);
    } else {
      setState(() {});
    }
  }

  void validateAndRegister() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (!validate()) {
      authController.register(email, password);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("เข้าสู่ระบบ")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "อีเมล",
                errorText: emailError,
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "รหัสผ่าน",
                errorText: passwordError,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: validateAndLogin,
              child: Text("เข้าสู่ระบบ"),
            ),
            TextButton(
              onPressed: validateAndRegister,
              child: Text("ลงชื่อเข้าใช้งาน"),
            ),
          ],
        ),
      ),
    );
  }
}
