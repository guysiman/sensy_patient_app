import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:url_launcher/url_launcher.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isBluetoothOn = false;

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
    _startScanning();
  }

  Future<void> _checkBluetoothState() async {
    bool isOn = await flutterBlue.isOn;
    setState(() {
      isBluetoothOn = isOn;
    });
  }

  Future<void> _startScanning() async {
    if (isBluetoothOn) {
      flutterBlue.startScan(timeout: Duration(seconds: 4));
    }
  }

  void _navigateToPairingScreen() {
    if (isBluetoothOn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PairingScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BluetoothOffScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _navigateToPairingScreen,
              child: Text('Pair Device'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startScanning,
              child: Text('Refresh Scan'),
            ),
          ],
        ),
      ),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({super.key});

  Future<void> _openBluetoothSettings() async {
    Uri url = Uri.parse('app-settings:bluetooth');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not open Bluetooth settings.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Off'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bluetooth is turned off',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Please enable Bluetooth to pair your device',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openBluetoothSettings,
              child: Text('Go to Bluetooth Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class PairingScreen extends StatelessWidget {
  const PairingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pairing Screen'),
      ),
      body: Center(
        child: Text('Pair your device here.'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BluetoothScreen(),
  ));
}