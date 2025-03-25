import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'auth_service.dart';
import 'otp_screen.dart';

class LoginForm extends StatefulWidget {
  final AuthService authService;
  
  const LoginForm({super.key, required this.authService});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await widget.authService.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        onCodeSent: (verificationId) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: _phoneNumber,
                verificationId: verificationId,
                authService: widget.authService,
                isLogin: true,
              ),
            ),
          );
        },
        onVerificationFailed: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${error.message}')),
          );
        },
        onVerificationCompleted: (credential) async {
          await widget.authService.signInWithOTP(
            verificationId: credential.verificationId!,
            otp: credential.smsCode!,
          );
        },
        onCodeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Login with Phone',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          IntlPhoneField(
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
            initialCountryCode: 'US',
            onChanged: (phone) {
              _phoneNumber = phone.completeNumber;
            },
            validator: (phone) {
              if (phone?.number.isEmpty ?? true) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Send OTP'),
                  ),
                ),
        ],
      ),
    );
  }
}