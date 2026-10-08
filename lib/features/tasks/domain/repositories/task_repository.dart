import 'package:taskflow_mobile/features/tasks/data/models/task_submission_model.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';

abstract class TaskRepository {
  /// Returns tasks visible to the current user — the backend enforces that
  /// workers only ever receive tasks assigned to them.
  Future<TaskPage> getTasks({int page = 1, int limit = 20});

  /// Returns every visible task whose deadline or start date falls within
  /// [from]..[to] (inclusive), following pagination until all pages load.
  Future<List<Task>> getTasksInRange({
    required DateTime from,
    required DateTime to,
  });

  /// Fetches a single task by id. The backend enforces access control;
  /// a worker requesting another worker's task will fail here.
  Future<Task> getTaskById(String taskId);

  /// Transitions a task to a new status (e.g. ASSIGNED -> IN_PROGRESS).
  /// The backend validates that the transition is legal.
  Future<Task> updateTaskStatus(String taskId, TaskStatus status);

  /// Submits completion evidence for a task. The backend validates that
  /// all required evidence (photos, files, checklist) is present.
  Future<Task> completeTask(String taskId, TaskSubmissionModel submission);

  Future<Map<String, dynamic>> uploadAttachment({
    required String taskId,
    required String filePath,
    required String kind,
  });
}
