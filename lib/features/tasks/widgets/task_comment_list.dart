import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task_comment.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_comment_tile.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Comments oldest first, with a "load more" control for newer pages.
/// Lives inside the details screen's scroll view, so it does not scroll.
class TaskCommentList extends StatelessWidget {
  const TaskCommentList({
    super.key,
    required this.comments,
    required this.currentUserId,
    required this.hasMore,
    required this.loadingMore,
    required this.loadMoreFailed,
    required this.onLoadMore,
  });

  final List<TaskComment> comments;
  final String? currentUserId;
  final bool hasMore;
  final bool loadingMore;
  final bool loadMoreFailed;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        for (final comment in comments)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.space3),
            child: TaskCommentTile(
              comment: comment,
              isOwn: comment.author.id == currentUserId,
            ),
          ),
        if (hasMore)
          loadingMore
              ? const Padding(
                  padding: EdgeInsets.all(AppDimensions.space2),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton.icon(
                  onPressed: onLoadMore,
                  icon: const Icon(Icons.expand_more_rounded),
                  label: Text(
                    loadMoreFailed
                        ? l10n.commentsLoadMoreFailed
                        : l10n.commentsLoadMore,
                  ),
                ),
      ],
    );
  }
}
