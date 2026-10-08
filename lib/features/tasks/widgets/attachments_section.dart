import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

class AttachmentsSection extends StatelessWidget {
  const AttachmentsSection({super.key, required this.attachments});
  final List<TaskAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(AppDimensions.space3),
        child: Text(AppLocalizations.of(context).noAttachments),
      );
    }
    return Column(
      children: [
        for (final attachment in attachments)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.space2),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimensions.fieldRadius),
                onTap: () async {
                  final base = Uri.parse(ApiConstants.baseUrl);
                  final uri = base.resolve(attachment.url);
                  try {
                    final opened = await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!opened && context.mounted) _showOpenError(context);
                  } catch (_) {
                    if (context.mounted) _showOpenError(context);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.space2),
                  child: Row(
                    children: [
                      if (attachment.mimeType.startsWith('image/'))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            Uri.parse(ApiConstants.baseUrl)
                                .resolve(attachment.url)
                                .toString(),
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox(
                              width: 54,
                              height: 54,
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      const SizedBox(width: AppDimensions.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachment.url.split('/').last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${(attachment.sizeBytes / 1024).toStringAsFixed(0)} KB',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.open_in_new_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showOpenError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).attachmentOpenFailed),
      ),
    );
  }
}
