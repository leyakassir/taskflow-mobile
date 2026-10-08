import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/features/tasks/data/repositories/task_comment_repository_impl.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task_comment.dart';

final taskCommentsControllerProvider = AsyncNotifierProvider.autoDispose
    .family<TaskCommentsController, TaskCommentsState, String>(
      TaskCommentsController.new,
    );

class TaskCommentsState {
  const TaskCommentsState({
    required this.comments,
    required this.page,
    required this.totalPages,
    this.loadingMore = false,
    this.loadMoreFailed = false,
  });

  /// Oldest first, matching the backend order.
  final List<TaskComment> comments;
  final int page;
  final int totalPages;
  final bool loadingMore;
  final bool loadMoreFailed;

  bool get hasMore => page < totalPages;

  TaskCommentsState copyWith({
    List<TaskComment>? comments,
    int? page,
    int? totalPages,
    bool? loadingMore,
    bool? loadMoreFailed,
  }) {
    return TaskCommentsState(
      comments: comments ?? this.comments,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      loadingMore: loadingMore ?? this.loadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }
}

class TaskCommentsController
    extends AutoDisposeFamilyAsyncNotifier<TaskCommentsState, String> {
  static const _pageSize = 20;

  @override
  Future<TaskCommentsState> build(String taskId) => _loadFirstPage();

  Future<TaskCommentsState> _loadFirstPage() async {
    final result = await ref
        .read(taskCommentRepositoryProvider)
        .getComments(arg, page: 1, limit: _pageSize);
    return TaskCommentsState(
      comments: result.comments,
      page: result.page,
      totalPages: result.totalPages,
    );
  }

  /// Pull-to-refresh: keeps showing current comments until the reload ends.
  Future<void> refresh() async {
    final next = await AsyncValue.guard(_loadFirstPage);
    state = next.hasError && state.hasValue ? state : next;
  }

  /// Loads the next (newer) page and appends it.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(
      current.copyWith(loadingMore: true, loadMoreFailed: false),
    );
    try {
      final result = await ref
          .read(taskCommentRepositoryProvider)
          .getComments(arg, page: current.page + 1, limit: _pageSize);
      state = AsyncData(
        current.copyWith(
          comments: _merge(current.comments, result.comments),
          page: result.page,
          totalPages: result.totalPages,
          loadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(
        current.copyWith(loadingMore: false, loadMoreFailed: true),
      );
    }
  }

  /// Posts a comment and appends it. Throws ApiException on failure so the
  /// input can show the error and keep the user's text.
  Future<void> send(String body) async {
    final comment = await ref
        .read(taskCommentRepositoryProvider)
        .addComment(arg, body);
    final current = state.value;
    if (current == null) {
      state = AsyncData(
        TaskCommentsState(comments: [comment], page: 1, totalPages: 1),
      );
      return;
    }
    state = AsyncData(
      current.copyWith(comments: _merge(current.comments, [comment])),
    );
  }

  // Appends without duplicates (a sent comment may later arrive in a page).
  List<TaskComment> _merge(List<TaskComment> existing, List<TaskComment> more) {
    final ids = existing.map((c) => c.id).toSet();
    return [
      ...existing,
      for (final comment in more)
        if (ids.add(comment.id)) comment,
    ];
  }
}
