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
