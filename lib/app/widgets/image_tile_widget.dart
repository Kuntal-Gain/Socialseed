import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget imageTile({required String imageId}) {
  return GestureDetector(
    child: Container(
      height: 125,
      width: double.infinity,
      padding: const EdgeInsets.all(6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: imageId,
          placeholder: (ctx, url) => Container(
            color: Colors.grey,
          ),
          errorWidget: (ctx, url, err) => const Icon(Icons.error),
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}
