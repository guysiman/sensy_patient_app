import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DevicePairingPage extends StatefulWidget {
  const DevicePairingPage({super.key});

  @override
  _DevicePairingPageState createState() => _DevicePairingPageState();
}

class _DevicePairingPageState extends State<DevicePairingPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isBluetoothOn = false;

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
  }

  Future<void> _checkBluetoothState() async {
    bool isOn = await flutterBlue.isOn;
    setState(() {
      isBluetoothOn = isOn;
    });
  }

  void _navigateScreen(String deviceName) {
    if (isBluetoothOn) {
      Navigator.pushNamed(context, '/bluetoothpage', arguments: deviceName);
    } else {
      // TODO : change this to bluetooth off page, but for testing purposes
      Navigator.pushNamed(context, '/bluetoothpage', arguments: deviceName);
    }
  }

  Widget device(deviceName) {
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
                      device('External sensors')
                    ]),
              ),
              SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/homepage');
                    },
                    child: Text(
                      'Go to the Home Screen',
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
