import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'auth_service.dart';
import 'otp_screen.dart';
import 'profile_setup_screen.dart';

class SignUpForm extends StatefulWidget {
  final AuthService authService;
  
  const SignUpForm({super.key, required this.authService});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
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
                isLogin: false,
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
          final userCredential = await widget.authService.signInWithOTP(
            verificationId: credential.verificationId!,
            otp: credential.smsCode!,
          );
          
          if (userCredential.additionalUserInfo?.isNewUser ?? false) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileSetupScreen(
                  authService: widget.authService,
                ),
              ),
            );
          }
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
            'Create Account',
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