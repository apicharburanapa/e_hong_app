import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
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
  var isConnectResponseReceived = false.obs; // เพิ่มตัวแปรสำหรับตรวจสอบการตอบกลับ
  var canActivate = false.obs; // เพิ่มตัวแปรสำหรับควบคุมการเปิดใช้งานปุ่ม Activate

  StreamSubscription<Uint8List>? _dataSubscription;

  @override
  void onInit() {
    super.onInit();
    ensureBluetoothOnThenScan();
    autoReconnect();
  }

  @override
  void onClose() {
    _dataSubscription?.cancel();
    super.onClose();
  }

  Future<void> autoReconnect() async {
    String? lastAddress = await getLastConnectedDeviceAddress();

    if (lastAddress != null) {
      List<BluetoothDevice> bonded = await bluetoothService.getBondedDevices();

      final device = bonded.firstWhereOrNull((d) => d.address == lastAddress);
      if (device != null) {
        connectToDevice(device);
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

  // เพิ่มฟังก์ชันสำหรับฟังข้อมูลที่ส่งกลับมา
  void _startListeningForData() {
    if (bluetoothService.connection == null) return;

    _dataSubscription = bluetoothService.connection!.input!.listen(
      (Uint8List data) {
        _handleReceivedData(data);
      },
      onError: (error) {
        print("Error receiving data: $error");
      },
    );
  }

  // ฟังก์ชันสำหรับจัดการข้อมูลที่รับเข้ามา
  void _handleReceivedData(Uint8List data) {
    print("Received data: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");
    
    // ตรวจสอบว่าเป็นการตอบกลับจากคำสั่ง Connect หรือไม่
    if (data.length >= 4 && 
        data[0] == 0xA1 && 
        data[1] == 0x11 && 
        data[2] == 0xF1 && 
        data[3] == 0x01) { // 0x01 คือ response สำหรับ Connect command
      
      // ตรวจสอบ checksum ถ้าจำเป็น
      if (_validateChecksum(data)) {
        isConnectResponseReceived.value = true;
        canActivate.value = true;
        
        Get.snackbar(
          "เชื่อมต่อสำเร็จ",
          "✅ อุปกรณ์ตอบกลับแล้ว สามารถใช้งาน Activate ได้",
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // ฟังก์ชันตรวจสอบ checksum
  bool _validateChecksum(Uint8List data) {
    if (data.length < 64) return false;
    
    int sum = 0;
    for (int i = 0; i < 62; i++) {
      sum += data[i];
    }
    
    return (sum & 0xFF) == data[62] && data[63] == 0xE1;
  }

  void sendUnlockCommand() {
    bluetoothService.send("UNLOCK");
  }

  void sendCommand(int commandByte, {String? successMessage}) {
    if (bluetoothService.connection == null) {
      Get.snackbar("ยังไม่ได้เชื่อมต่อ", "กรุณาเชื่อมต่อกับอุปกรณ์ก่อน");
      return;
    }

    List<int> packet = List.filled(64, 0);

    // Header
    packet[0] = 0xA1;
    packet[1] = 0x11;
    packet[2] = 0xF1;

    // Command
    packet[3] = commandByte;

    // Checksum (sum of byte 0..61)
    int sum = 0;
    for (int i = 0; i < 62; i++) {
      sum += packet[i];
    }
    packet[62] = sum & 0xFF;

    // End byte
    packet[63] = 0xE1;

    bluetoothService.connection!.output.add(Uint8List.fromList(packet));
    bluetoothService.connection!.output.allSent.then((_) {
      print("Sent command: $commandByte");
      
      // แสดง snackbar เมื่อส่งเสร็จ
      if (successMessage != null) {
        Get.snackbar(
          "สำเร็จ", 
          successMessage,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }).catchError((error) {
      // แสดง error หากส่งไม่สำเร็จ
      Get.snackbar(
        "ผิดพลาด", 
        "ไม่สามารถส่งคำสั่งได้: $error",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  // แก้ไขฟังก์ชัน activateConnect เพื่อรีเซ็ตสถานะ
  void activateConnect() {
    isConnectResponseReceived.value = false;
    canActivate.value = false;
    sendCommand(0x01, successMessage: "🔌 ส่งคำสั่ง Activate Connect แล้ว กรุณารอการตอบกลับ...");
  }

  void activateNow() {
    if (!canActivate.value) {
      Get.snackbar(
        "ไม่สามารถใช้งานได้",
        "❌ กรุณากด Connect และรอการตอบกลับจากอุปกรณ์ก่อน",
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    sendCommand(0x02, successMessage: "⚡ ส่งคำสั่ง Activate Now แล้ว");
  }

  void disconnect() async {
    _dataSubscription?.cancel();
    startScan();
    await bluetoothService.disconnect();
    isConnected.value = false;
    selectedDevice.value = null;
    isConnectResponseReceived.value = false;
    canActivate.value = false;
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
      isConnectResponseReceived.value = false;
      canActivate.value = false;

      // เริ่มฟังข้อมูลที่ส่งกลับมา
      _startListeningForData();

      await saveLastConnectedDevice(device.address);
    } catch (e) {
      Get.snackbar("เชื่อมต่อไม่สำเร็จ", e.toString());
    } finally {
      isConnecting.value = false;
    }
  }
}