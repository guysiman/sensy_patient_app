import 'package:flutter/material.dart';
import '../widgets/sensy_app_header.dart'; // Import the header we just created
import '../modals/connection_status_popup.dart';
import 'Session_screen.dart';
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
          ? SessionScreen()
          : FootMappingScreen(
              onContinue: () {
                setState(() {
                  _isSessionScreen = true; // Switch to session screen
                });
              },
            );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_walk, size: 64, color: Color(0xFF2C5364)),
            SizedBox(height: 16),
            Text(
              'Walking Mode Content',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }
  }
}
