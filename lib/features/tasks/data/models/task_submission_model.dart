class TaskSubmissionModel {
  final String? notes;
  final List<ChecklistResultInput>? checklistResults;
  final List<AttachmentInput>? photos;
  final List<AttachmentInput>? files;

  const TaskSubmissionModel({
    this.notes,
    this.checklistResults,
    this.photos,
    this.files,
  });

  /// Reads a submission saved in the offline queue.
  factory TaskSubmissionModel.fromJson(Map<String, dynamic> json) {
    List<AttachmentInput>? attachments(Object? raw) => raw is List
        ? [
            for (final a in raw.whereType<Map<String, dynamic>>())
              AttachmentInput(
                url: a['url'] as String? ?? '',
                mimeType: a['mimeType'] as String? ?? '',
                sizeBytes: (a['sizeBytes'] as num?)?.toInt() ?? 0,
              ),
          ]
        : null;
    final checklist = json['checklistResults'];
    return TaskSubmissionModel(
      notes: json['notes'] as String?,
      checklistResults: checklist is List
          ? [
              for (final r in checklist.whereType<Map<String, dynamic>>())
                ChecklistResultInput(
                  id: r['id']?.toString() ?? '',
                  done: r['done'] == true,
                ),
            ]
          : null,
      photos: attachments(json['photos']),
      files: attachments(json['files']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (notes != null) 'notes': notes,
      if (checklistResults != null)
        'checklistResults': checklistResults!.map((e) => e.toJson()).toList(),
      if (photos != null) 'photos': photos!.map((e) => e.toJson()).toList(),
      if (files != null) 'files': files!.map((e) => e.toJson()).toList(),
    };
  }
}

class ChecklistResultInput {
  final String id;
  final bool done;

  const ChecklistResultInput({required this.id, required this.done});

  Map<String, dynamic> toJson() => {'id': id, 'done': done};
}

class AttachmentInput {
  final String url;
  final String mimeType;
  final int sizeBytes;

  const AttachmentInput({
    required this.url,
    required this.mimeType,
    required this.sizeBytes,
  });

  Map<String, dynamic> toJson() => {
    'url': url,
    'mimeType': mimeType,
    'sizeBytes': sizeBytes,
  };
}
