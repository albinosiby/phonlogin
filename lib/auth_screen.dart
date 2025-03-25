import 'package:flutter/material.dart';
import 'login_form.dart';
import 'sign_up_form.dart';
import 'auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child:
                  _isLogin
                      ? LoginForm(authService: _authService)
                      : SignUpForm(authService: _authService),
            ),
            TextButton(
              onPressed: _toggleAuthMode,
              child: Text(
                _isLogin
                    ? 'Create new account'
                    : 'Already have an account? Login',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
