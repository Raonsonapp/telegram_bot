import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/loading.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
      _success = false;
    });

    try {
      await AuthService.forgotPassword(
        email: _emailCtrl.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _success = true;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception:', '').trim();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Reset password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _description(),
              const SizedBox(height: 24),
              _form(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                _errorText(),
              ],
              if (_success) ...[
                const SizedBox(height: 12),
                _successText(),
              ],
              const Spacer(),
              _submitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _description() {
    return const Text(
      'Enter your email and we will send you a password reset link.',
      style: TextStyle(color: Colors.white70),
      textAlign: TextAlign.center,
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: TextFormField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Enter your email';
          if (!v.contains('@')) return 'Invalid email';
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF121212),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _loading
            ? const Loading(color: Colors.white)
            : const Text(
                'Send reset link',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _errorText() {
    return Text(
      _error!,
      style: const TextStyle(color: Colors.redAccent),
      textAlign: TextAlign.center,
    );
  }

  Widget _successText() {
    return const Text(
      'Reset link sent. Check your email.',
      style: TextStyle(color: Colors.greenAccent),
      textAlign: TextAlign.center,
    );
  }
}
