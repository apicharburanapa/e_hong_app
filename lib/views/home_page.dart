import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/bluetooth_controller.dart';
import '../widgets/device_tile.dart';

class HomePage extends StatelessWidget {
  final AuthController authController = Get.find();
  final BluetoothController btController = Get.find<BluetoothController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth เชื่อมต่อ"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: btController.startScan,
          ),
        ],
      ),
      body: Obx(() {
  if (btController.isConnecting.value) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("🔄 กำลังเชื่อมต่ออุปกรณ์ล่าสุด..."),
        ],
      ),
    );
  }

  if (btController.isConnected.value) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("✅ เชื่อมต่อกับ: ${btController.selectedDevice.value?.name}"),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: btController.sendUnlockCommand,
            child: Text("🔓 ปลดล็อก"),
          ),
          TextButton(
            onPressed: btController.disconnect,
            child: Text("ตัดการเชื่อมต่อ"),
          ),
        ],
      ),
    );
  } else {
    return ListView.builder(
      itemCount: btController.devices.length,
      itemBuilder: (context, index) {
        final device = btController.devices[index];
        return DeviceTile(
          device: device,
          onTap: () => btController.connectToDevice(device),
        );
      },
    );
  }
})

      // body: Obx(() {
      //   if (btController.isConnecting.value) {
      //     return Center(child: CircularProgressIndicator());
      //   }

      //   if (btController.isConnected.value) {
      //     return Center(
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Text(
      //             "✅ เชื่อมต่อกับ: ${btController.selectedDevice.value?.name}",
      //           ),
      //           SizedBox(height: 20),
      //           ElevatedButton(
      //             onPressed: btController.sendUnlockCommand,
      //             child: Text("🔓 ปลดล็อก"),
      //           ),
      //           TextButton(
      //             onPressed: btController.disconnect,
      //             child: Text("ตัดการเชื่อมต่อ"),
      //           ),
      //         ],
      //       ),
      //     );
      //   } else {
      //     return Column(
      //       children: [
      //         ElevatedButton(
      //           onPressed: btController.startScan,
      //           child: Text("🔍 สแกนอุปกรณ์"),
      //         ),
      //         Expanded(
      //           child: ListView.builder(
      //             itemCount: btController.devices.length,
      //             itemBuilder: (context, index) {
      //               final device = btController.devices[index];
      //               return ListTile(
      //                 title: Text(device.name ?? "No name"),
      //                 subtitle: Text(device.address),
      //                 onTap: () => btController.connectToDevice(device),
      //               );
      //             },
      //           ),
      //         ),
      //       ],
      //     );
      //   }
      // }),
    );
  }
}
