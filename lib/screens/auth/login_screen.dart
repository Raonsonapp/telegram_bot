import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/loading.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.login(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;
      widget.onLoginSuccess?.call();
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _logo(),
                const SizedBox(height: 32),
                _form(),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  _errorText(),
                ],
                const SizedBox(height: 20),
                _loginButton(),
                const SizedBox(height: 24),
                _registerLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI PARTS =================

  Widget _logo() {
    return Column(
      children: const [
        Text(
          'Raonson',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Sign in to continue',
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _input(
            controller: _usernameCtrl,
            hint: 'Username or email',
            validator: (v) =>
                v == null || v.isEmpty ? 'Enter username or email' : null,
          ),
          const SizedBox(height: 12),
          _input(
            controller: _passwordCtrl,
            hint: 'Password',
            obscure: true,
            validator: (v) =>
                v == null || v.length < 6 ? 'Password too short' : null,
          ),
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF121212),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _loginButton() {
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
                'Log In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _registerLink() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
      },
      child: const Text(
        "Don't have an account? Sign up",
        style: TextStyle(color: Colors.white70),
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
}
