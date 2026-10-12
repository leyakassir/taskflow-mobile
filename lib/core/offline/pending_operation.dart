/// A change made while offline, waiting to be sent to the server.
///
/// Operations are replayed strictly in the order they were made, so a
/// task is started before its photos upload and before it is completed.
enum PendingOperationType {
  /// payload: { status }  (backend status string, e.g. IN_PROGRESS)
  updateTaskStatus,

  /// payload: { filePath, kind, mimeType, sizeBytes, name }
  uploadAttachment,

  /// payload: the completion submission JSON
  completeTask,

  /// payload: { body }
  addComment,

  /// payload: { notificationId }
  markNotificationRead,

  /// payload: {}
  markAllNotificationsRead,
}

class PendingOperation {
  const PendingOperation({
    required this.id,
    required this.type,
    required this.createdAt,
    this.taskId,
    this.payload = const {},
  });

  final String id;
  final PendingOperationType type;
  final String? taskId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'taskId': taskId,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Returns null for entries written by a newer/older app version that
  /// this one does not understand; they are dropped.
  static PendingOperation? fromJson(Map<String, dynamic> json) {
    final type = PendingOperationType.values
        .where((t) => t.name == json['type'])
        .firstOrNull;
    if (type == null) return null;
    return PendingOperation(
      id: json['id']?.toString() ?? '',
      type: type,
      taskId: json['taskId'] as String?,
      payload: (json['payload'] as Map<String, dynamic>?) ?? const {},
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
