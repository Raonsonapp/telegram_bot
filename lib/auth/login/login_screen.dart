import 'package:flutter/material.dart';
import 'login_controller.dart';
import 'login_state.dart';

/// =====================================================
/// LOGIN SCREEN – Raonson
/// -----------------------------------------------------
/// - Username / Email
/// - Password
/// - Validation
/// - Loading / Error handling
/// - Navigation to Register / Forgot Password
/// =====================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = LoginController();

  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await _controller.login(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: StreamBuilder<LoginState>(
          stream: _controller.state,
          initialData: const LoginState.initial(),
          builder: (context, snapshot) {
            final state = snapshot.data!;

            if (state.isSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/home');
              });
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),

                  // ===== LOGO =====
                  Column(
                    children: const [
                      Icon(
                        Icons.auto_awesome,
                        size: 64,
                        color: Colors.white,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Raonson',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ===== FORM =====
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _input(
                          controller: _usernameCtrl,
                          hint: 'Username or email',
                          enabled: !state.isLoading,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        _input(
                          controller: _passwordCtrl,
                          hint: 'Password',
                          obscure: true,
                          enabled: !state.isLoading,
                          validator: (v) =>
                              v == null || v.length < 6
                                  ? 'Min 6 characters'
                                  : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== ERROR =====
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        state.error!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  // ===== LOGIN BUTTON =====
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Log in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== FORGOT PASSWORD =====
                  TextButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(
                                context, '/forgot-password');
                          },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

                  const Spacer(),

                  // ===== REGISTER =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don’t have an account?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                Navigator.pushReplacementNamed(
                                    context, '/register');
                              },
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1C1C1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
