import 'package:e_hong_app/model/profile.dart';
import 'package:e_hong_app/screen/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  Profile profile = Profile(); // email = '', password = ''
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("Error")),
            body: Center(child: Text("${snapshot.error}")),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "เข้าสู่ระบบ",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 230, 66, 55),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ---- อีเมล ----
                      const Text("อีเมล", style: TextStyle(fontSize: 20)),
                      TextFormField(
                        initialValue: profile.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: MultiValidator([
                          RequiredValidator(
                            errorText: "กรุณาป้อนอีเมลด้วยครับ",
                          ),
                          EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง"),
                        ]),

                        // ---- แก้ไขต่างจาก kongruk ----
                        onSaved: (value) => profile.email = value ?? '',
                      ),

                      const SizedBox(height: 15),

                      // ---- รหัสผ่าน ----
                      const Text("รหัสผ่าน", style: TextStyle(fontSize: 20)),
                      TextFormField(
                        initialValue: profile.password,
                        obscureText: true,
                        validator: RequiredValidator(
                          errorText: "กรุณาป้อนรหัสผ่านด้วยครับ",
                        ),

                        // ---- แก้ไขต่างจาก kongruk ----
                        onSaved: (value) => profile.password = value ?? '',
                      ),

                      const SizedBox(height: 30),

                      // ---- ปุ่มเข้าระบบ ----
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: const Text(
                            "ลงชื่อเข้าใช้",
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () async {
                            // ตรวจ validate
                            if (formKey.currentState!.validate()) {
                              // save ค่าจาก onSaved
                              formKey.currentState!.save();
                              try {
                                // ใช้งาน profile.email และ profile.password
                                // เพื่อ login
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                      email: profile.email,
                                      password: profile.password,
                                    )
                                    .then((value) {
                                      formKey.currentState!.reset();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return WelcomeScreen();
                                          },
                                        ),
                                      );
                                    });

                                //ตรวจสอบเงื่อไข Auth เมลซ้ำและรหัสไม่ถึง 6 ตัว
                              } on FirebaseAuthException catch (e) {
                                Fluttertoast.showToast(
                                  msg: e.message.toString(),
                                  gravity: ToastGravity.CENTER,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
