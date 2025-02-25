import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
  }

  Future<void> _checkBluetoothState() async {
    var subscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        isBluetoothOn = true;
      } else {
        isBluetoothOn = false;
      }
    });
  }

  void _navigateScreen(String deviceName) {
    if (isBluetoothOn) {
      Navigator.pushNamed(context, '/bluetoothpage', arguments: deviceName);
    } else {
      // TODO: change this to a Bluetooth off page; for testing, we're navigating to the same page.
      Navigator.pushNamed(context, '/bluetoothpage', arguments: deviceName);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                    device('IPG'),
                    device('External controller'),
                    device('External sensors'),
                  ],
                ),
              ),
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
    );
  }
}
