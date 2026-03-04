import 'package:flutter/material.dart';

/// Base function to show animated snackbars with a close button
void _showAnimatedSnackBar({
  required BuildContext context,
  required String message,
  required Color backgroundColor,
  required Color accentColor,
  IconData? icon,
}) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    padding: EdgeInsets.zero,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    duration: const Duration(seconds: 5),
    content: TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 24),
            child: child,
          ),
        );
      },
      child: _SnackBarContent(
        message: message,
        backgroundColor: backgroundColor,
        accentColor: accentColor,
        icon: icon,
        outerContext: context,
      ),
    ),
  );

  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(snackBar);
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color accentColor;
  final IconData? icon;
  final BuildContext outerContext;

  const _SnackBarContent({
    required this.message,
    required this.backgroundColor,
    required this.accentColor,
    required this.icon,
    required this.outerContext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 13),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.1,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () =>
                ScaffoldMessenger.of(outerContext).hideCurrentSnackBar(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Success snackbar
void successBar(BuildContext context, String message) {
  _showAnimatedSnackBar(
    context: context,
    message: message,
    backgroundColor: Colors.green.shade600,
    accentColor: Colors.green.shade800,
    icon: Icons.check_circle_rounded,
  );
}

/// Failure snackbar
void failureBar(BuildContext context, String message) {
  _showAnimatedSnackBar(
    context: context,
    message: message,
    backgroundColor: Colors.red.shade600,
    accentColor: Colors.red.shade800,
    icon: Icons.error_rounded,
  );
}

/// Pending snackbar
void pendingBar(BuildContext context, String message) {
  _showAnimatedSnackBar(
    context: context,
    message: message,
    backgroundColor: Colors.amber.shade700,
    accentColor: Colors.amber.shade900,
    icon: Icons.hourglass_top_rounded,
  );
}
