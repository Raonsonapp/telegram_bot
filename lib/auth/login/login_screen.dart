import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/session_manager.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/validators.dart';
import '../auth_repository.dart';
import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = context.read<SessionManager>();

    return ChangeNotifierProvider(
      create: (_) => LoginController(AuthRepository(), sessionManager),
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Consumer<LoginController>(
          builder: (context, controller, _) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 24),
                    if (controller.error != null)
                      Text(
                        controller.error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: controller.loading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                controller.login(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                              }
                            },
                      child: controller.loading
                          ? const LoadingWidget(size: 18)
                          : const Text('Login'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
