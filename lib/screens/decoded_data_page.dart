import 'dart:typed_data';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';

class DecodedDataScreen extends StatefulWidget {
  const DecodedDataScreen({super.key});

  @override
  State<DecodedDataScreen> createState() => _DecodedDataScreenState();
}

class _DecodedDataScreenState extends State<DecodedDataScreen> {
  String _decodedResult = '';
  StreamSubscription<List<int>>? _notificationSubscription;
  final List<int> _buffer = [];
  StringBuffer _bufferedString = StringBuffer();


  @override
  void initState() {
    super.initState();
    final device = context.read<BluetoothProvider>().EC;
    if (device != null) {
      _readLiveData(device);
      _startListening(device);
    } else {
      setState(() {
        _decodedResult = '⚠️ No device connected.';
      });
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _startListening(BluetoothDevice device) async {
    try {
      // Request a higher MTU on Android to accommodate larger data packets
      if (Platform.isAndroid) {
        await device.requestMtu(512);
      }

      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);

            _notificationSubscription = characteristic.value.listen((value) {
              _onDataReceived(value);
            });

            print("✅ Subscribed to notifications on ${characteristic.uuid}");
            return;
          }
        }
      }

      print("⚠️ No notifiable characteristic found.");
    } catch (e) {
      print("❌ Error setting up Bluetooth listener: $e");
      setState(() {
        _decodedResult = '❌ Failed to start listening: $e';
      });
    }
  }

  Future<void> _readLiveData(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
        in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            characteristic.value.listen((value) {
              String receivedData = String.fromCharCodes(value);
              print("📡 DData Received: $receivedData");
            });
            print("-- -- Listening for live data on ${characteristic.uuid}");
          }
        }
      }
    } catch (e) {
      print("XX Error reading live data: $e");
    }
  }


  void _onDataReceived(List<int> dataChunk) {
    try {
      // Convert incoming bytes to string (they are ASCII characters)
      final receivedString = String.fromCharCodes(dataChunk);
      print("📡 Raw Received String: $receivedString");

      // Append to the buffer string
      _bufferedString.write(receivedString);

      // Try to extract 20 values
      final parts = _bufferedString.toString().trim().split(RegExp(r'\s+'));

      if (parts.length >= 20) {
        final completeParts = parts.sublist(0, 20);
        _bufferedString = StringBuffer(parts.sublist(20).join(' '));
        _decode(completeParts);
      }
    } catch (e) {
      print("❌ Error processing received chunk: $e");
    }
  }



  void _decode(List<String> hexStrings) {
    try {
      final decimalValues = hexStrings.map((hex) => int.parse(hex, radix: 16)).toList();
      final result = 'Decoded Decimal Values:\n${decimalValues.join(' ')}';
      setState(() {
        _decodedResult = result;
      });
      print("✅ Decoded Data: $result");
    } catch (e) {
      print("❌ Error decoding data: $e");
      setState(() {
        _decodedResult = '❌ Error decoding data';
      });
    }
  }




  String _formatBytes(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Decoded Data"),
        backgroundColor: const Color(0xFF5E8D9B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Live Decoded Data:",
              style: TextStyle(
                color: Color(0xFF5E8D9B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _decodedResult,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
