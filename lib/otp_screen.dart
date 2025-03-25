import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'auth_service.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final AuthService authService;
  final bool isLogin;
  
  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.authService,
    required this.isLogin,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) return;
    
    setState(() => _isLoading = true);
    
    try {
      final userCredential = await widget.authService.signInWithOTP(
        verificationId: widget.verificationId,
        otp: _otpController.text,
      );
      
      if (!widget.isLogin && (userCredential.additionalUserInfo?.isNewUser ?? false)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileSetupScreen(
              authService: widget.authService,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isResending = true);
    
    try {
      await widget.authService.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (verificationId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully!')),
          );
        },
        onVerificationFailed: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${error.message}')),
          );
        },
        onVerificationCompleted: (credential) {},
        onCodeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'Enter OTP sent to ${widget.phoneNumber}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: _otpController,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
                activeColor: Theme.of(context).primaryColor,
                selectedColor: Theme.of(context).primaryColor,
                inactiveColor: Colors.grey,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _verifyOTP,
                      child: const Text('Verify OTP'),
                    ),
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _isResending ? null : _resendOTP,
              child: _isResending
                  ? const Text('Resending OTP...')
                  : const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}