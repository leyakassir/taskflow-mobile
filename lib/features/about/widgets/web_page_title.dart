import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';

/// Two-line AppBar title for an in-app web page: the page title, and below
/// it the site address with a lock (https) or info (http) icon, like a
/// browser's address bar.
class WebPageTitle extends StatelessWidget {
  const WebPageTitle({super.key, required this.title, required this.url});

  final String title;
  final Uri url;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final secure = url.scheme == 'https';
    final address = url.hasPort && !_isDefaultPort(url)
        ? '${url.host}:${url.port}'
        : url.host;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              secure ? Icons.lock_rounded : Icons.info_outline_rounded,
              size: 12,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: AppDimensions.space1),
            Flexible(
              child: Text(
                address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // Addresses read left to right even in Arabic.
                textDirection: TextDirection.ltr,
                style: AppTextStyles.labelMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static bool _isDefaultPort(Uri url) =>
      (url.scheme == 'https' && url.port == 443) ||
      (url.scheme == 'http' && url.port == 80);
}
