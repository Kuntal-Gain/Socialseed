import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialseed/features/auth_module/model/user_model.dart';
import 'package:socialseed/features/auth_module/ui/provider/creds_provider.dart';

enum RelationType { school, college, work, home }

// implement relationship chip

List<RelationType> resolveRelations(
  ProfileHistory myHistory,
  ProfileHistory friendHistory,
) {
  final relations = <RelationType>[];

  bool isSame(String? a, String? b) {
    if (a == null || b == null) return false;
    if (a.trim().isEmpty || b.trim().isEmpty) return false;
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }

  if (isSame(myHistory.school, friendHistory.school)) {
    relations.add(RelationType.school);
  }

  if (isSame(myHistory.college, friendHistory.college)) {
    relations.add(RelationType.college);
  }

  if (isSame(myHistory.workspace, friendHistory.workspace)) {
    relations.add(RelationType.work);
  }

  print(relations);

  return relations;
}

class RelationshipChip extends ConsumerWidget {
  final ProfileHistory friendProfileHistory;

  const RelationshipChip({
    super.key,
    required this.friendProfileHistory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    final relations = resolveRelations(
      user?.profileHistory ?? ProfileHistory("", "", ""),
      friendProfileHistory,
    );

    if (relations.isEmpty) return const SizedBox();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: relations.map((relation) {
        final color = _getColor(relation);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withAlpha(45),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _getText(relation),
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getText(RelationType type) {
    switch (type) {
      case RelationType.school:
        return "School";
      case RelationType.college:
        return "College";
      case RelationType.work:
        return "Work";
      case RelationType.home:
        return "Home";
    }
  }

  IconData _getIcon(RelationType type) {
    switch (type) {
      case RelationType.school:
        return Icons.school;
      case RelationType.college:
        return Icons.account_balance;
      case RelationType.work:
        return Icons.work;
      case RelationType.home:
        return Icons.home;
    }
  }

  Color _getColor(RelationType type) {
    switch (type) {
      case RelationType.school:
        return Colors.blue;
      case RelationType.college:
        return Colors.purple;
      case RelationType.work:
        return Colors.green;
      case RelationType.home:
        return Colors.orange;
    }
  }
}
