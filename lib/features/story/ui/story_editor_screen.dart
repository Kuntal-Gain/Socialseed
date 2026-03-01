import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/provider/utility_provider.dart';
import 'package:socialseed/features/story/model/story_model.dart';
import 'package:socialseed/features/story/ui/provider/story_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoryEditorScreen
// ─────────────────────────────────────────────────────────────────────────────

class StoryEditorScreen extends StatefulWidget {
  final File? imageFile;
  final bool isTextStory;

  const StoryEditorScreen({
    super.key,
    this.imageFile,
    this.isTextStory = false,
  });

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int _bgIndex = 0;

  static const _bgGradients = [
    [Color(0xff1a1a2e), Color(0xff16213e)],
    [Color(0xffFF3131), Color(0xffff6b6b)],
    [Color(0xff0f3460), Color(0xff533483)],
    [Color(0xff2d6a4f), Color(0xff40916c)],
    [Color(0xff7209b7), Color(0xff3a0ca3)],
    [Color(0xfff77f00), Color(0xffd62828)],
    [Color(0xff023e8a), Color(0xff0096c7)],
    [Color(0xff1b1b1b), Color(0xff3a3a3a)],
  ];

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ─────────────────────────────────────────────────
          widget.isTextStory ? _buildTextBg() : _buildImageBg(),

          // ── Foreground layout ──────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                if (widget.isTextStory) ...[
                  const Spacer(),
                  _buildTextInput(),
                  const Spacer(),
                ],
              ],
            ),
          ),

          // ── Color picker – sits just above the bottom action bar ────────
          if (widget.isTextStory)
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom + 90,
              left: 0,
              right: 0,
              child: _buildColorPicker(),
            ),

          // ── Bottom bar (image story) ────────────────────────────────────
          if (!widget.isTextStory)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(child: _buildBottomBar()),
            ),

          // ── Bottom bar (text story – floats above keyboard) ────────────
          if (widget.isTextStory)
            Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: MediaQuery.of(context).viewInsets.bottom == 0,
                child: _buildBottomBar(),
              ),
            ),
        ],
      ),
    );
  }

  // ── Backgrounds ───────────────────────────────────────────────────────────

  Widget _buildImageBg() {
    if (widget.imageFile != null) {
      return Image.file(widget.imageFile!, fit: BoxFit.cover);
    }
    return Container(color: Colors.black);
  }

  Widget _buildTextBg() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _bgGradients[_bgIndex],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // ── Text input (text story only) ──────────────────────────────────────────

  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        autofocus: true,
        maxLines: null,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.4,
          shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
        ),
        decoration: const InputDecoration(
          hintText: 'Start typing…',
          hintStyle: TextStyle(
            color: Colors.white38,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
        ),
        cursorColor: Colors.white,
      ),
    );
  }

  // ── Color picker row ──────────────────────────────────────────────────────

  Widget _buildColorPicker() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _bgGradients.length,
        itemBuilder: (_, i) {
          final selected = _bgIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _bgIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: EdgeInsets.symmetric(
                  horizontal: 5, vertical: selected ? 0 : 4),
              width: selected ? 38 : 30,
              height: selected ? 38 : 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _bgGradients[i],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: selected ? Colors.white : Colors.white30,
                  width: selected ? 2.5 : 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _bgGradients[i][0].withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _CircleIconBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          if (widget.isTextStory)
            _CircleIconBtn(
              icon: Icons.shuffle_rounded,
              onTap: () => setState(
                  () => _bgIndex = (_bgIndex + 1) % _bgGradients.length),
            ),
        ],
      ),
    );
  }

  // ── Bottom bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Consumer(builder: (context, ref, child) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            // Discard
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Text(
                  'Discard',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const Spacer(),

            // Post Story
            GestureDetector(
              onTap: () async {
                if (widget.isTextStory && _textController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Write something first!'),
                      backgroundColor: Colors.black87,
                    ),
                  );
                  return;
                }

                final uploadImage = ref.read(uploadImageProvider);

                final url = await uploadImage(widget.imageFile);

                ref.read(storyNotifierProvider.notifier).createStory(StoryAsset(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      type: widget.isTextStory
                          ? StoryAssetType.text
                          : StoryAssetType.image,
                      url: url,
                      caption: _textController.text.trim(),
                      createdAt: Timestamp.now(),
                      bg: '#FFFFFF',
                    ));

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffFF3131), Color(0xffff6b6b)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffFF3131).withOpacity(0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Post Story',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable circle icon button
// ─────────────────────────────────────────────────────────────────────────────

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
