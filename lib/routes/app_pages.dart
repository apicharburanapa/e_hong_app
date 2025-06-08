import 'package:get/get.dart';

import '../bindings/auth_binding.dart';
import '../bindings/bluetooth_binding.dart';
import '../views/home_page.dart';
import '../views/login_page.dart';

class AppPages {
  static const INITIAL = '/login';

  static final routes = [
    GetPage(
      name: '/login',
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/home',
      page: () => HomePage(),
      binding: BluetoothBinding(),
    ),
  
  ];
}
