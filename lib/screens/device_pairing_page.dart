import 'package:flutter/material.dart';

class DevicePairingPage extends StatefulWidget {
  const DevicePairingPage({super.key});

  @override
  _DevicePairingPageState createState() => _DevicePairingPageState();
}

class _DevicePairingPageState extends State<DevicePairingPage> {
  Widget device(deviceName) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(deviceName),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Pair'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Pairing'),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  device('IPG'),
                  device('External controller'),
                  device('External sensors')
                ]),
          ),
        ],
      ),
    );
  }
}
