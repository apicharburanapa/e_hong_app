import 'package:e_hong_app/screen/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final email = user?.email ?? 'ไม่พบอีเมล';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ยินดีต้อนรับ",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 230, 66, 55),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // รูปตำแหน่งเหนือชื่ออีเมล
              Image.asset(
                'assets/images/doctor.png',
                width: 240,
                height: 240,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),

              // แสดงอีเมล
              Text(
                email,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              // ปุ่มปลดล็อค Doctor ปรับขนาดและตัวหนังสือ
              ElevatedButton(
                onPressed: () {
                  // TODO: เขียนโค้ดปลดล็อค Doctor ที่นี่
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("ปลดล็อค Dr.Sm."),
              ),

              const SizedBox(height: 16),

              // ปุ่มออกจากระบบ
              ElevatedButton(
                onPressed: () {
                  _auth.signOut().then((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("ออกจากระบบ"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
