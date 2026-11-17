import 'package:flutter/material.dart';
import '../accounts/account_list_screen.dart';
import '../../models/dashboard_stats.dart';
import '../../services/dashboard_service.dart';
import '../../services/session_manager.dart';
import '../../services/permission_manager.dart';
import '../../widgets/dashboard_card.dart';
import '../contacts/contact_list_screen.dart';
import '../leads/lead_list_screen.dart';
import '../opportunities/opportunity_list_screen.dart';
import '../meetings/meeting_list_screen.dart';
import '../calls/call_list_screen.dart';
import '../tasks/task_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardStats? stats;
  bool loading = true;
  double? opportunityTotalValue;
  late bool myStatsOnly;

  @override
  void initState() {
    super.initState();
    myStatsOnly = !SessionManager.isAdmin;
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() {
      loading = true;
      opportunityTotalValue = null;
    });

    final dashboard = await DashboardService().loadDashboard(
      myStatsOnly: myStatsOnly,
    );

    if (!mounted) return;

    setState(() {
      stats = dashboard;
      loading = false;
    });

    if (!PermissionManager.canList('Opportunities')) return;

    try {
      final total = await DashboardService()
          .loadOpportunityTotalValue(myStatsOnly: myStatsOnly)
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;
      setState(() => opportunityTotalValue = total);
    } catch (_) {}
  }

  int statusCount(Map<String, int> values, String key) => values[key] ?? 0;

  Future<void> _chooseStatsScope() async {

    final result = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Statistics',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose whether the dashboard shows your own records or all records you are permitted to access.',
              ),
              const SizedBox(height: 16),
              RadioGroup<bool>(
                groupValue: myStatsOnly,
                onChanged: (value) => Navigator.pop(sheetContext, value),
                child: Column(
                  children: [
                    RadioListTile<bool>(
                      value: true,
                      title: const Text('My Statistics'),
                      subtitle: const Text('Records assigned to me'),
                    ),
                    RadioListTile<bool>(
                      value: false,
                      title: const Text('All Accessible'),
                      subtitle: const Text('Everything SuiteCRM allows me to see'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == null || !mounted || result == myStatsOnly) return;
    setState(() => myStatsOnly = result);
    await loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = stats!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenCRM Mobile'),
        actions: [
          IconButton(
              tooltip: myStatsOnly ? 'Showing My Statistics' : 'Showing All Accessible',
              icon: Icon(myStatsOnly ? Icons.person : Icons.groups),
              onPressed: _chooseStatsScope,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Good Morning', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Welcome ${SessionManager.username}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            ...[
              const SizedBox(height: 14),
              InkWell(
                onTap: _chooseStatsScope,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(myStatsOnly ? Icons.person : Icons.groups, size: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(myStatsOnly ? 'My Statistics' : 'All Accessible Statistics')),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 25),

            if (PermissionManager.canList('Leads'))
              DashboardCard(
                icon: Icons.person_add_alt,
                title: 'Leads',
                value: data.leads.toString(),
                rows: [
                  DashboardCardRow(label: 'New', value: statusCount(data.leadStatuses, 'New')),
                  DashboardCardRow(label: 'Assigned', value: statusCount(data.leadStatuses, 'Assigned')),
                  DashboardCardRow(label: 'In Process', value: statusCount(data.leadStatuses, 'In Process')),
                  DashboardCardRow(label: 'Converted', value: statusCount(data.leadStatuses, 'Converted')),
                ],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeadListScreen(myStatsOnly: myStatsOnly))),
              ),

            if (PermissionManager.canList('Opportunities'))
              DashboardCard(
                icon: Icons.attach_money,
                title: 'Opportunities',
                value: data.opportunities.toString(),
                rows: [
                  DashboardCardRow(label: 'Prospecting', value: statusCount(data.opportunityStages, 'Prospecting')),
                  DashboardCardRow(label: 'Qualification', value: statusCount(data.opportunityStages, 'Qualification')),
                  DashboardCardRow(label: 'Needs Analysis', value: statusCount(data.opportunityStages, 'Needs Analysis')),
                  DashboardCardRow(label: 'Proposal / Quote', value: statusCount(data.opportunityStages, 'Proposal/Price Quote')),
                  DashboardCardRow(label: 'Negotiation', value: statusCount(data.opportunityStages, 'Negotiation/Review')),
                  DashboardCardRow(label: 'Closed Won', value: statusCount(data.opportunityStages, 'Closed Won')),
                ],
                footer: opportunityTotalValue == null
                    ? 'Total value: Calculating...'
                    : 'Total value: R ${opportunityTotalValue!.toStringAsFixed(2)}',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OpportunityListScreen(myStatsOnly: myStatsOnly))),
              ),

            if (PermissionManager.canList('Accounts'))
              DashboardCard(
                icon: Icons.business,
                title: 'Accounts',
                value: data.accounts.toString(),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AccountListScreen(myStatsOnly: myStatsOnly))),
              ),

            if (PermissionManager.canList('Contacts'))
              DashboardCard(
                icon: Icons.people,
                title: 'Contacts',
                value: data.contacts.toString(),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactListScreen(myStatsOnly: myStatsOnly))),
              ),

            if (PermissionManager.canList('Meetings'))
              DashboardCard(
                icon: Icons.event,
                title: 'Meetings',
                value: data.meetings.toString(),
                rows: [
                  DashboardCardRow(label: 'Planned', value: statusCount(data.meetingStatuses, 'Planned')),
                  DashboardCardRow(label: 'Held', value: statusCount(data.meetingStatuses, 'Held')),
                  DashboardCardRow(label: 'Not Held', value: statusCount(data.meetingStatuses, 'Not Held')),
                  DashboardCardRow(label: 'Today', value: data.todayMeetings),
                ],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MeetingListScreen(myStatsOnly: myStatsOnly))),
              ),

            if (PermissionManager.canList('Calls'))
              DashboardCard(
                icon: Icons.call,
                title: 'Calls',
                value: data.calls.toString(),
                rows: [
                  DashboardCardRow(label: 'Planned', value: statusCount(data.callStatuses, 'Planned')),
                  DashboardCardRow(label: 'Held', value: statusCount(data.callStatuses, 'Held')),
                  DashboardCardRow(label: 'Not Held', value: statusCount(data.callStatuses, 'Not Held')),
                  DashboardCardRow(label: 'Today', value: data.todayCalls),
                ],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CallListScreen(myStatsOnly: myStatsOnly))),
              ),

            if (PermissionManager.canList('Tasks'))
              DashboardCard(
                icon: Icons.task_alt,
                title: 'Tasks',
                value: data.tasks.toString(),
                rows: [
                  DashboardCardRow(label: 'Not Started', value: statusCount(data.taskStatuses, 'Not Started')),
                  DashboardCardRow(label: 'In Progress', value: statusCount(data.taskStatuses, 'In Progress')),
                  DashboardCardRow(label: 'Completed', value: statusCount(data.taskStatuses, 'Completed')),
                  DashboardCardRow(label: 'Pending Input', value: statusCount(data.taskStatuses, 'Pending Input')),
                  DashboardCardRow(label: 'Due Today', value: data.dueTodayTasks),
                  DashboardCardRow(label: 'Overdue', value: data.overdueTasks),
                ],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskListScreen(myStatsOnly: myStatsOnly))),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
