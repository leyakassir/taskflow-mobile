import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Keeps photos and files picked while offline until they are uploaded.
///
/// Picked images live in a temporary cache folder the OS may clear, so a
/// copy is made in the app's own documents folder; the copy is deleted
/// after a successful upload, or on logout.
final offlineFilesProvider = Provider<OfflineFiles>((ref) => OfflineFiles());

class OfflineFiles {
  static const _folder = 'offline_uploads';

  Future<Directory> _directory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_folder');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// Copies [sourcePath] into the upload folder and returns the copy's path.
  Future<String> keep(String sourcePath) async {
    final dir = await _directory();
    final name = sourcePath.split(RegExp(r'[\\/]')).last;
    final target = '${dir.path}/${DateTime.now().microsecondsSinceEpoch}_$name';
    await File(sourcePath).copy(target);
    return target;
  }

  Future<void> discard(String path) async {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }

  Future<void> clear() async {
    final dir = await _directory();
    if (dir.existsSync()) await dir.delete(recursive: true);
  }
}
