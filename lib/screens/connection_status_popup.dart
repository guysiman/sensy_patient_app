import 'package:flutter/material.dart';

void showConnectionStatusPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return _ConnectionStatusPopup();
    },
  );
}

class _ConnectionStatusPopup extends StatefulWidget {
  @override
  _ConnectionStatusPopupState createState() => _ConnectionStatusPopupState();
}

class _ConnectionStatusPopupState extends State<_ConnectionStatusPopup>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // dummy data for now
  // mobile battery status, IPG battery, FW, serial#, connection, EC battery, FW, serial#, connection, sensor connections
  List<dynamic> connectionInfo = [
    '67%',
    '83%',
    '2.0',
    '83cne482j',
    true,
    '83%',
    '2.0',
    '8302847',
    true,
    false
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add a listener to update the UI when the tab index changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close Button
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          SizedBox(height: 4),

          // Title
          Text(
            "Connection status",
            style: Theme.of(context).textTheme.titleMedium,
          ),

          SizedBox(height: 24),

          // TabBar with TabController
          TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.secondary,
            dividerColor: Colors.white,
            tabs: [
              Tab(text: "Pain relief mode"),
              Tab(text: "Walking mode"),
            ],
          ),

          SizedBox(height: 10),

          // Manually switching the content based on selected index
          _tabController.index == 0
              ? Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFEBF0F1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                          context, "Mobile battery status:", connectionInfo[0]),
                      _buildInfoRow(
                          context, "IPG battery status:", connectionInfo[1]),
                      _buildInfoRow(
                          context, "IPG FW version:", connectionInfo[2]),
                      _buildInfoRow(
                          context, "IPG serial number:", connectionInfo[3]),
                      _buildInfoRow(context, "Connection with IPG:",
                          connectionInfo[4] ? 'Connected' : 'Disconnected',
                          isGreen: connectionInfo[4],
                          isRed: !connectionInfo[4]),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFEBF0F1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                          context, "Mobile battery status:", connectionInfo[0]),
                      _buildInfoRow(
                          context, "EC battery status:", connectionInfo[5]),
                      _buildInfoRow(
                          context, "EC FW version:", connectionInfo[6]),
                      _buildInfoRow(
                          context, "EC serial number:", connectionInfo[7]),
                      _buildInfoRow(context, "Connection with EC:",
                          connectionInfo[8] ? 'Connected' : 'Disconnected',
                          isGreen: connectionInfo[8],
                          isRed: !connectionInfo[8]),
                      _buildInfoRow(context, "Connection with sensors:",
                          connectionInfo[9] ? 'Connected' : 'Disconnected',
                          isGreen: connectionInfo[9],
                          isRed: !connectionInfo[9]),
                    ],
                  ),
                ),

          SizedBox(height: 24),

          // Cancel Button
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // Helper widget to create rows for information
  Widget _buildInfoRow(BuildContext context, String label, String value,
      {bool isGreen = false, bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: isGreen
                  ? Colors.green
                  : isRed
                      ? Colors.red
                      : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
