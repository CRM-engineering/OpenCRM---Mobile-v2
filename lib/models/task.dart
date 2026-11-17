class CrmTask {
  final String id;
  final String name;
  final String dateStart;
  final String dateDue;
  final String status;
  final String priority;
  final String assignedTo;
  final String parentName;
  final String description;

  const CrmTask({
    required this.id,
    required this.name,
    required this.dateStart,
    required this.dateDue,
    required this.status,
    required this.priority,
    required this.assignedTo,
    required this.parentName,
    required this.description,
  });
}

class TaskFilter {
  final String status;
  final String priority;
  final String sortBy;
  final bool sortAscending;

  const TaskFilter({
    this.status = '',
    this.priority = '',
    this.sortBy = 'date_due',
    this.sortAscending = true,
  });

  TaskFilter copyWith({
    String? status,
    String? priority,
    String? sortBy,
    bool? sortAscending,
  }) {
    return TaskFilter(
      status: status ?? this.status,
      priority: priority ?? this.priority,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}