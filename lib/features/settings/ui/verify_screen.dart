import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:socialseed/core/utils/constants/color_const.dart';

// ─── Fake provider (swap with real user data) ────────────────────────────────

final followerCountProvider = Provider<int>((ref) => 950); // swap with real

const int kVerificationThreshold = 1000;

// ─── Screen ──────────────────────────────────────────────────────────────────

class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnim;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    final followers = ref.read(followerCountProvider);
    final target = (followers / kVerificationThreshold).clamp(0.0, 1.0);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _progressAnim = Tween<double>(begin: 0.0, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Slight delay so user sees animation on enter
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestVerification() async {
    setState(() => _isRequesting = true);
    // TODO: wire to real usecase
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isRequesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification request submitted!'),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final followers = ref.watch(followerCountProvider);
    final isEligible = followers >= kVerificationThreshold;
    final remaining = kVerificationThreshold - followers;

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColor.blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verification',
          style: TextStyle(
            color: AppColor.blackColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Circular Progress ──
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (_, __) => _VerifyRing(
                  progress: _progressAnim.value,
                  isEligible: isEligible,
                  followers: followers,
                ),
              ),

              const SizedBox(height: 36),

              // ── Title ──
              Text(
                isEligible ? 'You\'re eligible!' : 'Almost there',
                style: const TextStyle(
                  color: AppColor.blackColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),

              // ── Subtitle ──
              Text(
                isEligible
                    ? 'You have reached 1,000 followers.\nYou can now request account verification.'
                    : 'You need $remaining more followers to\nunlock account verification.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColor.textGreyColor,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 40),

              // ── Criteria Checklist ──
              _CriteriaList(isEligible: isEligible, followers: followers),

              const Spacer(flex: 3),

              // ── CTA ──
              _VerifyCTA(
                isEligible: isEligible,
                isLoading: _isRequesting,
                onTap: isEligible ? _requestVerification : null,
                remaining: remaining,
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Ring Widget ─────────────────────────────────────────────────────────────

class _VerifyRing extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final bool isEligible;
  final int followers;

  const _VerifyRing({
    required this.progress,
    required this.isEligible,
    required this.followers,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring painter
          CustomPaint(
            size: const Size(180, 180),
            painter: _RingPainter(
              progress: progress,
              isEligible: isEligible,
            ),
          ),

          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: isEligible
                    ? const Icon(
                        Icons.verified_rounded,
                        key: ValueKey('verified'),
                        size: 40,
                        color: AppColor.redColor,
                      )
                    : const Icon(
                        Icons.shield_outlined,
                        key: ValueKey('shield'),
                        size: 36,
                        color: AppColor.textGreyColor,
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                '$followers',
                style: const TextStyle(
                  color: AppColor.blackColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'followers',
                style: TextStyle(
                  color: AppColor.textGreyColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isEligible;

  const _RingPainter({required this.progress, required this.isEligible});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 9.0;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColor.greyColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = AppColor.redColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Tip dot
    final tipAngle = startAngle + 2 * math.pi * progress;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);

    canvas.drawCircle(
      Offset(tipX, tipY),
      strokeWidth / 2,
      Paint()
        ..color = AppColor.redColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.isEligible != isEligible;
}

// ─── Criteria List ────────────────────────────────────────────────────────────

class _CriteriaList extends StatelessWidget {
  final bool isEligible;
  final int followers;

  const _CriteriaList({required this.isEligible, required this.followers});

  @override
  Widget build(BuildContext context) {
    final items = [
      _CriteriaItem(
        label: '1,000 followers',
        met: followers >= kVerificationThreshold,
        detail: '${followers.clamp(0, kVerificationThreshold)} / 1,000',
      ),
      const _CriteriaItem(
        label: 'Account at least 30 days old',
        met: true,
        detail: 'Verified',
      ),
      const _CriteriaItem(
        label: 'Profile photo added',
        met: true,
        detail: 'Verified',
      ),
      const _CriteriaItem(
        label: 'Bio completed',
        met: true,
        detail: 'Verified',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColor.greyColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color:
                            item.met ? AppColor.redColor : AppColor.whiteColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: item.met
                              ? AppColor.redColor
                              : AppColor.greyShadowColor,
                          width: 1.5,
                        ),
                      ),
                      child: item.met
                          ? const Icon(Icons.check_rounded,
                              size: 13, color: AppColor.whiteColor)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: item.met
                              ? AppColor.blackColor
                              : AppColor.textGreyColor,
                          fontSize: 13,
                          fontWeight:
                              item.met ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      item.detail,
                      style: TextStyle(
                        color: item.met
                            ? AppColor.blackColor
                            : AppColor.textGreyColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 50,
                  color: AppColor.greyShadowColor,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _CriteriaItem {
  final String label;
  final bool met;
  final String detail;

  const _CriteriaItem({
    required this.label,
    required this.met,
    required this.detail,
  });
}

// ─── CTA Button ───────────────────────────────────────────────────────────────

class _VerifyCTA extends StatelessWidget {
  final bool isEligible;
  final bool isLoading;
  final VoidCallback? onTap;
  final int remaining;

  const _VerifyCTA({
    required this.isEligible,
    required this.isLoading,
    required this.remaining,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isEligible ? AppColor.redColor : AppColor.greyColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onTap,
                borderRadius: BorderRadius.circular(14),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColor.whiteColor,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isEligible
                                  ? Icons.verified_rounded
                                  : Icons.lock_outline_rounded,
                              size: 18,
                              color: isEligible
                                  ? AppColor.whiteColor
                                  : AppColor.textGreyColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEligible
                                  ? 'Request Verification'
                                  : 'Locked — $remaining more needed',
                              style: TextStyle(
                                color: isEligible
                                    ? AppColor.whiteColor
                                    : AppColor.textGreyColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
        if (!isEligible) ...[
          const SizedBox(height: 10),
          Text(
            'Keep growing your audience to unlock this feature',
            style: const TextStyle(
              color: AppColor.textGreyColor,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
