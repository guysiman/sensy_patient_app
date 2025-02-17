import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isScanning = false;

  String _getTitle(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'ipg':
        return 'Pair an IPG';
      case 'external controller':
        return 'Pair an EC';
      case 'external sensors':
        return 'Pair sensors';
      default:
        return 'Pair Device';
    }
  }

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  Future<void> _startScanning() async {
    setState(() {
      isScanning = true;
    });
    
    await Future.delayed(const Duration(seconds: 4));
    
    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Color(0xFF2D4F63),
        ),
        title: Text(
          'Back',
          style: TextStyle(
            color: Color(0xFF2D4F63),
            fontSize: 18,
          ),
        ),
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTitle(deviceType),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Searching nearby...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            // Example device buttons
            _buildDeviceButton('IPG 3452fg5'),
            _buildDeviceButton('AirPods - Eugene'),
            _buildDeviceButton('Column-23'),
            _buildDeviceButton('JBL-Go'),
            SizedBox(height: 40),
            // Instructions Section
            Text(
              'How to connect your device via Bluetooth',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
            SizedBox(height: 24),
            _buildInstructionStep(
              'Step one',
              'place the charging unit above the implant.',
            ),
            SizedBox(height: 16),
            _buildInstructionStep(
              'Step two',
              'press the pairing button on a charging unit for 10 seconds until IPG appears on the list.',
            ),
            SizedBox(height: 16),
            _buildInstructionStep(
              'Step three',
              'press connect button to the IPG.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceButton(String deviceName) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          deviceName,
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF2D3436),
          ),
        ),
        trailing: TextButton(
          onPressed: () {},
          child: Text(
            'Connect',
            style: TextStyle(
              color: Color(0xFF2D4F63),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String stepTitle, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(top: 8, right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE3A69C),
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2D3436),
              ),
              children: [
                TextSpan(
                  text: '$stepTitle — ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }
}