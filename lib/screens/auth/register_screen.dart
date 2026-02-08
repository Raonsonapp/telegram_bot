import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../core/session.dart';
import '../../navigation/bottom_nav.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await AuthService.register(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      await Session.saveToken(token);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BottomNav()),
        (_) => false,
      );
    } catch (e) {
      setState(() => _error = 'Registration failed');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),

                const Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Username or phone',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.length < 3 ? 'Too short' : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 chars' : null,
                ),

                const SizedBox(height: 16),

                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Sign up'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
