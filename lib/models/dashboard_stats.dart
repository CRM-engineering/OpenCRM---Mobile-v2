class DashboardStats {
  final int leads;
  final int accounts;
  final int contacts;
  final int opportunities;
  final int meetings;
  final int calls;
  final int tasks;

  final Map<String, int> leadStatuses;
  final Map<String, int> accountTypes;
  final Map<String, int> opportunityStages;
  final Map<String, int> meetingStatuses;
  final Map<String, int> callStatuses;
  final Map<String, int> taskStatuses;

  final int todayCalls;
  final int todayMeetings;
  final int dueTodayTasks;
  final int overdueTasks;

  const DashboardStats({
    required this.leads,
    required this.accounts,
    required this.contacts,
    required this.opportunities,
    required this.meetings,
    required this.calls,
    required this.tasks,
    required this.leadStatuses,
    required this.accountTypes,
    required this.opportunityStages,
    required this.meetingStatuses,
    required this.callStatuses,
    required this.taskStatuses,
    required this.todayCalls,
    required this.todayMeetings,
    required this.dueTodayTasks,
    required this.overdueTasks,
  });
}