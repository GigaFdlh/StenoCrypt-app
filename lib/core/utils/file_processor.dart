import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FileProcessor {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}
