import 'package:flutter/material.dart';

class FootMappingScreen extends StatefulWidget {
  final VoidCallback onContinue;
  const FootMappingScreen({Key? key, required this.onContinue})
      : super(key: key);

  @override
  State<FootMappingScreen> createState() => _FootMappingScreenState();
}

class _FootMappingScreenState extends State<FootMappingScreen> {
  final GlobalKey<_FootSelectionWidgetState> _leftFootKey =
      GlobalKey<_FootSelectionWidgetState>();
  final GlobalKey<_FootSelectionWidgetState> _rightFootKey =
      GlobalKey<_FootSelectionWidgetState>();

  bool isLeftFoot = false; // Track which foot is currently displayed

  Map<String, List<String>> _selectedAreas = {
    'left': [],
    'right': [],
  };

  Map<String, List<String>> get selectedAreas => _selectedAreas;

  void toggleFoot() {
    setState(() {
      isLeftFoot = !isLeftFoot;
    });
  }

  void updateSelection(List<String> newSelection) {
    setState(() {
      _selectedAreas[isLeftFoot ? 'left' : 'right'] = newSelection;
    });
  }

  void clearAllSelections() {
    setState(() {
      _selectedAreas['left'] = [];
      _selectedAreas['right'] = [];
    });
    if (isLeftFoot) {
      _leftFootKey.currentState?.clearSelection();
    } else {
      _rightFootKey.currentState?.clearSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive padding
    final horizontalPadding = screenWidth * 0.05; // 5% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instruction text without reset button
          Padding(
            padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 26, // Slightly larger
                bottom: 18), // Slightly larger
            child: Text(
              "Click on the painful areas",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Color(0xFF3A6470)),
            ),
          ),

          // Reset button above the foot container
          Padding(
            padding: EdgeInsets.only(right: horizontalPadding, bottom: 10.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed:
                    _selectedAreas[isLeftFoot ? 'left' : 'right']!.isNotEmpty
                        ? () {
                            clearAllSelections();
                          }
                        : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 20, // Slightly larger
                    ),
                    SizedBox(width: 5),
                    Text(
                      "Reset",
                      style: TextStyle(
                        fontSize: 14, // Slightly larger
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Foot diagram container - dynamically sized
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate the available space
                  final availableWidth =
                      constraints.maxWidth - (horizontalPadding * 2);
                  final availableHeight = constraints.maxHeight;

                  // Determine the container size while preserving aspect ratio
                  double containerWidth, containerHeight;

                  // Original aspect ratio of foot image plus some padding
                  const aspectRatio = 343 / 364;

                  // Add a bit more space around the container
                  const paddingFactor =
                      0.95; // 95% of the calculated size to add some space

                  if (availableWidth / availableHeight > aspectRatio) {
                    // Height constrained
                    containerHeight = availableHeight * paddingFactor;
                    containerWidth = containerHeight * aspectRatio;
                  } else {
                    // Width constrained
                    containerWidth = availableWidth * paddingFactor;
                    containerHeight = containerWidth / aspectRatio;
                  }

                  return Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1.5, // Slightly thicker border
                      ),
                      borderRadius:
                          BorderRadius.circular(10), // Slightly larger radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FootSelectionWidget(
                      initialSelection:
                          _selectedAreas[isLeftFoot ? 'left' : 'right']!,
                      key: isLeftFoot ? _leftFootKey : _rightFootKey,
                      onSelectionChanged: (List<String> newSelection) {
                        setState(() {
                          _selectedAreas[isLeftFoot ? 'left' : 'right'] =
                              newSelection;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Foot pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left,
                    color: isLeftFoot ? Color(0xFF3A6470) : Colors.grey),
                onPressed: isLeftFoot ? toggleFoot : null,
              ),
              Text(
                isLeftFoot ? "Left foot 2 / 2" : "Right foot 1 / 2",
                style: TextStyle(
                    color: Color(0xFF5E8D9B),
                    fontWeight: FontWeight.w500,
                    fontSize: 17),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: !isLeftFoot ? Color(0xFF3A6470) : Colors.grey),
                onPressed: !isLeftFoot ? toggleFoot : null,
              ),
            ],
          ),

