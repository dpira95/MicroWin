import 'task_category.dart';
import 'task_status.dart';

class Task {
  final String id;
  final String title;
  final int durationMinutes;
  final TaskCategory  category;

  final bool completed;

  // timestamps in ms epoch (per essere 1:1 con Date.now())
  final int createdAtMs;

  final int totalActiveMs;
  final TaskStatus status;

  final int? startTimeMs;
  final int? pausedAtMs;

  final int delayCount;

  const Task({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.category,
    required this.completed,
    required this.createdAtMs,
    required this.totalActiveMs,
    required this.status,
    required this.delayCount,
    this.startTimeMs,
    this.pausedAtMs,
  });

  Task copyWith({
    String? id,
    String? title,
    int? durationMinutes,
    TaskCategory ? category,
    bool? completed,
    int? createdAtMs,
    int? totalActiveMs,
    TaskStatus? status,
    int? startTimeMs,
    int? pausedAtMs,
    int? delayCount,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
      completed: completed ?? this.completed,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      totalActiveMs: totalActiveMs ?? this.totalActiveMs,
      status: status ?? this.status,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      pausedAtMs: pausedAtMs ?? this.pausedAtMs,
      delayCount: delayCount ?? this.delayCount,
    );
  }
}
