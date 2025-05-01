import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
// Import the NeuromodulationCalculator
import '../services/neuromodulation_calculator.dart';
import '../services/database.dart';
import 'foot_selection_page.dart';
import '../services/nm_test.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../providers/bluetooth_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class SessionScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final String deviceType;
  const SessionScreen({
    Key? key,
    required this.onContinue,
    this.deviceType = 'ec',
  }) : super(key: key);

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  bool timerEnabled = true;
  double sessionDuration = 8.0; // Default 8 minutes
  String selectedLocation = "Right foot"; // Default selected location
  int intensityLevel = 2; // Default to show 3 colored bars (indices 0, 1, 2)
  final List<FootArea> rightFootAreas = const [
    FootArea(
        id: 'F0',
        left: 127,
        top: 60,
        width: 24,
        height: 13,
        zoneType: 'forefoot'),
    // Add more areas if needed
  ];
  // Added variables for running state
  bool isRunning = false;
  int remainingSeconds = 0;
  Timer? sessionTimer;
  Timer? stimulationTimer;
  Timer? writeDataTimer;
  String? bluetoothData;
  // Paradigm selection variables
  String selectedParadigm = "Standard";
  bool setParadigmAsDefault = false;

  // Neuromodulation variables
  Map<String, dynamic>? modulationResults;
  double currentPressure = 0.0;
  String? currentUserEmail;

  // Database service
  late DatabaseService databaseService;

  @override
  void initState() {
    super.initState();
    databaseService = DatabaseService();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bluetoothProvider =
          Provider.of<BluetoothProvider>(context, listen: false);
      BluetoothDevice? device;

      switch (widget.deviceType.toLowerCase()) {
        case 'ipg':
          device = bluetoothProvider.IPG;
          break;
        case 'ec':
          device = bluetoothProvider.EC;
          break;
      }

      if (device != null) {
        _readLiveData(device);
      } else {
        print("⚠️ No device found for type: ${widget.deviceType}");
      }
    });
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
              print("📡 Data Received: $receivedData");
              setState(() {
                bluetoothData = receivedData;
              });
            });
            print("-- -- Listening for live data on ${characteristic.uuid}");
          }
        }
      }
    } catch (e) {
      print("XX Error reading live data: $e");
    }
  }

  dynamic roundIfExceedsFourDecimals(dynamic value) {
    if (value == null) return 0.0; // Handle null case

    if (value is num) {
      final strValue = value.toString();
      // Check if the number has more than 4 decimal places
      if (strValue.contains('.') && strValue.split('.')[1].length > 4) {
        return double.parse(value.toStringAsFixed(4));
      }
    }
    return value; // Return original if <=4 decimals or not a number
  }

  Future<void> _writeLiveData(
      BluetoothDevice device, Map<String, dynamic> modulationData) async {
    try {
      print("🚀 Attempting to write data to ${device.advName}");
      List<BluetoothService> services = await device.discoverServices();
      print("🔍 Discovered ${services.length} services.");

      for (BluetoothService service in services) {
        print("🔍 Service: ${service.uuid}");
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          print("🔎 Characteristic: ${characteristic.uuid} - Properties: ${characteristic.properties}");

          // Only write to writable characteristics (excluding certain UUIDs if needed)
          if (characteristic.properties.write &&
              characteristic.uuid != Guid('2b29')) {
            // Construct JSON payload
            // Map<String, dynamic> payload = {
            //   'p': modulationData['pressure'],
            //   'a': modulationData['amplitude'],
            //   'f': modulationData['frequency'],
            //   // 'timestamp': DateTime.now().toIso8601String()
            // };
            Map<String, dynamic> payload = {
              'p': roundIfExceedsFourDecimals(modulationData['pressure']),
              'a': {
                's': roundIfExceedsFourDecimals(modulationData['amplitude']?['sai']),
                'f': roundIfExceedsFourDecimals(modulationData['amplitude']?['fai']),
              },
              'f': {
                's': roundIfExceedsFourDecimals(modulationData['frequency']?['sai']),
                'f': roundIfExceedsFourDecimals(modulationData['frequency']?['fai']),
              },
            };


            List<int> bytes = utf8.encode(json.encode(payload));
            print("✍ Writing data: $payload (Bytes: ${bytes.length})");

            DateTime sendTime = DateTime.now();
            await characteristic.write(bytes, withoutResponse: true);
            print("📤 Data Sent at $sendTime");

            // Optionally listen for notification response from any notify-capable characteristic
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


  Future<void> _loadUserData() async {
    try {
      // Get the current user directly from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        setState(() {
          currentUserEmail = user.email;
        });

        // Load user's saved settings
        await _loadUserSettings();
        await _loadSessionSettings();
      } else {
        print('No user is currently logged in');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Load session settings specifically (intensity and paradigm)
  Future<void> _loadSessionSettings() async {
    if (currentUserEmail == null) return;

    try {
      Map<String, dynamic>? sessionSettings =
          await databaseService.getSessionSettings(currentUserEmail!);

      if (sessionSettings != null) {
        setState(() {
          intensityLevel = sessionSettings['intensity_level'] ?? 2;
          selectedParadigm = sessionSettings['paradigm'] ?? 'Standard';
          setParadigmAsDefault = sessionSettings['is_default'] ?? false;
        });
        print(
            'Session settings loaded: intensity=$intensityLevel, paradigm=$selectedParadigm');
      }
    } catch (e) {
      print('Error loading session settings: $e');
    }
  }

  // Save session settings (intensity and paradigm)
  Future<void> _saveSessionSettings() async {
    if (currentUserEmail == null) return;

    try {
      await databaseService.saveSessionSettings(currentUserEmail!,
          intensityLevel, selectedParadigm, setParadigmAsDefault);
      print('Session settings saved successfully');
    } catch (e) {
      print('Error saving session settings: $e');
    }
  }

  @override
  void dispose() {
    sessionTimer?.cancel();
    stimulationTimer?.cancel();
    super.dispose();
  }

  // Update stimulation based on the current pressure and paradigm
  Future<void> updateStimulation(double pressure) async {
    if (currentUserEmail == null) return;

    try {
      // Convert foot location to a zone for the calculator
      String footZone = _getFootZoneFromLocation();

      // Calculate the modulation based on selected paradigm
      if (selectedParadigm == "Standard") {
        // Simple linear amplitude modulation based on intensity level
        double normalizedIntensity =
            intensityLevel / 4.0; // Convert 0-4 to 0.0-1.0
        currentPressure = normalizedIntensity * pressure;
        // Use linear amplitude for standard paradigm
        double amplitude =
            NeuromodulationCalculator.linearAmplitude(currentPressure);
        setState(() {
          modulationResults = {
            'amplitude': {'standard': amplitude},
            'electrode': footZone,
            'pressure': currentPressure
          };
          print(modulationResults);
        });
      } else {
        // For Advanced or Hybrid paradigms, use the full calculator
        double adjustedPressure = (intensityLevel / 4.0) * pressure;
        currentPressure = adjustedPressure;

        // Use database service directly to get electrode mapping using email
        String? electrodeMapping =
            await databaseService.getElectrodeMappingByEmail(currentUserEmail!);

        if (electrodeMapping != null) {
          // Use frequency modulation from the calculator
          Map<String, double> frequency =
              NeuromodulationCalculator.frequencyModulation(
                  electrodeMapping, adjustedPressure);

          // Use proper amplitude calculation based on paradigm
          Map<String, double> amplitudes = {};
          frequency.forEach((key, value) {
            if (selectedParadigm == "Hybrid") {
              amplitudes[key] = NeuromodulationCalculator.hybridAmplitude(
                  adjustedPressure, value);
            } else {
              // Advanced paradigm uses linear amplitude
              amplitudes[key] =
                  NeuromodulationCalculator.linearAmplitude(adjustedPressure);
            }
          });

          setState(() {
            modulationResults = {
              'electrode': electrodeMapping,
              'frequency': frequency,
              'amplitude': amplitudes
            };
          });
        } else {
          print('Electrode mapping not found for user: $currentUserEmail');
          // Fallback to basic calculation
          setState(() {
            modulationResults = {
              'amplitude': {
                'standard':
                    NeuromodulationCalculator.linearAmplitude(adjustedPressure)
              },
              'electrode': footZone,
              'pressure': adjustedPressure
            };
          });
        }
      }
    } catch (e) {
      print('Error updating stimulation: $e');
    }
  }

  // Convert UI location to footZone for the calculator
  String _getFootZoneFromLocation() {
    // This is a simplified mapping, adjust as needed based on your actual zones
    if (selectedLocation == "Right foot" || selectedLocation == "Left foot") {
      // Default to midfoot, but ideally this would be more specific
      return "midfoot";
    }
    return "midfoot"; // Default fallback
  }

  void startSession() {
    setState(() {
      isRunning = true;
      // If timer is disabled, use 15 minutes, otherwise use the slider value
      remainingSeconds = timerEnabled
          ? sessionDuration.toInt() * 60
          : 0; // 15 minutes in seconds
    });

    // Start the session timer
    sessionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timerEnabled) {
          if (remainingSeconds > 0) {
            remainingSeconds--;
          } else {
            // Auto-stop when countdown reaches zero
            stopSession();
          }
        } else {
          remainingSeconds++;
        }
      });
    });

    // Time simulation: reset after 1.5 seconds and update pressure
    double simulationTime = 0.0; // Start from 0s
    stimulationTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      simulationTime += 0.1; // Increment time by 0.1 seconds

      if (simulationTime >= 1.5) {
        simulationTime = 0.0; // Reset time after 1.5 seconds
      }

      final area = rightFootAreas.firstWhere((a) => a.id == 'F0');
      Map<String, dynamic> result =
          NeuromodulationLogic.computeModulation(area, simulationTime);

      setState(() {
        modulationResults = {
          'pressure': result['pressure'],
          'frequency': result['frequency'],
          'amplitude': result['amplitude'],
          'areaId': result['areaId'],
          'zoneType': result['zoneType'],
          'time': result['time'],
          'phase': result['phase'],
        };
        currentPressure = result['pressure'];

        // Optionally, update chart or any other state based on these results
        // Example:
        // pressureData.add(FlSpot(simulationTime, currentPressure));
      });
    });

    // Start sending data every 20 ms
    writeDataTimer = Timer.periodic(Duration(milliseconds: 20), (timer) async {
      if (modulationResults != null) {
        Map<String, dynamic> dataToSend = {
          'pressure': modulationResults!['pressure'],
          'amplitude': modulationResults!['amplitude'],
          'frequency': modulationResults!['frequency'],
          // 'timestamp': DateTime.now().toIso8601String(), // Optional
        };

        final bluetoothProvider =
        Provider.of<BluetoothProvider>(context, listen: false);
        BluetoothDevice? device;

        switch (widget.deviceType.toLowerCase()) {
          case 'ipg':
            device = bluetoothProvider.IPG;
            break;
          case 'ec':
            device = bluetoothProvider.EC;
            break;
        }

        if (device != null) {
          await _writeLiveData(device, dataToSend);
        } else {
          print("❗ BLE device not found during write.");
        }
      } else {
        print("⚠️ No modulation data to send.");
      }
    });

  }

  void stopSession() {
    // Save the session settings when stopping
    if (currentUserEmail != null) {
      _saveSessionSettings();
      _saveUserSettings(); // Save all settings
    }

    setState(() {
      isRunning = false;
      sessionTimer?.cancel();
      sessionTimer = null;
      stimulationTimer?.cancel();
      stimulationTimer = null;
      writeDataTimer?.cancel();
      writeDataTimer = null;
      modulationResults = null;
      currentPressure = 0.0;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Show paradigm selection dialog
  void _showParadigmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Local variables for the dialog state
        String tempSelectedParadigm = selectedParadigm;
        bool tempSetAsDefault = setParadigmAsDefault;

        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with close button
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ),
                  Text("Paradigm of stimulation",
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 16),

                  // Standard option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tempSelectedParadigm = "Standard";
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      decoration: BoxDecoration(
                        color: tempSelectedParadigm == "Standard"
                            ? Color(0xFFEBF0F1)
                            : Colors.white,
                        border: Border.all(
                          color: tempSelectedParadigm == "Standard"
                              ? const Color(0xFF3A6470)
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tempSelectedParadigm == "Standard")
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF3A6470),
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          Text("Standard",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: tempSelectedParadigm == "Standard"
                                          ? const Color(0xFF3A6470)
                                          : Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Advanced option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tempSelectedParadigm = "Advanced";
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      decoration: BoxDecoration(
                        color: tempSelectedParadigm == "Advanced"
                            ? Color(0xFFEBF0F1)
                            : Colors.white,
                        border: Border.all(
                          color: tempSelectedParadigm == "Advanced"
                              ? const Color(0xFF3A6470)
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tempSelectedParadigm == "Advanced")
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF3A6470),
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          Text("Advanced",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: tempSelectedParadigm == "Advanced"
                                          ? const Color(0xFF3A6470)
                                          : Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Hybrid option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tempSelectedParadigm = "Hybrid";
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      decoration: BoxDecoration(
                        color: tempSelectedParadigm == "Hybrid"
                            ? Color(0xFFEBF0F1)
                            : Colors.white,
                        border: Border.all(
                          color: tempSelectedParadigm == "Hybrid"
                              ? const Color(0xFF3A6470)
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (tempSelectedParadigm == "Hybrid")
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF3A6470),
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          Text("Hybrid",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: tempSelectedParadigm == "Hybrid"
                                          ? const Color(0xFF3A6470)
                                          : Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Set as default toggle
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            tempSetAsDefault = !tempSetAsDefault;
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 24,
                          decoration: BoxDecoration(
                            color: tempSetAsDefault
                                ? const Color(0xFF3A6470)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: tempSetAsDefault ? 2 : null,
                                left: tempSetAsDefault ? null : 2,
                                top: 2,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Set up as a default setting",
                        style: TextStyle(
                          color: const Color(0xFF3A6470),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Save button
                  ElevatedButton(
                    onPressed: () {
                      // Update the main state with selected values
                      this.setState(() {
                        selectedParadigm = tempSelectedParadigm;
                        setParadigmAsDefault = tempSetAsDefault;
                      });

                      // Save settings immediately
                      if (currentUserEmail != null) {
                        _saveSessionSettings();
                      }

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A6470),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // Save user settings to the database
  Future<void> _saveUserSettings() async {
    if (currentUserEmail == null) return;

    try {
      // Create a map of the user's settings
      Map<String, dynamic> userSettings = {
        'paradigm': selectedParadigm,
        'intensity_level': intensityLevel,
        'selected_location': selectedLocation,
        'session_duration': sessionDuration,
        'timer_enabled': timerEnabled,
        'last_pressure': currentPressure,
        'set_paradigm_as_default': setParadigmAsDefault,
        'last_updated': DateTime.now().millisecondsSinceEpoch
      };

      // Save the settings to Firestore using email
      await databaseService.saveUserSettings(currentUserEmail!, userSettings);
      print('User settings saved successfully');
    } catch (e) {
      print('Error saving user settings: $e');
    }
  }

  // Load user settings from the database
  Future<void> _loadUserSettings() async {
    if (currentUserEmail == null) return;

    try {
      Map<String, dynamic>? userSettings =
          await databaseService.getUserSettings(currentUserEmail!);

      if (userSettings != null) {
        setState(() {
          selectedParadigm = userSettings['paradigm'] ?? 'Standard';
          intensityLevel = userSettings['intensity_level'] ?? 2;
          selectedLocation = userSettings['selected_location'] ?? 'Right foot';
          sessionDuration = userSettings['session_duration'] ?? 8.0;
          timerEnabled = userSettings['timer_enabled'] ?? true;
          setParadigmAsDefault =
              userSettings['set_paradigm_as_default'] ?? false;
          // No need to set currentPressure here as it will be calculated during session
        });
        print('User settings loaded successfully');
      }
    } catch (e) {
      print('Error loading user settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16),

              // Timer settings container
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timer switch
                    Row(
                      children: [
                        GestureDetector(
                          onTap: !isRunning
                              ? () {
                                  setState(() {
                                    timerEnabled = !timerEnabled;
                                  });
                                }
                              : null,
                          child: Container(
                            width: 50,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFACC7CF),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: timerEnabled ? 3 : null,
                                  left: timerEnabled ? null : 3,
                                  top: 3,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: timerEnabled
                                          ? const Color(0xFF3A6470)
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Timer",
                          style: TextStyle(
                            color: const Color(0xFF3A6470),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Text(
                          isRunning ? "• Running" : "• Not running",
                          style: TextStyle(
                            color: isRunning ? Colors.green : Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Session duration and elapsed time toggle
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Set session duration",
                        style: TextStyle(
                          color: Color(0xFF3A6470),
                          fontSize: 14,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Session duration value or timer display
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      width: double.infinity,
                      color: isRunning
                          ? const Color(
                              0xFFE8F5E9) // Light green background when running
                          : const Color(0xFFF0F3F5),
                      child: Center(
                        child: Text(
                          isRunning
                              ? formatTime(remainingSeconds)
                              : timerEnabled
                                  ? "${sessionDuration.toInt()} min"
                                  : "0 min",
                          style: TextStyle(
                            color: isRunning ? Colors.green : Color(0xFF3A6470),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Session duration slider (only visible when timer is enabled)
                    // Session duration slider (only visible when timer is enabled)
                    if (timerEnabled)
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 2,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 12),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: isRunning
                              ? Colors.grey[400]
                              : const Color(0xFF3A6470),
                          inactiveTrackColor: Colors.grey[300],
                          thumbColor: isRunning
                              ? Colors.grey[400]
                              : const Color(0xFF3A6470),
                        ),
                        child: Column(
                          children: [
                            Slider(
                              value: sessionDuration,
                              min: 1,
                              max: 12,
                              divisions: 11,
                              onChanged: isRunning
                                  ? null
                                  : (value) {
                                      setState(() {
                                        sessionDuration = value;
                                      });
                                    },
                            ),
                            // Slider labels
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("1",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  Text("3",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  Text("5",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  Text("7",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  Text("9",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                  Text("12",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Stimulation info display
              if (isRunning && modulationResults != null)
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Neuromodulation Info",
                        style: TextStyle(
                          color: const Color(0xFF3A6470),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Paradigm: $selectedParadigm",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Location: $selectedLocation",
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        "Pressure: ${(currentPressure * 100).toStringAsFixed(1)}%",
                        style: TextStyle(fontSize: 14),
                      ),
                      if (modulationResults!.containsKey('frequency'))
                        Text(
                          "Frequencies: ${_formatFrequencies(modulationResults!['frequency'])}",
                          style: TextStyle(fontSize: 14),
                        ),
                      if (modulationResults!.containsKey('amplitude'))
                        Text(
                          "Amplitudes: ${_formatAmplitudes(modulationResults!['amplitude'])}",
                          style: TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              if (bluetoothData != null) ...[
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Bluetooth Data: $bluetoothData",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3A6470),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              // Start/Stop button
              ElevatedButton(
                onPressed: () {
                  // Toggle between Start and Stop
                  if (isRunning) {
                    stopSession();
                    // Session settings are saved in stopSession()
                  } else {
                    startSession();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isRunning ? Colors.red : const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        isRunning
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                        size: 24,
                        color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      isRunning ? "Stop" : "Start",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Intensity bars
              Container(
                height: 240,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Minus button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (intensityLevel > 0) {
                            intensityLevel--;
                            // Save settings when intensity changes
                            if (currentUserEmail != null) {
                              _saveSessionSettings();
                            }
                          }
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Icon(Icons.remove,
                              color: Colors.grey[700], size: 28),
                        ),
                      ),
                    ),

                    // Intensity bars
                    ...List.generate(5, (index) {
                      return Container(
                        width: 40,
                        height: 80.0 + (index * 30.0),
                        decoration: BoxDecoration(
                          color: index <= intensityLevel
                              ? const Color(0xFF5E8D9B)
                              : const Color(0xFFB8C9CE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),

                    // Plus button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (intensityLevel < 4) {
                            intensityLevel++;
                            // Add the if statement here
                            if (currentUserEmail != null) {
                              _saveSessionSettings();
                            }
                          }
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Icon(Icons.add,
                              color: Colors.grey[700], size: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Location selection buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedLocation = "Left foot";
                          // Save settings when location changes
                          if (currentUserEmail != null) {
                            _saveUserSettings();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedLocation == "Left foot"
                            ? const Color(0xFF3A6470)
                            : Colors.white,
                        foregroundColor: selectedLocation == "Left foot"
                            ? Colors.white
                            : Colors.grey[600],
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(
                            color: selectedLocation == "Left foot"
                                ? const Color(0xFF3A6470)
                                : Colors.grey[300]!,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (selectedLocation == "Left foot")
                            Icon(Icons.check, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text("Left foot"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedLocation = "Right foot";
                          // Save settings when location changes
                          if (currentUserEmail != null) {
                            _saveUserSettings();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedLocation == "Right foot"
                            ? const Color(0xFF3A6470)
                            : Colors.white,
                        foregroundColor: selectedLocation == "Right foot"
                            ? Colors.white
                            : Colors.grey[600],
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(
                            color: selectedLocation == "Right foot"
                                ? const Color(0xFF3A6470)
                                : Colors.grey[300]!,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (selectedLocation == "Right foot")
                            Icon(Icons.check, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text("Right foot"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Bottom action buttons
              // Bottom action buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: !isRunning ? widget.onContinue : null,
                        child: Text("Change location"),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: !isRunning ? _showParadigmDialog : null,
                        child: Text("Change paradigm"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to format frequency data
  String _formatFrequencies(Map<String, dynamic> frequencies) {
    StringBuffer buffer = StringBuffer();
    frequencies.forEach((key, value) {
      buffer.write('$key: ${value.toStringAsFixed(1)}Hz, ');
    });
    String result = buffer.toString();
    if (result.isNotEmpty) {
      result = result.substring(
          0, result.length - 2); // Remove trailing comma and space
    }
    return result;
  }

  // Helper function to format amplitude data
  String _formatAmplitudes(Map<String, dynamic> amplitudes) {
    StringBuffer buffer = StringBuffer();
    amplitudes.forEach((key, value) {
      buffer.write('$key: ${value.toStringAsFixed(2)}, ');
    });
    String result = buffer.toString();
    if (result.isNotEmpty) {
      result = result.substring(
          0, result.length - 2); // Remove trailing comma and space
    }
    return result;
  }
}
