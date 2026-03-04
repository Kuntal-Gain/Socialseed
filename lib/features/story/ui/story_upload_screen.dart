import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';

import 'story_editor_screen.dart';

class StoryUploadScreen extends StatefulWidget {
  const StoryUploadScreen({super.key});

  @override
  State<StoryUploadScreen> createState() => _StoryUploadScreenState();
}

class _StoryUploadScreenState extends State<StoryUploadScreen> {
  List<AssetEntity> _assets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    final permission = await PhotoManager.requestPermissionExtend();

    print(permission);
    if (!permission.isAuth) {
      setState(() => _loading = false);
      return;
    }
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (albums.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final assets = await albums.first.getAssetListPaged(page: 0, size: 80);
    setState(() {
      _assets = assets;
      _loading = false;
    });
  }

  void _openEditor({File? file, bool isText = false}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a1, a2) =>
            StoryEditorScreen(imageFile: file, isTextStory: isText),
        transitionsBuilder: (_, a1, a2, child) => FadeTransition(
          opacity: a1,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _onAssetTap(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null && mounted) _openEditor(file: file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.blackColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: AppColor.blackColor, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'New Story',
                    style: TextStyle(
                      color: AppColor.blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Story type cards row ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  // Text Story Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openEditor(isText: true),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xffFF3131), Color(0xffff6b6b)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          children: [
                            // Decorative circles
                            Positioned(
                              top: -10,
                              right: -10,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.whiteColor.withOpacity(0.1),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -15,
                              left: 10,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.whiteColor.withOpacity(0.08),
                                ),
                              ),
                            ),
                            const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.text_fields_rounded,
                                      color: AppColor.whiteColor, size: 28),
                                  SizedBox(height: 6),
                                  Text(
                                    'Text',
                                    style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Image Story Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // open camera or pick first asset
                        if (_assets.isNotEmpty) _onAssetTap(_assets.first);
                      },
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColor.blackColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColor.blackColor.withOpacity(0.15)),
                        ),
                        child: Stack(
                          children: [
                            // Positioned(
                            //   top: -8,
                            //   left: -8,
                            //   child: Container(
                            //     width: 50,
                            //     height: 50,
                            //     decoration: BoxDecoration(
                            //       shape: BoxShape.circle,
                            //       color:
                            //           const Color(0xffFF3131).withOpacity(0.15),
                            //     ),
                            //   ),
                            // ),
                            const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined,
                                      color: AppColor.blackColor, size: 28),
                                  SizedBox(height: 6),
                                  Text(
                                    'Image',
                                    style: TextStyle(
                                      color: AppColor.blackColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Divider ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                      child: Divider(
                          color: AppColor.blackColor.withOpacity(0.15),
                          height: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'GALLERY',
                      style: TextStyle(
                        color: AppColor.blackColor.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Divider(
                          color: AppColor.blackColor.withOpacity(0.15),
                          height: 1)),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Gallery grid ───────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xffFF3131)))
                  : _assets.isEmpty
                      ? Center(
                          child: Text(
                            'No photos found',
                            style: TextStyle(
                                color: AppColor.blackColor.withOpacity(0.5)),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          itemCount: _assets.length,
                          itemBuilder: (context, index) {
                            return _GalleryTile(
                              asset: _assets[index],
                              onTap: () => _onAssetTap(_assets[index]),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryTile extends StatefulWidget {
  final AssetEntity asset;
  final VoidCallback onTap;
  const _GalleryTile({required this.asset, required this.onTap});

  @override
  State<_GalleryTile> createState() => _GalleryTileState();
}

class _GalleryTileState extends State<_GalleryTile> {
  Uint8List? _thumb;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bytes = await widget.asset.thumbnailDataWithSize(
      const ThumbnailSize(300, 300),
    );
    if (mounted) setState(() => _thumb = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        child: _thumb == null
            ? Container(color: Colors.grey.shade900)
            : Image.memory(_thumb!, fit: BoxFit.cover),
      ),
    );
  }
}
