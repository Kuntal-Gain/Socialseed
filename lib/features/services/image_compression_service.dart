import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressionService {
  Future<XFile?> compressImage(File file) async {
    // Original size
    final originalSize = await file.length();
    debugPrint("Original Size: ${(originalSize / 1024).toStringAsFixed(2)} KB");
    final dir = await getTemporaryDirectory();
    final targetPath =
        "${dir.absolute.path}/${basename(file.path).split(".").first} _compressed.jpg";

    var res = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    if (res != null) {
      final compressedSize = await res.length();
      debugPrint(
          "Compressed Size: ${(compressedSize / 1024).toStringAsFixed(2)} KB (${(((originalSize - compressedSize) / originalSize) * 100).toStringAsFixed(2)}% reduction)");
    } else {
      debugPrint("Compression failed");
    }
    return res;
  }
}
