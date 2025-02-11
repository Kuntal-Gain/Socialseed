import 'dart:io';

import 'package:flutter/material.dart';

Widget imageCard1(File? image) {
  return Container(
    margin: const EdgeInsets.all(12),
    height: 250,
    width: double.infinity,
    decoration: const BoxDecoration(),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        image!,
        fit: BoxFit.cover,
      ),
    ),
  );
}

Widget imageCard2(List<File?> images) {
  return Row(
    children: [
      Expanded(
        child: Container(
          margin: const EdgeInsets.all(12),
          height: 250,
          decoration: const BoxDecoration(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              images[0]!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      Expanded(
        child: Container(
          margin: const EdgeInsets.all(12),
          height: 250,
          decoration: const BoxDecoration(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              images[1]!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget imageCard3(List<File?> images) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 125,
              decoration: const BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  images[0]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 125,
              decoration: const BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  images[1]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      Container(
        margin: const EdgeInsets.all(12),
        height: 125,
        width: double.infinity,
        decoration: const BoxDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            images[2]!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ],
  );
}

Widget imageCard4(List<File?> images) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 125,
              decoration: const BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  images[0]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 125,
              decoration: const BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  images[1]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 125,
              decoration: const BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  images[2]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 125,
              decoration: const BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  images[3]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget imageCardN(List<File?> images) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 125,
              decoration: const BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  images[0]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 125,
              decoration: const BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  images[1]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              height: 125,
              decoration: const BoxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  images[2]!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(6),
              height: 125,
              decoration: const BoxDecoration(),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      images[3]!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    color: Colors.black
                        .withOpacity(0.5), // Adjust opacity as needed
                    child: Center(
                      child: Text(
                        "${images.length - 3}+",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
