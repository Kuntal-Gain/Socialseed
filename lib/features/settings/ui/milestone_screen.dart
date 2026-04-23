import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:socialseed/core/utils/constants/color_const.dart';
import 'package:socialseed/core/utils/helpers/appbar.dart';
import 'package:socialseed/features/settings/model/milestones_model.dart';
import 'package:socialseed/features/settings/ui/provider/milestone_provider.dart';
import 'package:uuid/uuid.dart';

class MilestoneScreen extends ConsumerWidget {
  const MilestoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(milestonesProvider);

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: CommonAppbar(title: "Milestones"),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBottomSheet(context, ref),
        backgroundColor: AppColor.redColor,
        child: const Icon(Icons.add, color: AppColor.whiteColor),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppColor.redColor)),
        ),
        data: (milestones) {
          if (milestones.isEmpty) {
            return _EmptyState(
                onAdd: () => _showCreateBottomSheet(context, ref));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.03,
            ),
            itemCount: milestones.length,
            itemBuilder: (context, index) {
              // Fake progress seeded from index for now
              final fakeProgress = ((index + 1) * 17) % 100 / 100.0;
              return _MilestoneTile(
                milestone: milestones[index],
                progress: fakeProgress,
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateMilestoneSheet(ref: ref),
    );
  }
}

// ─── Milestone Tile ──────────────────────────────────────────────────────────

class _MilestoneTile extends StatelessWidget {
  final MilestoneModel milestone;
  final double progress; // 0.0 – 1.0

  const _MilestoneTile({required this.milestone, required this.progress});

  IconData get _iconForType {
    return switch (milestone.type) {
      MilestoneType.followers => Icons.people_alt_outlined,
      MilestoneType.posts => Icons.grid_on_outlined,
      MilestoneType.likes => Icons.favorite_border,
      MilestoneType.streak => Icons.local_fire_department_outlined,
      MilestoneType.custom => Icons.star_border_rounded,
      _ => Icons.star_border_rounded,
    };
  }

  Color get _accentForType {
    return switch (milestone.type) {
      _ => AppColor.redColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForType;
    final currentValue = ((milestone.maxValue ?? 0) * progress).toInt();

    return Container(
      decoration: BoxDecoration(
        color: AppColor.greyColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconForType, color: accent, size: 20),
          ),
          const SizedBox(height: 10),

          // Label
          Text(
            milestone.label ?? "--",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColor.blackColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),

          // Description
          Text(
            milestone.description ?? "--",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColor.textGreyColor,
              fontSize: 11,
              height: 1.4,
            ),
          ),

          SizedBox(height: 20),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColor.greyShadowColor.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 6),

          // Progress label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentValue',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              Text(
                '/ ${milestone.maxValue}',
                style: const TextStyle(
                  color: AppColor.textGreyColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_outlined,
              size: 64, color: AppColor.greyShadowColor),
          const SizedBox(height: 16),
          const Text(
            'No milestones yet',
            style: TextStyle(
              color: AppColor.blackColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + to create your first milestone',
            style: TextStyle(color: AppColor.textGreyColor, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onAdd,
            child: const Text('Create Milestone'),
          ),
        ],
      ),
    );
  }
}

// ─── Create Bottom Sheet ─────────────────────────────────────────────────────

class _CreateMilestoneSheet extends StatefulWidget {
  final WidgetRef ref;
  const _CreateMilestoneSheet({required this.ref});

  @override
  State<_CreateMilestoneSheet> createState() => _CreateMilestoneSheetState();
}

class _CreateMilestoneSheetState extends State<_CreateMilestoneSheet> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _maxValueCtrl = TextEditingController();
  MilestoneType _selectedType = MilestoneType.custom;
  bool _isLoading = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _descCtrl.dispose();
    _maxValueCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final milestone = MilestoneModel(
      id: const Uuid().v4(),
      label: _labelCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      maxValue: int.parse(_maxValueCtrl.text.trim()),
      type: _selectedType,
    );

    try {
      await widget.ref
          .read(milestonesProvider.notifier)
          .createMilestone(milestone);

      widget.ref.invalidate(milestonesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColor.redColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.greyShadowColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'New Milestone',
              style: TextStyle(
                color: AppColor.blackColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),

            _buildField(
              controller: _labelCtrl,
              label: 'Label',
              hint: 'e.g. 1K Followers',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            _buildField(
              controller: _descCtrl,
              label: 'Description',
              hint: 'e.g. Reach 1000 followers on your profile',
              maxLines: 2,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            _buildField(
              controller: _maxValueCtrl,
              label: 'Target Value',
              hint: 'e.g. 1000',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (int.tryParse(v.trim()) == null) return 'Must be a number';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Type Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Type',
                  style: TextStyle(
                    color: AppColor.textGreyColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<MilestoneType>(
                  value: _selectedType,
                  decoration: _inputDecoration(hint: ''),
                  style:
                      const TextStyle(color: AppColor.blackColor, fontSize: 14),
                  dropdownColor: AppColor.whiteColor,
                  items: MilestoneType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type.name[0].toUpperCase() + type.name.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedType = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.redColor,
                  foregroundColor: AppColor.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColor.whiteColor,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Milestone',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColor.textGreyColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppColor.blackColor, fontSize: 14),
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColor.greyShadowColor, fontSize: 13),
      filled: true,
      fillColor: AppColor.greyColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColor.redColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColor.blackColor, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColor.redColor, width: 1.2),
      ),
    );
  }
}
