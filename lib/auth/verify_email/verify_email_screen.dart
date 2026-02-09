import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'verify_email_controller.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VerifyEmailController(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Verify email')),
        body: Consumer<VerifyEmailController>(
          builder: (context, controller, _) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(labelText: 'Code'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Enter code' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          controller.verifyCode(_codeController.text.trim());
                        }
                      },
                      child: Text(controller.verified ? 'Verified!' : 'Verify'),
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
