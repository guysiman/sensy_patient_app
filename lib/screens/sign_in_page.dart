import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth.dart';
import '../services/database.dart';
import '../main.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  String? errorMessage = '';

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_checkFields);
    _passwordController.addListener(_checkFields);
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled = _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn(BuildContext context) async {
  String username = _usernameController.text;
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  try {
    if (username.contains('@')) {
      await authProvider.signIn(username, _passwordController.text);
    } else {
      String? email = await DatabaseService().getEmailByUsername(username);
      if (email == null) {
        setState(() {
          errorMessage = 'Invalid username';
        });
        return;
      }
      await authProvider.signIn(email, _passwordController.text);
    }
    Navigator.pushReplacementNamed(context, '/homepage');
  } catch (e) {
    setState(() {
      errorMessage = 'Login failed: ${e.toString()}';
    });
  }
}


  void _onForgotPassword() {
    Navigator.pushNamed(context, '/forgotpwpage');
  }

  void _onSignUp() {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sign in', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 40),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
                if (errorMessage != '') Text('$errorMessage'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isButtonEnabled ? () => _onSignIn(context) : null,
                  child: const Text('Sign In'),
                ),
                TextButton(
                  onPressed: _onForgotPassword,
                  child: const Text('Forgot Password?'),
                ),
                TextButton(
                  onPressed: _onSignUp,
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
