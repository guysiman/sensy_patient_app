import 'package:flutter/material.dart';

class SensarsHeader extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final VoidCallback onInfoPressed;

  const SensarsHeader({
    Key? key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.onInfoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bluishGreen = Color(0xFF3B626D);
    const lightGrey = Color(0xFFF5F5F5); // Light grey background for entire header

    return Container(
      color: lightGrey, // Make the entire header background light grey
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: lightGrey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SENSARS',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                    color: bluishGreen,
                    letterSpacing: 1.5,
                  ),
                ),
                GestureDetector(
                  onTap: onInfoPressed,
                  child: Row(
                    children: const [
                      Icon(
                        Icons.info_outline,
                        color: bluishGreen,
                      ),
                      SizedBox(width: 6.0),
                      Text(
                        'Connection status',
                        style: TextStyle(
                          color: bluishGreen,
                          fontWeight: FontWeight.w600, // Making this bolder
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Full-width divider that goes across the whole screen
          const Divider(
            color: Color(0xFFEBEBEB),
            thickness: 1.0,
            height: 1.0, // Minimizes the divider's own height
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            height: 44.0, // Increased height from 32.0 to 48.0 to make it taller
            decoration: const BoxDecoration(
              color: lightGrey,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEBEBEB),
                  width: 1.0,
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft, // Align tabs to bottom
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTab(0, 'Pain relief mode'),
                  const SizedBox(width: 24.0),
                  _buildTab(1, 'Walking mode'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    const bluishGreen = Color(0xFF3B626D);
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 4.0), // Only add padding at bottom
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? bluishGreen : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? bluishGreen : const Color(0xFF9EAFB3),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}