import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task_comment.dart';

/// Author photo, or initials when there is no avatar.
class TaskCommentAvatar extends StatelessWidget {
  const TaskCommentAvatar({super.key, required this.author, this.radius = 16});

  final TaskCommentAuthor author;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarUrl = author.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.secondaryContainer,
      foregroundImage: hasAvatar
          ? NetworkImage(ApiConstants.absoluteUrl(avatarUrl))
          : null,
      child: Text(
        _initials(author.fullName),
        style: AppTextStyles.labelMedium.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p.characters.first.toUpperCase()).join();
  }
}
