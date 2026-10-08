import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';

/// A compact tile representing a single attachment (instruction file, or
/// completion photo/file). Shows a type icon, filename, and file size.
class TaskAttachmentCard extends StatelessWidget {
  const TaskAttachmentCard({
    super.key,
    required this.attachment,
    this.onTap,
    this.onRemove,
    this.isUploaded = false,
  });

  final TaskAttachment attachment;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool isUploaded;

  bool get _isImage => attachment.mimeType.startsWith('image/');

  String get _fileName => attachment.url.split('/').last;

  String get _sizeLabel {
    final kb = attachment.sizeBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isImage ? Icons.image_rounded : Icons.description_rounded,
                  size: 20,
                  color: context.readable(AppColors.info),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fileName,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _sizeLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: colorScheme.onSurfaceVariant,
                  onPressed: onRemove,
                ),
              if (isUploaded)
                Icon(
                  Icons.check_circle_rounded,
                  color: context.readable(AppColors.success),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
