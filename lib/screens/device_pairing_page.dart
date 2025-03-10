import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../providers/bluetooth_provider.dart';

class DevicePairingPage extends StatefulWidget {
  const DevicePairingPage({super.key});

  @override
  _DevicePairingPageState createState() => _DevicePairingPageState();
}

class _DevicePairingPageState extends State<DevicePairingPage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();
  bool isBluetoothOn = false;

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNavigate();
    });
  }

  Future<void> _checkBluetoothState() async {
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        isBluetoothOn = true;
      } else {
        isBluetoothOn = false;
      }
    });
  }

  void _checkAndNavigate() {
    final bluetoothProvider =
        Provider.of<BluetoothProvider>(context, listen: false);
    if (bluetoothProvider.IPG != null &&
        bluetoothProvider.EC != null &&
        bluetoothProvider.sensors != null) {
      Navigator.pushReplacementNamed(context, '/mainpage');
    }
  }

  void _navigateScreen(String deviceName) {
    if (isBluetoothOn) {
      Navigator.pushNamed(context, '/bluetoothpage', arguments: deviceName);
    } else {
      Navigator.pushNamed(context, '/bluetoothoffpage', arguments: deviceName);
    }
  }

  Widget device(String deviceName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(deviceName, style: Theme.of(context).textTheme.bodyLarge),
          OutlinedButton(
            onPressed: () {
              _navigateScreen(deviceName);
            },
            child: const Text('Pair'),
          ),
        ],
      ),
    );
  }

  Widget connectedDevice(String deviceName, BluetoothDevice device) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle, // Checkmark icon
                    color: Colors.green, // Green color
                    size: 24, // Adjust size as needed
                  ),
                  SizedBox(width: 12),
                  Text(deviceName,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  _navigateScreen(deviceName);
                },
                child: const Text('Pair another one'),
              ),
            ],
          ),
          SizedBox(height: 12),
          deviceInfo(deviceName, device)
        ],
      ),
    );
  }

  Widget deviceInfo(String deviceName, BluetoothDevice device) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFFEEF3F4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RichText(
                text: TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.normal),
              children: [
                TextSpan(
                  text: "$deviceName name: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: device.platformName),
              ],
            )),
            Divider(),
            RichText(
                text: TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.normal),
              children: [
                TextSpan(
                  text: "$deviceName info: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: device.toString()),
              ],
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    BluetoothDevice? IPG = context.watch<BluetoothProvider>().IPG;
    BluetoothDevice? EC = context.watch<BluetoothProvider>().EC;
    BluetoothDevice? sensors = context.watch<BluetoothProvider>().sensors;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text('Pairing',
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                      IPG != null ? connectedDevice('IPG', IPG) : device('IPG'),
                      EC != null
                          ? connectedDevice('EC', EC)
                          : device('External controller'),
                      sensors != null
                          ? connectedDevice('Sensors', sensors)
                          : device('External sensors'),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/homepage');
                    },
                    child: const Text('Go to the Home Screen'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
