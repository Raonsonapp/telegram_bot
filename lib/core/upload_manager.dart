import 'dart:io';

class UploadManager {
  Future<String> uploadMedia(File file) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return file.path;
  }
}
