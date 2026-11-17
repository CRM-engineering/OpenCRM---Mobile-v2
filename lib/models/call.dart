class CrmCall {
  final String id;
  final String name;
  final String dateStart;
  final String durationHours;
  final String durationMinutes;
  final String status;
  final String direction;
  final String phone;
  final String assignedTo;
  final String parentName;
  final String description;

  const CrmCall({
    required this.id,
    required this.name,
    required this.dateStart,
    required this.durationHours,
    required this.durationMinutes,
    required this.status,
    required this.direction,
    required this.phone,
    required this.assignedTo,
    required this.parentName,
    required this.description,
  });
}

class CallFilter {
  final String status;
  final String direction;
  final String sortBy;
  final bool sortAscending;

  const CallFilter({
    this.status = '',
    this.direction = '',
    this.sortBy = 'date_start',
    this.sortAscending = true,
  });

  CallFilter copyWith({
    String? status,
    String? direction,
    String? sortBy,
    bool? sortAscending,
  }) {
    return CallFilter(
      status: status ?? this.status,
      direction: direction ?? this.direction,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}