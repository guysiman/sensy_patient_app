import 'package:flutter/material.dart';
import '../modals/connection_status_popup.dart';

class DummyPage extends StatefulWidget {
  const DummyPage({super.key});

  @override
  _DummyPageState createState() => _DummyPageState();
}

class _DummyPageState extends State<DummyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
                child: Text('Dummy Page',
                    style: Theme.of(context).textTheme.titleMedium)),
            ElevatedButton(
              child: const Text("Connection status"),
              onPressed: () {
                showConnectionStatusPopup(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
