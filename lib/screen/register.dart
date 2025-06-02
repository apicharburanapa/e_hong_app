import 'package:e_hong_app/model/profile.dart';
import 'package:e_hong_app/screen/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                "สร้างบัญชีผู้ใช้",
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

                      // ---- ปุ่มลงทะเบียน ----
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: const Text(
                            "ลงทะเบียน",
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () async {
                            // ตรวจ validate
                            if (formKey.currentState!.validate()) {
                              // save ค่าจาก onSaved
                              formKey.currentState!.save();
                              try {
                                // ใช้งาน profile.email และ profile.password ได้ที่นี่
                                // เพื่อสร้าง account
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                      email: profile.email,
                                      password: profile.password,
                                    )
                                    .then((value) {
                                      Fluttertoast.showToast(
                                        // แก้โดยเพิ่ม toString
                                        msg: "สร้างบัญชีผู้ใช้เรียบร้อยแล้ว",
                                        gravity: ToastGravity.TOP,
                                      );

                                      formKey.currentState!.reset();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return HomeScreen();
                                          },
                                        ),
                                      );
                                    });

                                //ตรวจสอบเงื่อไข Auth เมลซ้ำและรหัสไม่ถึง 6 ตัว
                              } on FirebaseAuthException catch (e) {
                                String errorMessage;
                                switch (e.code) {
                                  case 'email-already-in-use':
                                    errorMessage = 'อีเมลนี้มีอยู่ในระบบแล้ว';
                                    break;
                                  case 'weak-password':
                                    errorMessage =
                                        'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                                    break;
                                  default:
                                    // ข้อความ fallback กรณีโค้ดอื่นๆ
                                    errorMessage =
                                        e.message ??
                                        'เกิดข้อผิดพลาด ไม่ทราบสาเหตุ';
                                }

                                Fluttertoast.showToast(
                                  msg: errorMessage,
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
