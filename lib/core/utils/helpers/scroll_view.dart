import 'package:flutter/material.dart';

class CommonScreenWrapper extends StatelessWidget {
  final Widget? header;
  final Widget body;
  final bool containsScrollable;

  const CommonScreenWrapper({
    super.key,
    this.header,
    required this.body,
    this.containsScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (containsScrollable) {
      // ✅ Sliver approach: pins footer at bottom on short content
      return CustomScrollView(
        slivers: [
          if (header != null) SliverToBoxAdapter(child: header!),

          // NOTE: If `body` contains a ListView, make it NON-scrollable.
          SliverToBoxAdapter(child: body),
        ],
      );
    }

    // ✅ Non-scrollable pages (safe to use IntrinsicHeight)
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (header != null) header!,
                  Expanded(child: body),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
