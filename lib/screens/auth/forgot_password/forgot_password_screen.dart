import 'package:flutter/material.dart';

import '../../../core/network_checker.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/empty_state_widget.dart';
import 'forgot_password_controller.dart';
import 'forgot_password_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final ForgotPasswordController _controller;
  late ForgotPasswordState _state;

  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _state = ForgotPasswordState.initial();
    _controller = ForgotPasswordController(onStateChanged: _onStateChanged);
  }

  void _onStateChanged(ForgotPasswordState newState) {
    if (!mounted) return;
    setState(() => _state = newState);

    if (newState.status == ForgotPasswordStatus.success) {
      _showSuccessDialog();
    }

    if (newState.status == ForgotPasswordStatus.error &&
        newState.errorMessage != null) {
      _showError(newState.errorMessage!);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final hasNetwork = await NetworkChecker.hasConnection();
    if (!hasNetwork) {
      _showError('No internet connection');
      return;
    }

    await _controller.sendResetLink(
      email: _emailController.text.trim(),
    );
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Check your email'),
          content: const Text(
            'We have sent a password reset link to your email address.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _state.status == ForgotPasswordStatus.loading
              ? const Center(child: LoadingWidget())
              : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          const Icon(
            Icons.lock_reset,
            size: 72,
            color: Colors.blueAccent,
          ),

          const SizedBox(height: 24),

          const Text(
            'Forgot your password?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Enter your email address and we will send you a link to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 32),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _submit,
            child: const Text('Send reset link'),
          ),

          const SizedBox(height: 16),

          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to login'),
          ),
        ],
      ),
    );
  }
}
