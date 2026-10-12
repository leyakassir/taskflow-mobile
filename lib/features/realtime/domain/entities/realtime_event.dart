/// What the server says changed. The app reloads the matching data through
/// the normal endpoints; events never carry the data itself.
enum RealtimeEventType { task, comment, notification, ping, unknown }

class RealtimeEvent {
  const RealtimeEvent(this.type, {this.taskId});

  final RealtimeEventType type;
  final String? taskId;

  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    final type = switch (json['type']) {
      'task' => RealtimeEventType.task,
      'comment' => RealtimeEventType.comment,
      'notification' => RealtimeEventType.notification,
      'ping' => RealtimeEventType.ping,
      _ => RealtimeEventType.unknown,
    };
    return RealtimeEvent(type, taskId: json['taskId'] as String?);
  }
}