          // Confirmation button
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 18.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Slightly larger radius
                ),
                padding: EdgeInsets.symmetric(vertical: 18), // Slightly larger
              ),
              onPressed: (selectedAreas['left']!.isNotEmpty ||
                      selectedAreas['right']!.isNotEmpty)
                  ? widget.onContinue
                  : null,
              child: Text(
                "I have inserted all locations where I feel pain",
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple data class for each tappable foot area.
class _FootArea {
  final String id;
  final double left;
  final double top;
  final double width;
  final double height;

  const _FootArea({
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

/// An interactive foot widget with 16 rectangular hotspots (F0..F15).
/// Tapping toggles selection and highlights the area.
/// The user never sees "F0..F15" labels, but the IDs are returned in a callback.
class FootSelectionWidget extends StatefulWidget {
  final ValueChanged<List<String>> onSelectionChanged;
  final List<String> initialSelection;

  const FootSelectionWidget({
    Key? key,
    required this.onSelectionChanged,
    this.initialSelection = const [],
  }) : super(key: key);

  @override
  State<FootSelectionWidget> createState() => _FootSelectionWidgetState();
}

class _FootSelectionWidgetState extends State<FootSelectionWidget> {
  late List<String> _selectedAreas;

  // Original foot area coordinates as requested
  final List<_FootArea> _footAreas = const [
    _FootArea(id: 'F0', left: 127, top: 60, width: 24, height: 13),
    _FootArea(id: 'F1', left: 127, top: 75, width: 24, height: 13),
    //
    _FootArea(id: 'F2', left: 157, top: 65, width: 12, height: 10),
    _FootArea(id: 'F3', left: 173, top: 71, width: 12, height: 9),
    _FootArea(id: 'F4', left: 185, top: 85, width: 12, height: 9),
    _FootArea(id: 'F5', left: 202, top: 97, width: 12, height: 9),
    //
    _FootArea(id: 'F6', left: 128, top: 104, width: 24, height: 33),
    _FootArea(id: 'F7', left: 156, top: 104, width: 26, height: 33),
    _FootArea(id: 'F8', left: 187, top: 119, width: 26, height: 20),
    //
    _FootArea(id: 'F9', left: 156, top: 143, width: 26, height: 82),
    _FootArea(id: 'F10', left: 185, top: 143, width: 26, height: 27),
    _FootArea(id: 'F11', left: 185, top: 172, width: 20, height: 27),
    _FootArea(id: 'F12', left: 185, top: 201, width: 20, height: 27),
    //
    _FootArea(id: 'F13', left: 154, top: 235, width: 26, height: 30),
    _FootArea(id: 'F14', left: 154, top: 268, width: 26, height: 35),
    _FootArea(id: 'F15', left: 185, top: 250, width: 18, height: 40),
  ];

  @override
  void initState() {
    super.initState();
    _selectedAreas = List<String>.from(widget.initialSelection);
  }

  // Add the clearSelection method
  void clearSelection() {
    setState(() {
      _selectedAreas.clear();
    });
    widget.onSelectionChanged(_selectedAreas);
  }

  void _onAreaTapped(String areaId) {
    setState(() {
      if (_selectedAreas.contains(areaId)) {
        _selectedAreas.remove(areaId);
      } else {
        _selectedAreas.add(areaId);
      }
    });
    // Return the updated list of selected areas.
    widget.onSelectionChanged(_selectedAreas);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The actual size available.
        final actualWidth = constraints.maxWidth;
        final actualHeight = constraints.maxHeight;

        // Calculate scale factors based on the original dimensions
        final scaleX = actualWidth / 343;
        final scaleY = actualHeight / 364;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Center the foot diagram with optimal padding
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  'assets/foot_diagram.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Show all tappable areas with light pink color (visible but subtle)
            ..._footAreas.map((area) {
              // Scale each area's coordinates.
              final double left = area.left * scaleX;
              final double top = area.top * scaleY;
              final double w = area.width * scaleX;
              final double h = area.height * scaleY;

              return Positioned(
                left: left,
                top: top,
                width: w,
                height: h,
                child: GestureDetector(
                  onTap: () => _onAreaTapped(area.id),
                  child: Container(
                    decoration: BoxDecoration(
                      // Areas are invisible until clicked, then show transparent blue
                      color: _selectedAreas.contains(area.id)
                          ? Colors.blue
                              .withOpacity(0.4) // Selected: transparent blue
                          : Colors
                              .transparent, // Unselected: completely invisible
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
