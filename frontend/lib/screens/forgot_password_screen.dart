import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  int _step = 1; // 1: enter email, 2: enter otp, 3: new password
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  Future<void> _sendOtp() async {
    if (_emailController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final data = await _authService.forgotPassword(_emailController.text.trim());
    setState(() {
      _isLoading = false;
      _isError = data['success'] != true;
      _message = data['message'];
      if (data['success'] == true) _step = 2;
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final data = await _authService.verifyOtp(email: _emailController.text.trim(), otp: _otpController.text.trim());
    setState(() {
      _isLoading = false;
      _isError = data['success'] != true;
      _message = data['message'];
      if (data['success'] == true) _step = 3;
    });
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.length < 6) return;
    setState(() {
      _isLoading = true;
      _message = null;
    });
    final data = await _authService.resetPassword(
      email: _emailController.text.trim(),
      otp: _otpController.text.trim(),
      newPassword: _newPasswordController.text,
    );
    setState(() {
      _isLoading = false;
      _isError = data['success'] != true;
      _message = data['message'];
    });

    if (data['success'] == true) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _message!,
                    style: TextStyle(color: _isError ? Colors.red : Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_step == 1) ...[
                const Text('Enter your registered email. We will send you an OTP.'),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Send OTP'),
                ),
              ] else if (_step == 2) ...[
                Text('Enter the 6-digit OTP sent to ${_emailController.text}'),
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'OTP', prefixIcon: Icon(Icons.pin_outlined)),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Verify OTP'),
                ),
              ] else ...[
                const Text('Enter your new password.'),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.lock_outline)),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Reset Password'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
