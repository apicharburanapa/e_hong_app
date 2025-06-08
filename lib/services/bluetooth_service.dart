import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await _bluetooth.getBondedDevices();
  }

  Future<void> connect(BluetoothDevice device) async {
    connection = await BluetoothConnection.toAddress(device.address);
  }

  void send(String message) {
    connection?.output.add(Uint8List.fromList(message.codeUnits));
    connection?.output.allSent;
  }

  Future<void> disconnect() async {
    await connection?.close();
    connection = null;
  }

  bool get isConnected => connection?.isConnected ?? false;
}
