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
  List<String> devices = [
    'IPG 3452fg5',
    'AirPods - Eugene',
    'Column-23',
    'JBL-Go'
  ];

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

  List<String> _getInstructions(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'ipg':
        return [
          'Step one — place the charging unit above the implant.',
          'Step two — press the pairing button on a charging unit for 10 seconds until IPG appears on the list.',
          'Step three — press connect button to the IPG.'
        ];
      case 'external controller':
        return [
          'Step one — Press the pairing button on the External Controller for 10 seconds until the device appears on the list.',
          'Step two — Press connect to the External Controller'
        ];
      case 'external sensors':
        return [
          'Step one — Press the pairing button on the Insole Sensor for 10 seconds until the Sensor appears on the list.',
          'Step 2 — Press connect to the Sensor.'
        ];
      default:
        return ['Step one', 'Step two'];
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
    String deviceType = "default";
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      deviceType = args;
    }

    return Scaffold(
      appBar: AppBar(
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
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  // Refresh logic here
                });
              },
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getTitle(deviceType),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 24),
              Text(
                'Searching nearby...',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Color(0xFF9CB1B7)),
              ),
              SizedBox(height: 16),

              // Example device buttons

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: devices
                    .map(
                      (deviceName) => _buildDeviceButton(deviceName),
                    )
                    .toList(),
              ),

              SizedBox(height: 118),

              // Instructions Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'How to connect your device via Bluetooth',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              SizedBox(height: 12),

              _buildInstructions(deviceType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceButton(String deviceName) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFFEEF3F4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        title: Text(
          deviceName,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/dummypage');
          },
          child: Text(
            'Connect',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions(String deviceName) {
    List<String> instructions = _getInstructions(deviceName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: instructions
          .map((instruction) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildInstructionStep(instruction),
              ))
          .toList(),
    );
  }

  Widget _buildInstructionStep(String description) {
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
            child: Text(description,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.normal))),
      ],
    );
  }
}
