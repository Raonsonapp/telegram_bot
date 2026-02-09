import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../core/upload_service.dart';
import '../../widgets/avatar.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _bioCtrl = TextEditingController();
  bool _saving = false;

  File? _avatarFile;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _bioCtrl.text = widget.user.bio;
    _avatarUrl = widget.user.avatar;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() {
        _avatarFile = File(file.path);
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() => _saving = true);

    String? avatarUrl = _avatarUrl;

    if (_avatarFile != null) {
      avatarUrl = await UploadService.uploadImage(_avatarFile!);
    }

    await UserService.updateProfile(
      bio: _bioCtrl.text.trim(),
      avatar: avatarUrl,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: Avatar(
                    imageUrl: _avatarFile != null
                        ? _avatarFile!.path
                        : _avatarUrl,
                    size: 96,
                    isFile: _avatarFile != null,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _pickAvatar,
                  child: const Text('Change profile photo'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ================= USERNAME =================
          Text(
            'Username',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: widget.user.username,
            enabled: false,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // ================= BIO =================
          Text(
            'Bio',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _bioCtrl,
            maxLines: 3,
            maxLength: 150,
            decoration: const InputDecoration(
              hintText: 'Tell something about yourself',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
