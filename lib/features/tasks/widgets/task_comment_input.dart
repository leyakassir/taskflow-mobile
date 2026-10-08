import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_comments_provider.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Text field and send button. Keeps the text when sending fails so the
/// user can retry.
class TaskCommentInput extends ConsumerStatefulWidget {
  const TaskCommentInput({super.key, required this.taskId});

  static const maxLength = 1000;

  final String taskId;

  @override
  ConsumerState<TaskCommentInput> createState() => _TaskCommentInputState();
}

class _TaskCommentInputState extends ConsumerState<TaskCommentInput> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSend => !_sending && _controller.text.trim().isNotEmpty;

  Future<void> _send() async {
    if (!_canSend) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(taskCommentsControllerProvider(widget.taskId).notifier)
          .send(_controller.text);
      _controller.clear();
    } on ApiException catch (e) {
      _error = e.statusCode == 400 ? e.message : l10n.commentSendFailed;
    } catch (_) {
      _error = l10n.commentSendFailed;
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_sending,
                minLines: 1,
                maxLines: 5,
                maxLength: TaskCommentInput.maxLength,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => currentLength > TaskCommentInput.maxLength - 100
                    ? Text('$currentLength/$maxLength')
                    : null,
                decoration: InputDecoration(
                  hintText: l10n.commentHint,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.fieldRadius,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space2),
            Padding(
              // Line up with the text field, above its counter area.
              padding: const EdgeInsets.only(bottom: AppDimensions.space1),
              child: IconButton.filled(
                tooltip: l10n.commentSend,
                onPressed: _canSend ? _send : null,
                icon: _sending
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
        if (_error != null)
          Text(
            _error!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
          ),
      ],
    );
  }
}
