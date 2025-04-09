import 'package:flutter/material.dart';

class SensarsHeader extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final VoidCallback onInfoPressed;
  final VoidCallback? onTitlePressed; // Add callback for title press

  const SensarsHeader({
    Key? key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.onInfoPressed,
    this.onTitlePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      color: Colors.white,
      child: Column(
        children: [
          // Top row with logo and connection status
          Row(
            children: [
              // SENSARS title - now clickable but appearance unchanged
              GestureDetector(
                onTap: onTitlePressed,
                child: Text(
                  "SENSARS",
                  style: TextStyle(
                    color: Color(0xFF3A6470),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              // Connection status
              GestureDetector(
                onTap: onInfoPressed,
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF3A6470),
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Connection status",
                      style: TextStyle(
                        color: Color(0xFF3A6470),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Mode selector tabs
          Row(
            children: [
              _buildModeSelector("Pain relief mode", 0),
              SizedBox(width: 24),
              _buildModeSelector("Walking mode", 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(String title, int index) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF3A6470),
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          SizedBox(height: 4),
          Container(
            height: 2,
            width: 120,
            color: isSelected ? Color(0xFF3A6470) : Colors.transparent,
          ),
        ],
      ),
    );
  }
}