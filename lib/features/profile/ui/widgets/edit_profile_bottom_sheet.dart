import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialseed/core/provider/utility_provider.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';

class EditProfileBottomSheet extends ConsumerStatefulWidget {
  final User user;
  const EditProfileBottomSheet({super.key, required this.user});

  @override
  ConsumerState<EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState
    extends ConsumerState<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // ── Avatar ────────────────────────────────────────────────────────────────
  File? _pickedAvatar;
  bool _isUploadingAvatar = false;

  // ── Cover Image ───────────────────────────────────────────────────────────
  File? _pickedCover;
  bool _isUploadingCover = false;

  // ── Controllers ──────────────────────────────────────────────────────────
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _emailCtrl;

  // About fields
  late final TextEditingController _workspaceCtrl;
  late final TextEditingController _collegeCtrl;
  late final TextEditingController _schoolCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _countryCtrl;

  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _fullNameCtrl = TextEditingController(text: u.fullName ?? '');
    _usernameCtrl = TextEditingController(text: u.username ?? '');
    _bioCtrl = TextEditingController(text: u.bio ?? '');
    _emailCtrl = TextEditingController(text: u.email ?? '');
    _workspaceCtrl =
        TextEditingController(text: u.profileHistory?.workspace ?? '');
    _collegeCtrl = TextEditingController(text: u.profileHistory?.college ?? '');
    _schoolCtrl = TextEditingController(text: u.profileHistory?.school ?? '');
    _cityCtrl = TextEditingController(text: u.address?.city ?? '');
    _stateCtrl = TextEditingController(text: u.address?.state ?? '');
    _countryCtrl = TextEditingController(text: u.address?.country ?? '');

