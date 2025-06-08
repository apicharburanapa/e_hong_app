import 'package:get/get.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
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
    if (isOn == null || !isOn) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }

    FlutterBluetoothSerial.instance.startDiscovery().listen(
      (r) {
        if (devices.every((d) => d.address != r.device.address)) {
          devices.add(r.device);
        }
      },
      onError: (e) {
        print("เกิดข้อผิดพลาดระหว่างสแกน: $e");
        isConnecting.value = false;
      },
      onDone: () {
        isConnecting.value = false;
        print("สแกนเสร็จแล้ว");
      },
      cancelOnError: true,
    );
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

  void connectToDevice(BluetoothDevice device) async {
    try {
      isConnecting.value = true;
      await bluetoothService.connect(device);
      selectedDevice.value = device;
      isConnected.value = true;
    } catch (e) {
      Get.snackbar("เชื่อมต่อไม่สำเร็จ", e.toString());
    } finally {
      isConnecting.value = false;
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
}
