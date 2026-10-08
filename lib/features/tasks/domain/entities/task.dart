/// Domain entities for the Tasks feature.
///
/// These are plain, framework-agnostic representations of a Task and its
/// related data. JSON (de)serialization lives in `data/models/`, not here.
library;

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { assigned, inProgress, completed, overdue, cancelled }

enum TaskAttachmentKind { instruction, completionPhoto, completionFile }

class TaskChecklistItem {
  final String id;
  final String taskId;
  final String label;
  final bool done;

  const TaskChecklistItem({
    required this.id,
    required this.taskId,
    required this.label,
    required this.done,
  });

  TaskChecklistItem copyWith({
    String? id,
    String? taskId,
    String? label,
    bool? done,
  }) {
    return TaskChecklistItem(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      label: label ?? this.label,
      done: done ?? this.done,
    );
  }
}

class TaskAttachment {
  final String id;
  final String taskId;
  final TaskAttachmentKind kind;
  final String url;
  final String mimeType;
  final int sizeBytes;
  final DateTime createdAt;

  const TaskAttachment({
    required this.id,
    required this.taskId,
    required this.kind,
    required this.url,
    required this.mimeType,
    required this.sizeBytes,
    required this.createdAt,
  });
}

class Task {
  final String id;
  final String title;
  final String? description;
  final String? titleAr;
  final String? descriptionAr;
  final TaskPriority priority;
  final TaskStatus status;

  final DateTime? deadline;
  final DateTime? startDate;

  final String? location;

  /// Completion requirements set by the admin at creation time.
  final int minPhotosRequired;
  final int minFilesRequired;
  final bool requiresChecklist;

  final String assigneeId;
  final String createdById;

  final List<TaskChecklistItem> checklistItems;
  final List<TaskAttachment> attachments;

  final String? completionNotes;
  final DateTime? completionTimestamp;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.titleAr,
    this.descriptionAr,
    required this.priority,
    required this.status,
    this.deadline,
    this.startDate,
    this.location,
    required this.minPhotosRequired,
    required this.minFilesRequired,
    required this.requiresChecklist,
    required this.assigneeId,
    required this.createdById,
    this.checklistItems = const [],
    this.attachments = const [],
    this.completionNotes,
    this.completionTimestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  /// True when every required checklist item has been marked done.
  bool get isChecklistComplete =>
      !requiresChecklist || checklistItems.every((item) => item.done);

  /// True when the task has at least the minimum required photo evidence.
  bool get hasRequiredPhotos =>
      attachments
          .where((a) => a.kind == TaskAttachmentKind.completionPhoto)
          .length >=
      minPhotosRequired;

  /// True when the task has at least the minimum required file evidence.
  bool get hasRequiredFiles =>
      attachments
          .where((a) => a.kind == TaskAttachmentKind.completionFile)
          .length >=
      minFilesRequired;

  /// True when this task is overdue based on its deadline, independent of
  /// whatever status the backend currently reports (useful for local UI
  /// highlighting before a background job flips the backend status).
  bool get isPastDeadline =>
      deadline != null &&
      status != TaskStatus.completed &&
      status != TaskStatus.cancelled &&
      DateTime.now().isAfter(deadline!);

  /// Title in [languageCode]; Arabic falls back to [title] when the admin
  /// did not provide a translation.
  String titleFor(String languageCode) =>
      languageCode == 'ar' && (titleAr?.trim().isNotEmpty ?? false)
      ? titleAr!
      : title;

  String? descriptionFor(String languageCode) =>
      languageCode == 'ar' && (descriptionAr?.trim().isNotEmpty ?? false)
      ? descriptionAr
      : description;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? titleAr,
    String? descriptionAr,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? deadline,
    DateTime? startDate,
    String? location,
    int? minPhotosRequired,
    int? minFilesRequired,
    bool? requiresChecklist,
    String? assigneeId,
    String? createdById,
    List<TaskChecklistItem>? checklistItems,
    List<TaskAttachment>? attachments,
    String? completionNotes,
    DateTime? completionTimestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      titleAr: titleAr ?? this.titleAr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      startDate: startDate ?? this.startDate,
      location: location ?? this.location,
      minPhotosRequired: minPhotosRequired ?? this.minPhotosRequired,
      minFilesRequired: minFilesRequired ?? this.minFilesRequired,
      requiresChecklist: requiresChecklist ?? this.requiresChecklist,
      assigneeId: assigneeId ?? this.assigneeId,
      createdById: createdById ?? this.createdById,
      checklistItems: checklistItems ?? this.checklistItems,
      attachments: attachments ?? this.attachments,
      completionNotes: completionNotes ?? this.completionNotes,
      completionTimestamp: completionTimestamp ?? this.completionTimestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TaskPage {
  const TaskPage({
    required this.tasks,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<Task> tasks;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
