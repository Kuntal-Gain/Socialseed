import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/services/upload_service.dart';

final uploadImageProvider = Provider<Future<String?> Function(File?)>((ref) {
  final service = UploadService();

  return (File? image) async {
    return await service.uploadImage(image);
  };
});
