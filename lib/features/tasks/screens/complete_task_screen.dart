import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/widgets/error_view.dart';
import 'package:taskflow_mobile/core/widgets/photo_source_sheet.dart';
import 'package:taskflow_mobile/features/tasks/data/models/task_submission_model.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/features/tasks/providers/task_details_provider.dart';
import 'package:taskflow_mobile/features/tasks/widgets/completion_form.dart';
import 'package:taskflow_mobile/features/tasks/widgets/completion_task_summary_card.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_card_skeleton.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

class CompleteTaskScreen extends ConsumerStatefulWidget {
  const CompleteTaskScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<CompleteTaskScreen> createState() => _CompleteTaskScreenState();
}

class _CompleteTaskScreenState extends ConsumerState<CompleteTaskScreen> {
  final _imagePicker = ImagePicker();
  final _notesController = TextEditingController();

  final List<AttachmentInput> _pendingPhotos = [];
  final List<AttachmentInput> _pendingFiles = [];
  final Map<String, bool> _checklistResults = {};

  bool _isSubmitting = false;
  bool _isUploading = false;
  String? _uploadingName;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailsControllerProvider(widget.taskId));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).completeTaskTitle),
      ),
      body: taskAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          children: const [
            TaskCardSkeleton(lines: 2),
            SizedBox(height: AppDimensions.space3),
            TaskCardSkeleton(lines: 3),
          ],
        ),
        error: (error, stackTrace) => ErrorView(
          onRetry: () => ref
              .read(taskDetailsControllerProvider(widget.taskId).notifier)
              .refresh(),
        ),
        data: _buildTaskForm,
      ),
    );
  }

  Widget _buildTaskForm(Task task) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      children: [
        Text(
          AppLocalizations.of(context).completeHeadline,
          style: AppTextStyles.displaySmall.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppDimensions.space2),
        Text(
          AppLocalizations.of(context).completeSubhead,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.space5),

        CompletionTaskSummaryCard(task: task),
        const SizedBox(height: AppDimensions.space3),

        CompletionForm(
          task: task,
          notesController: _notesController,
          checklistResults: _checklistResults,
          onChecklistItemChanged: (itemId, done) {
            setState(() => _checklistResults[itemId] = done);
          },
          pendingPhotos: _pendingPhotos,
          pendingFiles: _pendingFiles,
          onAddPhoto: _addPhoto,
          onAddFile: _addFiles,
          canSubmit: _canSubmit(task),
          isSubmitting: _isSubmitting,
          uploadingName: _uploadingName,
          onSubmit: () => _submit(task),
        ),
      ],
    );
  }

  Future<void> _addPhoto() async {
    final source = await showPhotoSourceSheet(context);

    if (source == null) return;

    try {
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (pickedImage == null) return;

      final sizeBytes = await pickedImage.length();
      if (!mounted) return;

      setState(() {
        _isUploading = true;
        _uploadingName = 'photo:${pickedImage.name}';
      });
      await ref
          .read(taskDetailsControllerProvider(widget.taskId).notifier)
          .uploadAttachment(filePath: pickedImage.path, kind: 'PHOTO');
      if (!mounted) return;

      setState(() {
        _pendingPhotos.add(
          AttachmentInput(
            // Local path is kept only to label the uploaded item in this UI;
            // completion submissions never send these paths.
            url: pickedImage.path,
            mimeType: _mimeTypeForName(pickedImage.name),
            sizeBytes: sizeBytes,
          ),
        );
      });
      _showMessage(AppLocalizations.of(context).photoUploaded);
    } catch (error, stackTrace) {
      debugPrint('Photo selection or upload failed: $error\n$stackTrace');
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).photoUploadFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadingName = null;
        });
      }
    }
  }

  Future<void> _addFiles() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'txt',
          'csv',
        ],
      );

      if (files.isEmpty || !mounted) return;

      final uploadedFiles = <AttachmentInput>[];
      var failedUploads = 0;

      for (final file in files) {
        final path = file.path;
        if (path == null || path.isEmpty) {
          failedUploads++;
          continue;
        }

        final sizeBytes = file.lengthSync() ?? await file.length() ?? 0;

        try {
          if (mounted) {
            setState(() {
              _isUploading = true;
              _uploadingName = 'file:${file.name}';
            });
          }
          await ref
              .read(taskDetailsControllerProvider(widget.taskId).notifier)
              .uploadAttachment(filePath: path, kind: 'FILE');
          uploadedFiles.add(
            AttachmentInput(
              // Local path is only a display label; it is never submitted.
              url: path,
              mimeType: _mimeTypeForName(file.name),
              sizeBytes: sizeBytes,
            ),
          );
        } catch (error, stackTrace) {
          debugPrint(
            'File upload failed for ${file.name}: $error\n$stackTrace',
          );
          failedUploads++;
        }
      }

      if (!mounted) return;
      if (uploadedFiles.isEmpty) {
        _showMessage(AppLocalizations.of(context).filesUploadFailed);
        return;
      }

      setState(() => _pendingFiles.addAll(uploadedFiles));
      _showMessage(
        failedUploads == 0
            ? '${uploadedFiles.length} file(s) uploaded successfully.'
            : '${uploadedFiles.length} uploaded; $failedUploads failed.',
      );
    } catch (error, stackTrace) {
      debugPrint('File selection failed: $error\n$stackTrace');
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).filesSelectFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadingName = null;
        });
      }
    }
  }

  bool _canSubmit(Task task) {
    if (_isSubmitting || _isUploading) return false;

    final statusAllowsCompletion = task.status == TaskStatus.inProgress;

    final checklistRequirementMet =
        !task.requiresChecklist ||
        task.checklistItems.every(
          (item) => _checklistResults[item.id] ?? item.done,
        );

    return statusAllowsCompletion && checklistRequirementMet;
  }

  Future<void> _submit(Task task) async {
    if (!_canSubmit(task)) {
      _showMessage(AppLocalizations.of(context).completeRequiredFirst);
      return;
    }

    final notes = _notesController.text.trim();

    final submission = TaskSubmissionModel(
      notes: notes.isEmpty ? null : notes,
      checklistResults: task.requiresChecklist
          ? task.checklistItems
                .map(
                  (item) => ChecklistResultInput(
                    id: item.id,
                    done: _checklistResults[item.id] ?? item.done,
                  ),
                )
                .toList()
          : null,
    );

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(taskDetailsControllerProvider(widget.taskId).notifier)
          .complete(submission);

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      final completionSnackBar = _completionSnackBar(context);
      context.pop();
      messenger.showSnackBar(completionSnackBar);
    } catch (error, stackTrace) {
      debugPrint('Task completion submission failed: $error\n$stackTrace');
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context).submitFailed);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  SnackBar _completionSnackBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      content: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: colorScheme.inversePrimary),
          const SizedBox(width: AppDimensions.space3),
          Expanded(
            child: Text(AppLocalizations.of(context).completionSubmitted),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _mimeTypeForName(String name) {
    final extension = name.contains('.')
        ? name.split('.').last.toLowerCase()
        : '';

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      default:
        return 'application/octet-stream';
    }
  }
}
