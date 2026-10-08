import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/widgets/app_button.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_submission_model.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_attachment_card.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_checklist.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Completion controls only. Submission and checklist state remain owned by
/// the screen/provider; photos, files, and notes are optional.
class CompletionForm extends StatelessWidget {
  const CompletionForm({
    super.key,
    required this.task,
    required this.notesController,
    required this.checklistResults,
    required this.onChecklistItemChanged,
    required this.pendingPhotos,
    required this.pendingFiles,
    required this.onAddPhoto,
    required this.onAddFile,
    required this.canSubmit,
    required this.isSubmitting,
    this.uploadingName,
    required this.onSubmit,
  });

  final Task task;
  final TextEditingController notesController;
  final Map<String, bool> checklistResults;
  final void Function(String itemId, bool done) onChecklistItemChanged;
  final List<AttachmentInput> pendingPhotos;
  final List<AttachmentInput> pendingFiles;
  final VoidCallback onAddPhoto;
  final VoidCallback onAddFile;
  final bool canSubmit;
  final bool isSubmitting;
  final String? uploadingName;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (task.requiresChecklist && task.checklistItems.isNotEmpty) ...[
          _CompletionPanel(
            title: AppLocalizations.of(context).requiredChecklist,
            icon: Icons.checklist_rounded,
            child: TaskChecklist(
              items: [
                for (final item in task.checklistItems)
                  item.copyWith(done: checklistResults[item.id] ?? item.done),
              ],
              onChanged: onChecklistItemChanged,
            ),
          ),
          const SizedBox(height: AppDimensions.space3),
        ],
        _CompletionPanel(
          title: AppLocalizations.of(context).photosTitle,
          icon: Icons.photo_camera_back_outlined,
          optional: true,
          count: pendingPhotos.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: Column(
                  children: pendingPhotos.asMap().entries.map((entry) {
                    final photo = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.space2,
                      ),
                      child: TaskAttachmentCard(
                        attachment: TaskAttachment(
                          id: 'pending-photo-${entry.key}',
                          taskId: task.id,
                          kind: TaskAttachmentKind.completionPhoto,
                          url: photo.url,
                          mimeType: photo.mimeType,
                          sizeBytes: photo.sizeBytes,
                          createdAt: DateTime.now(),
                        ),
                        isUploaded: true,
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (uploadingName != null && uploadingName!.startsWith('photo:'))
                _UploadingRow(name: uploadingName!.substring(6)),
              OutlinedButton.icon(
                onPressed: uploadingName == null ? onAddPhoto : null,
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: Text(AppLocalizations.of(context).addPhoto),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space3),
        _CompletionPanel(
          title: AppLocalizations.of(context).filesTitle,
          icon: Icons.attach_file_rounded,
          optional: true,
          count: pendingFiles.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: Column(
                  children: pendingFiles.asMap().entries.map((entry) {
                    final file = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.space2,
                      ),
                      child: TaskAttachmentCard(
                        attachment: TaskAttachment(
                          id: 'pending-file-${entry.key}',
                          taskId: task.id,
                          kind: TaskAttachmentKind.completionFile,
                          url: file.url,
                          mimeType: file.mimeType,
                          sizeBytes: file.sizeBytes,
                          createdAt: DateTime.now(),
                        ),
                        isUploaded: true,
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (uploadingName != null && uploadingName!.startsWith('file:'))
                _UploadingRow(name: uploadingName!.substring(5)),
              OutlinedButton.icon(
                onPressed: uploadingName == null ? onAddFile : null,
                icon: const Icon(Icons.attach_file_rounded, size: 18),
                label: Text(AppLocalizations.of(context).addFile),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space3),
        _CompletionPanel(
          title: AppLocalizations.of(context).notesTitle,
          icon: Icons.notes_rounded,
          optional: true,
          child: TextField(
            controller: notesController,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).notesHint,
              alignLabelWithHint: true,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.space5),
        AppButton(
          label: AppLocalizations.of(context).submitCompletion,
          icon: Icons.check_rounded,
          isLoading: isSubmitting,
          onPressed: canSubmit ? onSubmit : null,
        ),
        if (uploadingName != null) ...[
          const SizedBox(height: AppDimensions.space2),
          Text(
            AppLocalizations.of(context).waitForUploads,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _UploadingRow extends StatelessWidget {
  const _UploadingRow({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const SizedBox.square(
      dimension: 22,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
    title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: const Text('Uploading…'),
  );
}

class _CompletionPanel extends StatelessWidget {
  const _CompletionPanel({
    required this.title,
    required this.icon,
    required this.child,
    this.optional = false,
    this.count,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool optional;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final detail = count == null
        ? (optional ? AppLocalizations.of(context).optional : null)
        : count == 0
        ? AppLocalizations.of(context).optional
        : '$count added';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.space4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppDimensions.space2),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (detail != null)
                Text(
                  detail,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.space3),
          child,
        ],
      ),
    );
  }
}
