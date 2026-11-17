import '../models/dashboard_stats.dart';
import 'suitecrm_client.dart';
import 'permission_manager.dart';
import 'session_manager.dart';

class DashboardService {
  final SuiteCRMClient _client = SuiteCRMClient();

  String _scopeQuery(String module, String query, bool myStatsOnly) {
    if (!myStatsOnly || SessionManager.userId == null) return query;
    final owner = "$module.assigned_user_id = '${SessionManager.userId}'";
    if (query.trim().isEmpty) return owner;
    return '$owner AND ($query)';
  }

  Future<double> loadOpportunityTotalValue({bool myStatsOnly = false}) {
    return _client.getTotalOpportunityValue(
      query: _scopeQuery('opportunities', '', myStatsOnly),
    );
  }

  Future<DashboardStats> loadDashboard({bool myStatsOnly = false}) async {
    Future<int> count(String module) async {
      if (!PermissionManager.canList(module)) return 0;
      return _client.getEntriesCountWhere(
        module,
        _scopeQuery(module.toLowerCase(), '', myStatsOnly),
      );
    }

    Future<int> whereCount(String module, String query) async {
      if (!PermissionManager.canList(module)) return 0;
      return _client.getEntriesCountWhere(
        module,
        _scopeQuery(module.toLowerCase(), query, myStatsOnly),
      );
    }

    final totals = await Future.wait([
      count('Leads'),
      count('Accounts'),
      count('Contacts'),
      count('Opportunities'),
      count('Meetings'),
      count('Calls'),
      count('Tasks'),
    ]);

    final leadStatusNames = [
      'New', 'Assigned', 'In Process', 'Converted', 'Recycled', 'Dead',
    ];
    final leadStatusResults = await Future.wait(leadStatusNames.map(
      (status) => whereCount('Leads', "leads.status = '$status'"),
    ));
    final leadStatuses = <String, int>{};
    for (int i = 0; i < leadStatusNames.length; i++) {
      leadStatuses[leadStatusNames[i]] = leadStatusResults[i];
    }

    final accountTypeNames = [
      'Analyst', 'Competitor', 'Customer', 'Integrator', 'Investor',
      'Partner', 'Press', 'Prospect', 'Reseller', 'Other',
    ];
    final accountTypeResults = await Future.wait(accountTypeNames.map(
      (type) => whereCount('Accounts', "accounts.account_type = '$type'"),
    ));
    final accountTypes = <String, int>{};
    for (int i = 0; i < accountTypeNames.length; i++) {
      accountTypes[accountTypeNames[i]] = accountTypeResults[i];
    }

    final opportunityStageNames = [
      'Prospecting', 'Qualification', 'Needs Analysis',
      'Value Proposition', 'Identifying Decision Makers',
      'Perception Analysis', 'Proposal/Price Quote', 'Negotiation/Review',
      'Closed Won', 'Closed Lost',
    ];
    final opportunityStageResults = await Future.wait(
      opportunityStageNames.map(
        (stage) => whereCount(
          'Opportunities',
          "opportunities.sales_stage = '$stage'",
        ),
      ),
    );
    final opportunityStages = <String, int>{};
    for (int i = 0; i < opportunityStageNames.length; i++) {
      opportunityStages[opportunityStageNames[i]] = opportunityStageResults[i];
    }

    final meetingStatusNames = ['Planned', 'Held', 'Not Held'];
    final meetingStatusResults = await Future.wait(meetingStatusNames.map(
      (status) => whereCount('Meetings', "meetings.status = '$status'"),
    ));
    final meetingStatuses = <String, int>{};
    for (int i = 0; i < meetingStatusNames.length; i++) {
      meetingStatuses[meetingStatusNames[i]] = meetingStatusResults[i];
    }

    final callStatusNames = ['Planned', 'Held', 'Not Held'];
    final callStatusResults = await Future.wait(callStatusNames.map(
      (status) => whereCount('Calls', "calls.status = '$status'"),
    ));
    final callStatuses = <String, int>{};
    for (int i = 0; i < callStatusNames.length; i++) {
      callStatuses[callStatusNames[i]] = callStatusResults[i];
    }

    final taskStatusNames = [
      'Not Started', 'In Progress', 'Completed', 'Pending Input', 'Deferred',
    ];
    final taskStatusResults = await Future.wait(taskStatusNames.map(
      (status) => whereCount('Tasks', "tasks.status = '$status'"),
    ));
    final taskStatuses = <String, int>{};
    for (int i = 0; i < taskStatusNames.length; i++) {
      taskStatuses[taskStatusNames[i]] = taskStatusResults[i];
    }

    final todayResults = await Future.wait([
      whereCount('Calls', "DATE(calls.date_start) = CURDATE()"),
      whereCount('Meetings', "DATE(meetings.date_start) = CURDATE()"),
      whereCount('Tasks', "DATE(tasks.date_due) = CURDATE()"),
      whereCount(
        'Tasks',
        "tasks.date_due < NOW() AND tasks.status NOT IN ('Completed', 'Deferred')",
      ),
    ]);

    return DashboardStats(
      leads: totals[0],
      accounts: totals[1],
      contacts: totals[2],
      opportunities: totals[3],
      meetings: totals[4],
      calls: totals[5],
      tasks: totals[6],
      leadStatuses: leadStatuses,
      accountTypes: accountTypes,
      opportunityStages: opportunityStages,
      meetingStatuses: meetingStatuses,
      callStatuses: callStatuses,
      taskStatuses: taskStatuses,
      todayCalls: todayResults[0],
      todayMeetings: todayResults[1],
      dueTodayTasks: todayResults[2],
      overdueTasks: todayResults[3],
    );
  }
}
