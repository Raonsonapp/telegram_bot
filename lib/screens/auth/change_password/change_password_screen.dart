import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'change_password_controller.dart';
import 'change_password_state.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangePasswordController>(
      create: (_) => ChangePasswordController(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatelessWidget {
  const _ChangePasswordView();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ChangePasswordController>();
    final s = c.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                obscureText: true,
                onChanged: c.setCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Current password',
                  errorText: s.currentError,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                onChanged: c.setNewPassword,
                decoration: InputDecoration(
                  labelText: 'New password',
                  errorText: s.newError,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                onChanged: c.setConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm new password',
                  errorText: s.confirmError,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: s.loading ? null : c.submit,
                  child: s.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update password'),
                ),
              ),
              if (s.generalError != null) ...[
                const SizedBox(height: 12),
                Text(
                  s.generalError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              if (s.success) ...[
                const SizedBox(height: 12),
                const Text(
                  'Password updated successfully',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
