import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bluetooth_service.dart';

class BluetoothController extends GetxController {
  final bluetoothService = BluetoothService();

  var devices = <BluetoothDevice>[].obs;
  var selectedDevice = Rxn<BluetoothDevice>();
  var isConnecting = false.obs;
  var isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    ensureBluetoothOnThenScan();
    autoReconnect();
  }

  Future<void> autoReconnect() async {
    String? lastAddress = await getLastConnectedDeviceAddress();

    if (lastAddress != null) {
      List<BluetoothDevice> bonded = await bluetoothService.getBondedDevices();

      final device = bonded.firstWhereOrNull((d) => d.address == lastAddress);
      if (device != null) {
        connectToDevice(device); // 🔁 auto connect
      }
    }
  }

  Future<void> ensureBluetoothOnThenScan() async {
    await requestPermissions(); // สำคัญมาก!

    bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;

    if (isEnabled == null || !isEnabled) {
      try {
        await FlutterBluetoothSerial.instance.requestEnable();
      } catch (e) {
        Get.snackbar("Error", "ไม่สามารถเปิด Bluetooth ได้: $e");
        return;
      }
    }

    startScan();
  }

  void startScan() async {
    isConnecting.value = true;
    devices.clear();
    await requestPermissions();

    bool? isOn = await FlutterBluetoothSerial.instance.isEnabled;
    if (!isOn!) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }

    final seenAddresses = <String>{};

    final StreamSubscription<BluetoothDiscoveryResult> subscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
          if (!seenAddresses.contains(r.device.address)) {
            seenAddresses.add(r.device.address);
            devices.add(r.device);
          }
        });

    // หยุดการสแกนหลังจาก 5 วินาที
    Future.delayed(Duration(seconds: 5), () async {
      await subscription.cancel();
      isConnecting.value = false;
    });
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses.values.any((status) => !status.isGranted)) {
      Get.snackbar("Permission", "โปรดอนุญาตการเข้าถึง Bluetooth และ Location");
      return;
    }
  }

  void sendUnlockCommand() {
    bluetoothService.send("UNLOCK");
  }

  void disconnect() async {
    await bluetoothService.disconnect();
    isConnected.value = false;
    selectedDevice.value = null;
  }

  Future<void> saveLastConnectedDevice(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_device', address);
  }

  Future<String?> getLastConnectedDeviceAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_device');
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      isConnecting.value = true;
      await bluetoothService.connect(device);
      selectedDevice.value = device;
      isConnected.value = true;

      await saveLastConnectedDevice(device.address);
    } catch (e) {
      Get.snackbar("เชื่อมต่อไม่สำเร็จ", e.toString());
    } finally {
      isConnecting.value = false;
    }
  }
}