    final dob = u.dateOfBirth;
    if (dob != null) _selectedDob = dob.toDate();
  }

  @override
  void dispose() {
    for (final c in [
      _fullNameCtrl,
      _usernameCtrl,
      _bioCtrl,
      _emailCtrl,
      _workspaceCtrl,
      _collegeCtrl,
      _schoolCtrl,
      _cityCtrl,
      _stateCtrl,
      _countryCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Pick cover image ──────────────────────────────────────────────────────
  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xffFF3131)),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xffFF3131)),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );

    if (picked != null) {
      setState(() => _pickedCover = File(picked.path));
    }
  }

  /// Uploads cover image to Firebase Storage and returns the download URL.
  Future<String?> _uploadCover() async {
    if (_pickedCover == null) return null;

    setState(() => _isUploadingCover = true);

    try {
      final upload = ref.read(uploadImageProvider);
      final url = await upload(_pickedCover);
      return url;
    } catch (e) {
      debugPrint("Cover upload failed: $e");
      return null;
    } finally {
      if (mounted) {
        setState(() => _isUploadingCover = false);
      }
    }
  }

  // ── Pick avatar ───────────────────────────────────────────────────────────
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xffFF3131)),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xffFF3131)),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
    );

    if (picked != null) {
      setState(() => _pickedAvatar = File(picked.path));
    }
  }

  /// Uploads avatar to Firebase Storage and returns the download URL.
  Future<String?> _uploadAvatar() async {
    if (_pickedAvatar == null) return null;

    setState(() => _isUploadingAvatar = true);

    try {
      final upload = ref.read(uploadImageProvider);

      final url = await upload(_pickedAvatar);

      return url;
    } catch (e) {
      debugPrint("Avatar upload failed: $e");
      return null;
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      // Upload cover first (if a new one was picked)
      final coverUrl =
          _pickedCover != null ? await _uploadCover() : widget.user.cover;

      // Upload avatar (if a new one was picked)
      final avatarUrl =
          _pickedAvatar != null ? await _uploadAvatar() : widget.user.avatar;

      final updatedUser = widget.user.copyWith(
        fullName: _fullNameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        avatar: avatarUrl,
        cover: coverUrl,
        dateOfBirth: _selectedDob != null
            ? Timestamp.fromDate(_selectedDob!)
            : widget.user.dateOfBirth,
        profileHistory: ProfileHistory(
          _schoolCtrl.text.trim(),
          _collegeCtrl.text.trim(),
          _workspaceCtrl.text.trim(),
        ),
        address: Address(
          _cityCtrl.text.trim(),
          _stateCtrl.text.trim(),
          _countryCtrl.text.trim(),
        ),
      );

      ref.watch(credsProvider.notifier).updateUser(updatedUser);

      ref.invalidate(credsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xffFF3131),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── DOB picker ───────────────────────────────────────────────────────────
  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xffFF3131),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDob = picked);
  }

  // ── UI helpers ────────────────────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          Container(width: 3, height: 16, color: const Color(0xffFF3131)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xffFF3131)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xffFF3131), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _dobField() {
    final label = _selectedDob != null
        ? '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}'
        : 'Select Birthday';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: _pickDob,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.cake_outlined,
                  size: 20, color: Color(0xffFF3131)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Birthday',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cover + Avatar composite widget ──────────────────────────────────────
  Widget _coverAndAvatarSection() {
    // Resolve cover image provider
    ImageProvider? coverImageProvider;
    if (_pickedCover != null) {
      coverImageProvider = FileImage(_pickedCover!);
    } else if (widget.user.cover != null && widget.user.cover!.isNotEmpty) {
      coverImageProvider = NetworkImage(widget.user.cover!);
    }

    // Resolve avatar image provider
    ImageProvider? avatarImageProvider;
    if (_pickedAvatar != null) {
      avatarImageProvider = FileImage(_pickedAvatar!);
    } else if (widget.user.avatar != null && widget.user.avatar!.isNotEmpty) {
      avatarImageProvider = NetworkImage(widget.user.avatar!);
    }

    return Column(
      children: [
        // ── Cover image area ─────────────────────────────────────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Cover container
            GestureDetector(
              onTap: _pickCover,
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                  image: coverImageProvider != null
                      ? DecorationImage(
                          image: coverImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: coverImageProvider == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined,
                              size: 32, color: Colors.grey.shade400),
                          const SizedBox(height: 6),
                          Text(
                            'Add cover photo',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),

            // Cover upload loading overlay
            if (_isUploadingCover)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.4),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),

            // Cover edit badge (top-right)
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: _pickCover,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, size: 13, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Edit cover',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Avatar overlapping cover ───────────────────────────────────
            Positioned(
              bottom: -40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // White ring + avatar
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xffFF3131),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: avatarImageProvider,
                            child: avatarImageProvider == null
                                ? Icon(Icons.person,
                                    size: 40, color: Colors.grey.shade400)
                                : null,
                          ),
                        ),
                      ),

                      // Avatar upload overlay
                      if (_isUploadingAvatar)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.4),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),

                      // Camera badge on avatar
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Color(0xffFF3131),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Space to account for avatar overflow below cover
        const SizedBox(height: 52),

        // "Tap to change photo" hint centered under avatar
        Center(
          child: Text(
            'Tap avatar to change',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Handle + header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 18, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Divider(color: Colors.grey.shade200),
                  ],
                ),
              ),

              // ── Scrollable form ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Cover + Avatar ─────────────────────────────
                        const SizedBox(height: 16),
                        _coverAndAvatarSection(),

                        // ── Basic Info ─────────────────────────────────
                        _sectionHeader('Basic Info'),
                        _field(
                          controller: _fullNameCtrl,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        _field(
                          controller: _usernameCtrl,
                          label: 'Username',
                          icon: Icons.alternate_email,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        _field(
                          controller: _bioCtrl,
                          label: 'Bio',
                          icon: Icons.edit_note_outlined,
                          maxLines: 3,
                        ),

                        // ── Overview ───────────────────────────────────
                        _sectionHeader('Overview'),
                        _dobField(),
                        _field(
                          controller: _emailCtrl,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            if (!v.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),

                        // ── Work & Education ───────────────────────────
                        _sectionHeader('Work & Education'),
                        _field(
                          controller: _workspaceCtrl,
                          label: 'Works at',
                          icon: Icons.business_outlined,
                        ),
                        _field(
                          controller: _collegeCtrl,
                          label: 'College',
                          icon: Icons.school_outlined,
                        ),
                        _field(
                          controller: _schoolCtrl,
                          label: 'High School',
                          icon: Icons.school_outlined,
                        ),

                        // ── Location ───────────────────────────────────
                        _sectionHeader('Location'),
                        _field(
                          controller: _cityCtrl,
                          label: 'City',
                          icon: Icons.location_on_outlined,
                        ),
                        _field(
                          controller: _stateCtrl,
                          label: 'State',
                          icon: Icons.home_outlined,
                        ),
                        _field(
                          controller: _countryCtrl,
                          label: 'Country',
                          icon: Icons.flag_outlined,
                        ),

                        const SizedBox(height: 8),

                        // ── Save Button ────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffFF3131),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xffFF3131).withOpacity(0.6),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
