import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/*
TO DO
- Scan and display a real time list of nearby Bluetooth devices
- Include a refresh button to rescan for devices
- Implement AUTOMATIC BLUETOOTH SCANNING on screen load
*/

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus();

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  BluetoothDevice? _device;

  Future<void> _startScanning() async {
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 15));
    print("-- SCAN STARTED --");

    var subscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.advName} found! RSSI: ${r.rssi}');

        // ✅ Filter for Thingy:53 and connect
        if (r.device.advName == "Thingy:53" || r.device.advName == "Nordic_UART_Service") {  // Update if needed
          FlutterBluePlus.stopScan();
          print("Thingy:53 Found! Connecting...");
          _connectToDevice(r.device);
          break;
        }
      }
    });



  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _device = device;
      print("✅ Connected to ${device.advName}");

      // 🔍 Discover GATT Services
      _discoverServices(device);
    } catch (e) {
      print(" Connection failed: $e");
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();

    for (BluetoothService service in services) {
      // for (BluetoothCharacteristic characteristic in service.characteristics) {
      //   if (characteristic.properties.notify) {
      //     await characteristic.setNotifyValue(true);
      //     characteristic.value.listen((value) {
      //       print("Data Received: $value");
      //     });
      //   }
      // }

      // READ DEVICE DATA
      // Reads all characteristics
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
        if (c.properties.read) {
          List<int> value = await c.read();
          print(value);
        }
      }
    }


  }

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
                _startScanning();
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
