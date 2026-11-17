class Meeting {
  final String id;
  final String name;
  final String dateStart;
  final String durationHours;
  final String durationMinutes;
  final String status;
  final String location;
  final String assignedTo;
  final String parentName;
  final String description;

  const Meeting({
    required this.id,
    required this.name,
    required this.dateStart,
    required this.durationHours,
    required this.durationMinutes,
    required this.status,
    required this.location,
    required this.assignedTo,
    required this.parentName,
    required this.description,
  });
}

class MeetingFilter {
  final String status;
  final String sortBy;
  final bool sortAscending;

  const MeetingFilter({
    this.status = '',
    this.sortBy = 'date_start',
    this.sortAscending = true,
  });

  MeetingFilter copyWith({
    String? status,
    String? sortBy,
    bool? sortAscending,
  }) {
    return MeetingFilter(
      status: status ?? this.status,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}