import 'package:flutter/material.dart';
import 'package:sensy_patient_app/screens/walking_mode.dart';
import '../widgets/sensy_app_header.dart'; // Import the header we just created
import '../modals/connection_status_popup.dart';
import 'session_page.dart';
import 'foot_selection_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedTabIndex = 1;
  bool _isSessionScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SensarsHeader(
              selectedIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              onInfoPressed: () {
                showConnectionStatusPopup(context);
              },
              onTitlePressed: () {
                // Direct navigation to homepage when SENSARS text is clicked
                Navigator.pushReplacementNamed(context, '/homepage');
              },
            ),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    // This is where each tab's content would go
    if (_selectedTabIndex == 0) {
      return _isSessionScreen
          ? SessionScreen(
        onContinue: () {
          setState(() {
            _isSessionScreen = false; // Switch to session screen
          });
        },
      )
          : FootMappingScreen(
        onContinue: () {
          setState(() {
            _isSessionScreen = true; // Switch to session screen
          });
        },
      );
    } else {
      return WalkingModeScreen();
    }
  }
}