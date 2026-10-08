import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Asks whether to take a photo or pick one from the gallery. Returns null
/// when dismissed. Styling comes from the theme's bottomSheetTheme.
Future<ImageSource?> showPhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (_) => const PhotoSourceSheet(),
  );
}

class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: Text(AppLocalizations.of(context).photoTake),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(AppLocalizations.of(context).photoChoose),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}
