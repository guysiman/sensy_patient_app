import 'package:flutter/material.dart';

class GenericDevicePairingPage extends StatefulWidget {
  const GenericDevicePairingPage({super.key});

  @override
  State<GenericDevicePairingPage> createState() =>
      _GenericDevicePairingPageState();
}

class _GenericDevicePairingPageState extends State<GenericDevicePairingPage> {
  @override
  Widget build(BuildContext context) {
    String deviceName = "deviceName";
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      deviceName = args;
    }
    return Scaffold(appBar: AppBar(), body: Text(deviceName));
  }
}
