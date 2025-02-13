import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'screens/device_pairing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
        routes: {
          '/homepage': (context) => HomePage(),
          '/devicepairingpage': (context) => DevicePairingPage(),
        });
  }
}
