import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class HomePage extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authController.logout(),
          )
        ],
      ),
      body: Center(child: Text("Logged In!")),
    );
  }
}
