import 'package:flutter/material.dart';

class PainReliefFeedbackScreen extends StatefulWidget {
  @override
  _PainReliefFeedbackScreenState createState() =>
      _PainReliefFeedbackScreenState();
}

class _PainReliefFeedbackScreenState extends State<PainReliefFeedbackScreen> {
  // Track selected emoji for each body part
  int? _rightFootRating;
  int? _rightCalfRating;

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

            // Right calf feedback
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
                    'Right calf',
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
                          _rightCalfRating,
                          (val) => setState(() => _rightCalfRating = val),
                          Colors.red),
                      _buildEmoji(
                          '😟',
                          1,
                          _rightCalfRating,
                          (val) => setState(() => _rightCalfRating = val),
                          Colors.orange),
                      _buildEmoji(
                          '😐',
                          2,
                          _rightCalfRating,
                          (val) => setState(() => _rightCalfRating = val),
                          Colors.yellow),
                      _buildEmoji(
                          '😊',
                          3,
                          _rightCalfRating,
                          (val) => setState(() => _rightCalfRating = val),
                          Colors.lightBlue),
                      _buildEmoji(
                          '😁',
                          4,
                          _rightCalfRating,
                          (val) => setState(() => _rightCalfRating = val),
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
                onPressed: _rightFootRating != null && _rightCalfRating != null
                    ? () {
                        // Save feedback and return to main screen
                        Navigator.of(context).pop();
                      }
                    : null, // Disabled if either rating is missing
                style: ElevatedButton.styleFrom(
                  backgroundColor: _rightFootRating != null &&
                          _rightCalfRating != null
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

  @override
  Widget build(BuildContext context) {
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
                    : const Color(0xFF4CAF50), // Green for Start
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                setState(() {
                  // Toggle session active state
                  _isSessionActive = !_isSessionActive;
                });

                if (_isSessionActive) {
                  // Session started
                  // Navigate to the session screen or start the session
                  // Navigator.of(context).pushNamed('/sessionscreen');
                } else {
                  // Session stopped - show feedback screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PainReliefFeedbackScreen(),
                    ),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      _isSessionActive
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                      size: 20),
                  SizedBox(width: 8),
                  Text(
                    _isSessionActive ? "Stop" : "Start",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
              ? Border.all(color: const Color(0xFF5E8D9B), width: 1)
              : null,
        ),
        child: Row(
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFF5E8D9B),
                size: 22,
              ),
            if (isSelected) SizedBox(width: 10),
            Text(
              paradigm,
              style: TextStyle(
                color: isSelected ? const Color(0xFF5E8D9B) : Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
