import 'package:flutter/material.dart';

/// A screen that displays the walking mode options with paradigm selection.
/// This screen follows the design shown in Image 1.
class WalkingModeScreen extends StatefulWidget {
  const WalkingModeScreen({Key? key}) : super(key: key);

  @override
  State<WalkingModeScreen> createState() => _WalkingModeScreenState();
}

class _WalkingModeScreenState extends State<WalkingModeScreen> {
  // Track which paradigm is selected
  String _selectedParadigm = 'Standard';

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
                // Standard paradigm
                _buildParadigmOption("Standard", horizontalPadding),
                SizedBox(height: 10),

                // Advanced paradigm
                _buildParadigmOption("Advanced", horizontalPadding),
                SizedBox(height: 10),

                // Hybrid paradigm
                _buildParadigmOption("Hybrid", horizontalPadding),
              ],
            ),
          ),

          // Spacer to push the Start button down
          SizedBox(
              height: 40), //puts the start button right below the paradigms
          // Start button
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 10,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF4CAF50), // Green color from the image
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // Navigate to the session screen or start the session
                Navigator.of(context).pushNamed('/sessionscreen');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Start",
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
                _buildBottomButton("Change intensities"),
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
          // Handle button press
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
