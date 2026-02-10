import 'package:flutter/material.dart';

import 'login_controller.dart';
import 'login_state.dart';
import '../../../utils/validators.dart';
import '../../../widgets/loading_widget.dart';

/// =====================================================
/// LOGIN SCREEN – RAONSON
/// PATH: lib/screens/auth/login/login_screen.dart
/// =====================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  LoginState _state = const LoginState.initial();

  @override
  void initState() {
    super.initState();

    _controller.stream.listen((state) {
      if (!mounted) return;

      setState(() => _state = state);

      if (state.isSuccess) {
        Navigator.pushReplacementNamed(context, '/home');
      }

      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    _controller.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ===== LOGO =====
                  const Text(
                    'Raonson',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ===== USERNAME =====
                  TextFormField(
                    controller: _usernameController,
                    validator: Validators.username,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Username'),
                  ),
                  const SizedBox(height: 14),

                  // ===== PASSWORD =====
                  TextFormField(
                    controller: _passwordController,
                    validator: Validators.password,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Password'),
                  ),
                  const SizedBox(height: 24),

                  // ===== LOGIN BUTTON =====
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: _state.isLoading
                        ? const LoadingWidget()
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF1DB954),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // ===== FORGOT PASSWORD =====
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, '/forgot-password');
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== REGISTER =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No account?',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, '/register');
                        },
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            color: Color(0xFF1DB954),
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  // ===== INPUT DECORATION =====
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
