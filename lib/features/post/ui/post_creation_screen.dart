import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/app_loader.dart';
import 'package:socialseed/core/utils/helpers/failure_widget.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';
import 'package:socialseed/features/post/model/post_model.dart';
import 'package:socialseed/features/post/ui/provider/post_provider.dart';

class PostCreationScreen extends ConsumerStatefulWidget {
  const PostCreationScreen({super.key});

  @override
  ConsumerState<PostCreationScreen> createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends ConsumerState<PostCreationScreen> {
  final TextEditingController _captionController = TextEditingController();
  final List<String> _selectedAssets = [];
  String? _selectedLocation;
  final List<String> _taggedUsers = [];

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _addAsset() {
    // Simulate asset picker
    setState(() {
      _selectedAssets.add(
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400');
    });
  }

  void _removeAsset(int index) {
    setState(() {
      _selectedAssets.removeAt(index);
    });
  }

  void _selectLocation() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ...['New York, USA', 'London, UK', 'Tokyo, Japan', 'Paris, France']
                .map(
              (location) => ListTile(
                leading:
                    const Icon(Icons.location_on, color: Color(0xffFF3131)),
                title: Text(location),
                onTap: () {
                  setState(() {
                    _selectedLocation = location;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tagUsers() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tag People',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ...['@johndoe', '@janesmith', '@alexchen', '@sarahpark'].map(
              (user) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    user[1].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                title: Text(user),
                trailing: _taggedUsers.contains(user)
                    ? const Icon(Icons.check_circle, color: Color(0xffFF3131))
                    : null,
                onTap: () {
                  setState(() {
                    if (_taggedUsers.contains(user)) {
                      _taggedUsers.remove(user);
                    } else {
                      _taggedUsers.add(user);
                    }
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createPost() async {
    final user = ref.read(credsProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post')),
      );
      return;
    }

    if (_captionController.text.isEmpty && _selectedAssets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some text or media to post')),
      );
      return;
    }

    // Show loader while posting
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final newPost = PostModel(
        creator: CreatorModel(
            uid: user.uid,
            name: user.fullName,
            avatarUrl: user.avatar,
            profileHistory: user.profileHistory),
        creatorUid: user.uid,
        type: _selectedAssets.isEmpty ? PostType.text : PostType.image,
        content: _captionController.text,
        assets: _selectedAssets,
      );

      await ref.read(feedProvider.notifier).createPost(newPost);

      // Close loader
      Navigator.pop(context);

      // Show success
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Success'),
          content: const Text('Your post has been created!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xffFF3131)),
              ),
            ),
          ],
        ),
      );

      // Clear fields
      setState(() {
        _captionController.clear();
        _selectedAssets.clear();
        _selectedLocation = null;
        _taggedUsers.clear();
      });
    } catch (e) {
      Navigator.pop(context); // Close loader if error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // User Info Section
            Consumer(builder: (ctx, ref, child) {
              final state = ref.watch(credsProvider);

              return state.when(
                data: (user) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: NetworkImage(user?.avatar ?? ''),
                          onBackgroundImageError: (err, st) => NetworkImage(
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Public',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                error: (err, st) => errorWidget(err, st),
                loading: () => AppLoader().stateLoader(),
              );
            }),

            // Caption Field
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _captionController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            const SizedBox(height: 16),

            // Assets Upload Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Media',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Assets Grid
                  _selectedAssets.isEmpty
                      ? GestureDetector(
                          onTap: _addAsset,
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xffFF3131).withOpacity(0.3),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 48,
                                    color: Color(0xffFF3131),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Photos or Videos',
                                    style: TextStyle(
                                      color: Color(0xffFF3131),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _selectedAssets.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _selectedAssets.length) {
                              return GestureDetector(
                                onTap: _addAsset,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xffFF3131)
                                          .withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Color(0xffFF3131),
                                    size: 32,
                                  ),
                                ),
                              );
                            }
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(_selectedAssets[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeAsset(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Location Button
                  _buildActionButton(
                    icon: Icons.location_on_outlined,
                    label: _selectedLocation ?? 'Add Location',
                    hasValue: _selectedLocation != null,
                    onTap: _selectLocation,
                  ),
                  const SizedBox(height: 12),

                  // Tag Users Button
                  _buildActionButton(
                    icon: Icons.person_add_outlined,
                    label: _taggedUsers.isEmpty
                        ? 'Tag People'
                        : '${_taggedUsers.length} people tagged',
                    hasValue: _taggedUsers.isNotEmpty,
                    onTap: _tagUsers,
                  ),

                  const SizedBox(height: 12),

                  // Feeling/Activity Button
                  _buildActionButton(
                    icon: Icons.sentiment_satisfied_outlined,
                    label: 'Feeling/Activity',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tagged Users Chips
            if (_taggedUsers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tagged',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _taggedUsers.map((user) {
                        return Chip(
                          label: Text(user),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _taggedUsers.remove(user);
                            });
                          },
                          backgroundColor:
                              const Color(0xffFF3131).withOpacity(0.1),
                          labelStyle: const TextStyle(
                            color: Color(0xffFF3131),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          deleteIconColor: const Color(0xffFF3131),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
          ],
        ),
      ),

      // Post Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _createPost,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffFF3131),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Post',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool hasValue = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? const Color(0xffFF3131).withOpacity(0.3)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: hasValue ? const Color(0xffFF3131) : Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color:
                    hasValue ? const Color(0xffFF3131) : Colors.grey.shade700,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
