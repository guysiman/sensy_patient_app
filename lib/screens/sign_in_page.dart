import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database.dart';
import '../main.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  String? errorMessage = '';

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkFields);
    _passwordController.addListener(_checkFields);
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn(BuildContext context) async {
    String email = _emailController.text;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      // Directly use the email for authentication
      await authProvider.signIn(email, _passwordController.text);
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

  void _onSignUp() {}

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

                // Email field
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email',
                        style: Theme.of(context).textTheme.bodyMedium)),
                const SizedBox(height: 4),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Enter your email',
                    labelStyle:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Color(0xFFE8EDEC))),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                          color: Color(
                              0xFFE8EDEC)), // Border color when not focused
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),

                const SizedBox(height: 16),

                // Password field
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password',
                        style: Theme.of(context).textTheme.bodyMedium)),
                const SizedBox(height: 4),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Enter your password',
                    labelStyle:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Color(0xFFE8EDEC))),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                          color: Color(
                              0xFFE8EDEC)), // Border color when not focused
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),

                const SizedBox(height: 8),

                // Forgot password link
                TextButton(
                  onPressed: _onForgotPassword,
                  child: Text('Forgot password?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      )),
                ),

                const SizedBox(height: 40),

                if (errorMessage != '') Text('$errorMessage'),

                const SizedBox(height: 40),

                // Enter account button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withAlpha((255 * 0.5).toInt()), // Background Color
                      disabledForegroundColor: Colors.white70, //Text Color
                    ),
                    onPressed: _isButtonEnabled
                        ? () {
                      _onSignIn(context);
                    }
                        : null,
                    child: const Text('Enter account'),
                  ),
                ),

                const SizedBox(height: 40),

                // Sign up prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    GestureDetector(
                      onTap: _onSignUp,
                      child: Text(
                        'Sign up',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}