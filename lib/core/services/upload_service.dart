import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:socialseed/core/utils/constants/app_strings.dart';

class UploadService {
  /// Uploads an image file to Cloudinary and returns the URL
  Future<String?> uploadImage(File? image) async {
    if (image == null) return null;

    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppStrings.cloudName}/image/upload');

    // Create multipart request
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppStrings.dbName
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        // Return the secure URL
        return data['secure_url'] as String?;
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Upload failed: ${response.statusCode} -> $responseBody');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
