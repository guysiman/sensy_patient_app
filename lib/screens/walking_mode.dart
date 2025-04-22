import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../providers/bluetooth_provider.dart';

class PainReliefFeedbackScreen extends StatefulWidget {
  @override
  _PainReliefFeedbackScreenState createState() =>
      _PainReliefFeedbackScreenState();
}

class _PainReliefFeedbackScreenState extends State<PainReliefFeedbackScreen> {
  // Track selected emoji for each body part
  int? _rightFootRating;
  int? _leftFootRating;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        title: const Text(
          'SENSARS',
          style: TextStyle(
            color: Color(0xFF5E8D9B),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.info_outline,
                color: Color(0xFF5E8D9B), size: 16),
            label: const Text(
              'Connection status',
              style: TextStyle(
                color: Color(0xFF5E8D9B),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How satisfied are you with the relief of pain in this session?',
              style: TextStyle(
                color: Color(0xFF5E8D9B),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Right foot feedback
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Right foot',
                    style: TextStyle(
                      color: Color(0xFF5E8D9B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEmoji(
                          '😣',
                          0,
                          _rightFootRating,
                          (val) => setState(() => _rightFootRating = val),
                          Colors.red),
                      _buildEmoji(
                          '😟',
                          1,
                          _rightFootRating,
                          (val) => setState(() => _rightFootRating = val),
                          Colors.orange),
                      _buildEmoji(
                          '😐',
                          2,
                          _rightFootRating,
                          (val) => setState(() => _rightFootRating = val),
                          Colors.yellow),
                      _buildEmoji(
                          '😊',
                          3,
                          _rightFootRating,
                          (val) => setState(() => _rightFootRating = val),
                          Colors.lightBlue),
                      _buildEmoji(
                          '😁',
                          4,
                          _rightFootRating,
                          (val) => setState(() => _rightFootRating = val),
                          Colors.green),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Left Foot feedback
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Left Foot',
                    style: TextStyle(
                      color: Color(0xFF5E8D9B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEmoji(
                          '😣',
                          0,
                          _leftFootRating,
                          (val) => setState(() => _leftFootRating = val),
                          Colors.red),
                      _buildEmoji(
                          '😟',
                          1,
                          _leftFootRating,
                          (val) => setState(() => _leftFootRating = val),
                          Colors.orange),
                      _buildEmoji(
                          '😐',
                          2,
                          _leftFootRating,
                          (val) => setState(() => _leftFootRating = val),
                          Colors.yellow),
                      _buildEmoji(
                          '😊',
                          3,
                          _leftFootRating,
                          (val) => setState(() => _leftFootRating = val),
                          Colors.lightBlue),
                      _buildEmoji(
                          '😁',
                          4,
                          _leftFootRating,
                          (val) => setState(() => _leftFootRating = val),
                          Colors.green),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Finish button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rightFootRating != null && _leftFootRating != null
                    ? () {
                        // Save feedback and return to main screen
                        Navigator.of(context).pop();
                      }
                    : null, // Disabled if either rating is missing
                style: ElevatedButton.styleFrom(
                  backgroundColor: _rightFootRating != null &&
                          _leftFootRating != null
                      ? const Color(
                          0xFF5E8D9B) // Active teal color when both ratings present
                      : const Color(0xFF96A7AB), // Inactive gray color
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Finish',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Skip button
            Center(
              child: TextButton(
                onPressed: () {
                  // Skip feedback and return to main screen
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Color(0xFF5E8D9B),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmoji(String emoji, int value, int? currentValue,
      Function(int) onSelect, Color color) {
    final bool isSelected = currentValue == value;

    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

/// Sensors Calibration Screen that matches the design in the provided image
class SensorsCalibrationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF5E8D9B), size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SENSARS',
          style: TextStyle(
            color: Color(0xFF5E8D9B),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.info_outline,
                color: Color(0xFF5E8D9B), size: 16),
            label: const Text(
              'Connection status',
              style: TextStyle(
                color: Color(0xFF5E8D9B),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pressure sensors in the insole',
              style: TextStyle(
                color: Color(0xFF5E8D9B),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildCalibrateButton('Calibrate'),
            const SizedBox(height: 8),
            _buildResetButton('Reset sensors'),
            const SizedBox(height: 24),
            const Text(
              'Ankle IMU',
              style: TextStyle(
                color: Color(0xFF5E8D9B),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildCalibrateButton('Calibrate'),
            const SizedBox(height: 8),
            _buildResetButton('Reset sensors'),
            const SizedBox(height: 24),
            const Text(
              'Knee IMU',
              style: TextStyle(
                color: Color(0xFF5E8D9B),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildCalibrateButton('Calibrate'),
            const SizedBox(height: 8),
            _buildResetButton('Reset sensors'),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrateButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5E8D9B),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildResetButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF5E8D9B),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh, size: 16),
            const SizedBox(width: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}

class WalkingModeScreen extends StatefulWidget {
  const WalkingModeScreen({Key? key}) : super(key: key);

  @override
  State<WalkingModeScreen> createState() => _WalkingModeScreenState();
}

class _WalkingModeScreenState extends State<WalkingModeScreen> {
  // Track which paradigm is selected
  String _selectedParadigm = 'Mode 1';

  // Track if session is active (for Start/Stop button)
  bool _isSessionActive = false;
  bool _isWaitingForStartConfirmation = false;

  Future<void> _writeLiveData(
      BluetoothDevice device, Map<String, dynamic> jsonData) async {
    try {
      print("🚀 Attempting to write data to ${device.advName}");
      List<BluetoothService> services = await device.discoverServices();
      print("🔍 Discovered ${services.length} services.");

      for (BluetoothService service in services) {
        print("🔍 Service: ${service.uuid}");
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          print(
              "🔎 Characteristic: ${characteristic.uuid} - Properties: ${characteristic.properties}");
          print("🔎 Checking characteristic: ${characteristic.uuid}");

          if (characteristic.properties.write &&
              characteristic.uuid != Guid('2b29')) {
            List<int> bytes = utf8.encode(json.encode(jsonData));
            print("✍ Writing data: $jsonData (Bytes: $bytes)");

            DateTime sendTime = DateTime.now();
            await characteristic.write(bytes, withoutResponse: true);
            print("📤 Data Sent at $sendTime");

            // Check if there's a characteristic for receiving data
            for (BluetoothCharacteristic c in service.characteristics) {
              if (c.properties.notify || c.properties.indicate) {
                await c.setNotifyValue(true);
                c.lastValueStream.listen((value) {
                  String receivedData = String.fromCharCodes(value);
                  print("📡 Received Data: $receivedData");
                });
                print("✅ Listening for response on ${c.uuid}");
                return;
              }
            }

            print("⚠️ No notification characteristic found.");
            return;
          }
        }
      }
      print("⚠️ No writable characteristic found.");
    } catch (e) {
      print("❌ Error writing data: $e");
    }
  }

  Future<void> _readLiveData(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);

            bool isFirstNotification = true;
            String? lastProcessedData;

            characteristic.value.listen((value) {
              String receivedData = String.fromCharCodes(value).trim();
              print("📡 Data Received: $receivedData");

              if (isFirstNotification) {
                // Skip the first notification to avoid processing cached data
                isFirstNotification = false;
                return;
              }

              if (receivedData == lastProcessedData) {
                // Duplicate notification; ignore
                return;
              }

              lastProcessedData = receivedData;

              if (receivedData == "walking_mode_started") {
                print("Walking mode started detected");
                if (mounted) {
                  setState(() {
                    _isSessionActive = true;
                    _isWaitingForStartConfirmation = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Walking mode active")),
                  );
                }
              }
            });

            print("-- Listening for live data on ${characteristic.uuid}");
          }
        }
      }
    } catch (e) {
      print("❌ Error reading live data: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    BluetoothDevice? EC = context.watch<BluetoothProvider>().EC;

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05; // 5% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instruction text
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: 26,
              bottom: 18,
            ),
            child: Text(
              "Choose the paradigm of stimulation",
              style: TextStyle(
                color: const Color(0xFF5E8D9B),
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Paradigm selection options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                // Mode 1 paradigm (formerly Standard)
                _buildParadigmOption("Mode 1", horizontalPadding),
                SizedBox(height: 10),

                // Mode 2 paradigm (formerly Advanced)
                _buildParadigmOption("Mode 2", horizontalPadding),
                SizedBox(height: 10),

                // Mode 3 paradigm (formerly Hybrid)
                _buildParadigmOption("Mode 3", horizontalPadding),
              ],
            ),
          ),

          // Spacer to push the Start button down
          SizedBox(
              height: 40), //puts the start button right below the paradigms

          // Start/Stop button
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 10,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSessionActive
                    ? const Color(0xFFE53935) // Red for Stop
                    : (_isWaitingForStartConfirmation ? Colors.grey : Color(0xFF4CAF50)), // Green for Start
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: (_isSessionActive || _isWaitingForStartConfirmation)
                  ? _isSessionActive
                  ? () {
                // Handle STOP logic
                final Map<String, dynamic> jsonData = {
                  "command": "stop_walk",
                };
                _writeLiveData(EC!, jsonData);
                setState(() {
                  _isSessionActive = false;
                });
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PainReliefFeedbackScreen(),
                  ),
                );
              }
                  : null // Waiting for confirmation — disabled
                  : () {
                // Handle START logic
                setState(() {
                  _isWaitingForStartConfirmation = true;
                });

                final Map<String, dynamic> jsonData = {
                  "command": "start_walk",
                  "mode": _selectedParadigm,
                };
                _writeLiveData(EC!, jsonData);
                _readLiveData(EC!);
              },

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      _isSessionActive
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                      size: 24,
                      color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    _isSessionActive ? "Stop" : "Start",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),

          // Bottom options - with wider buttons
          Container(
            padding: EdgeInsets.symmetric(
              horizontal:
                  horizontalPadding * 0.5, // Less padding to make buttons wider
              vertical: 10,
            ),
            child: Column(
              children: [
                _buildBottomButton("Boost"),
                SizedBox(height: 10),
                _buildBottomButton("Calibrate sensors"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParadigmOption(String paradigm, double horizontalPadding) {
    final isSelected = _selectedParadigm == paradigm;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedParadigm = paradigm;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFECF0F1),
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: const Color(0xFF3A6470), width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFF3A6470),
                size: 22,
              ),
            if (isSelected) SizedBox(width: 10),
            Text(
              paradigm,
              style: TextStyle(
                color: const Color(0xFF3A6470),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(String label) {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // Only handle button press if session is active (in stop mode)
          if (_isSessionActive) {
            if (label == "Calibrate sensors") {
              // Navigate to the sensors calibration page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SensorsCalibrationScreen(),
                ),
              );
            } else if (label == "Boost") {
              // Handle boost functionality
            }
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor:
              _isSessionActive ? const Color(0xFF5E8D9B) : Colors.grey,
          side: BorderSide(
            color: _isSessionActive
                ? const Color(0xFF5E8D9B)
                : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                _isSessionActive ? const Color(0xFF5E8D9B) : Colors.grey[400],
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
