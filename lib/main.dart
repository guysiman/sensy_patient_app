import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sensy_patient_app/screens/forgot_password_page.dart';
import 'firebase_options.dart';
import 'services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'providers/bluetooth_provider.dart';
import 'widget_tree.dart';

import 'screens/bluetooth_off_page.dart';
import 'screens/device_pairing_page.dart';
import 'screens/home_page.dart';
import 'screens/sign_in_page.dart';
import 'screens/bluetooth_page.dart';
import 'screens/main_page.dart';
import 'screens/decoded_data_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BluetoothProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class AuthProvider with ChangeNotifier {
  final Auth _auth = Auth();
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _auth.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme(
              primary: Color(0xFF3A6470),
              onPrimary: Colors.white,
              secondary: Color(0xFF75939B),
              onSecondary: Colors.white,
              error: Colors.red,
              onError: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF253228),
              brightness: Brightness.light,
            ),
            hintColor: Color(0xFF9CB1B7),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF3A6470),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                  side: BorderSide(width: 1.0, color: Color(0xFF75939B)),
                  foregroundColor: Color(0xFF3A6470),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            textTheme: TextTheme(
                titleLarge: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF253228),
                ),
                titleMedium: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF253228),
                ),
                labelMedium: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF253228),
                ),
                labelSmall: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                bodyLarge: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF253228),
                ),
                bodyMedium: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF253228),
                )),
            useMaterial3: true,
          ),
          home: authProvider.user == null ? SignInPage() : const WidgetTree(),
          routes: {
            '/signinpage': (context) => SignInPage(),
            '/forgotpwpage': (context) => ForgotPasswordPage(),
            '/homepage': (context) => HomePage(),
            '/devicepairingpage': (context) => DevicePairingPage(),
            '/bluetoothpage': (context) => BluetoothPage(),
            '/bluetoothoffpage': (context) => BluetoothOffPage(),
            '/datapage': (context) => DecodedDataScreen(),
            '/mainpage': (context) => MainPage(),
          },
        );
      },
    );
  }
}
