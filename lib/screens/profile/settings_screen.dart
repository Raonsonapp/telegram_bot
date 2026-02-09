import 'package:flutter/material.dart';

import '../../core/session.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _privateAccount = false;
  bool _notifications = true;
  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) return;

    setState(() => _loggingOut = true);

    await AuthService.logout();
    await Session.clear();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          onRegisterTap: () {},
          onLoginSuccess: () {},
        ),
      ),
      (_) => false,
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }

  Widget _item({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _sectionTitle('Account'),

          _item(
            title: 'Change password',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password change coming soon'),
                ),
              );
            },
          ),

          SwitchListTile(
            title: const Text('Private account'),
            subtitle: const Text('Only followers can see your posts'),
            value: _privateAccount,
            onChanged: (v) {
              setState(() => _privateAccount = v);
              // TODO: connect to server
            },
          ),

          _sectionTitle('Notifications'),

          SwitchListTile(
            title: const Text('Push notifications'),
            value: _notifications,
            onChanged: (v) {
              setState(() => _notifications = v);
              // TODO: connect to server
            },
          ),

          _sectionTitle('Storage'),

          _item(
            title: 'Clear cache',
            onTap: () async {
              await Session.clear();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
          ),

          const Divider(height: 32),

          _item(
            title: 'Log out',
            trailing: _loggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _logout,
          ),

          const SizedBox(height: 24),

          Center(
            child: Text(
              'Raonson v5.0.0',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
