import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:socialseed/core/utils/constants/color_const.dart';

class NoDataFoundWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRefresh;
  final String? actionButtonText;
  final Color? iconcolor;

  const NoDataFoundWidget({
    super.key,
    this.title = 'No Data Found',
    this.message = 'There is no data available at the moment.',
    this.icon = Ionicons.bulb_outline,
    this.onRefresh,
    this.actionButtonText,
    this.iconcolor,
  });

  @override
  State<NoDataFoundWidget> createState() => _NoDataFoundWidgetState();
}

class _NoDataFoundWidgetState extends State<NoDataFoundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(mq.width * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon Container
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.iconcolor?.withOpacity(0.1) ??
                            AppColor.redColor.withOpacity(0.1),
                        widget.iconcolor?.withOpacity(0.1) ??
                            const Color(0xFF9D8DF1).withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.redColor.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      size: 40,
                      color: widget.iconcolor ?? AppColor.redColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              // Message
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),

              // Action Button
              if (widget.onRefresh != null)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ElevatedButton.icon(
                    onPressed: widget.onRefresh,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: Text(
                      widget.actionButtonText ?? 'Refresh',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.redColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 2,
                      shadowColor: AppColor.redColor.withOpacity(0.3),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
