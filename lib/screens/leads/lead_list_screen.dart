import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/lead.dart';
import '../../services/lead_service.dart';
import '../../services/session_manager.dart';
import '../../widgets/stats_scope_picker.dart';
import '../../services/permission_manager.dart';
import '../../widgets/lead_card.dart';
import '../../widgets/pager_widget.dart';
import 'lead_detail_screen.dart';
import 'lead_form_screen.dart';

class LeadListScreen extends StatefulWidget {
  final bool? myStatsOnly;

  const LeadListScreen({super.key, this.myStatsOnly});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  late bool myStatsOnly;
  final LeadService _service = LeadService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  int _requestId = 0;
  List<Lead> items = [];
  bool loading = true;
  int offset = 0;
  static const pageSize = 25;
  int totalLeads = 0;
  String search = '';
  LeadFilter filter = const LeadFilter();

  int get currentPage => (offset ~/ pageSize) + 1;
  int get totalPages => totalLeads == 0 ? 1 : ((totalLeads + pageSize - 1) ~/ pageSize);

  @override
  void initState() {
    super.initState();
    myStatsOnly = widget.myStatsOnly ?? !SessionManager.isAdmin;
    loadItems();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadItems() async {
    final request = ++_requestId;
    setState(() => loading = true);
    try {
      final results = await _service.getLeads(
        search: search,
        offset: offset,
        maxResults: pageSize,
        filter: filter,
        myStatsOnly: myStatsOnly,
      );
      if (!mounted || request != _requestId) return;
      setState(() {
        items = results;
        totalLeads = offset + results.length;
        loading = false;
      });

      try {
        final count = await _service
            .getLeadCount(search: search, filter: filter, myStatsOnly: myStatsOnly)
            .timeout(const Duration(seconds: 5));
        if (!mounted || request != _requestId) return;
        setState(() => totalLeads = count);
      } catch (_) {}
    } catch (_) {
      if (!mounted || request != _requestId) return;
      setState(() {
        items = [];
        totalLeads = 0;
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load leads.')),
      );
    }
  }

  Future<void> _newLead() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeadFormScreen()),
    );
    if (created == true && mounted) loadItems();
  }

  Future<void> _showFilter() async {
    var status = filter.status;
    var leadSource = filter.leadSource;
    var assignedTo = filter.assignedTo;
    var dateFrom = filter.dateFrom;
    var dateTo = filter.dateTo;
    var sortBy = filter.sortBy;
    var ascending = filter.sortAscending;

    Future<void> pickDate(
      BuildContext sheetContext,
      bool from,
      StateSetter setModalState,
    ) async {
      final picked = await showDatePicker(
        context: sheetContext,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: DateTime.tryParse(from ? dateFrom : dateTo) ?? DateTime.now(),
      );
      if (picked == null) return;
      final value = picked.toIso8601String().substring(0, 10);
      setModalState(() {
        if (from) {
          dateFrom = value;
        } else {
          dateTo = value;
        }
      });
    }

    final result = await showModalBottomSheet<LeadFilter>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Filter Leads',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: status.isEmpty ? null : status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      '', 'New', 'Assigned', 'In Process', 'Converted', 'Recycled', 'Dead',
                    ].map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(v.isEmpty ? 'All Statuses' : v),
                    )).toList(),
                    onChanged: (v) => setModalState(() => status = v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: leadSource.isEmpty ? null : leadSource,
                    decoration: const InputDecoration(
                      labelText: 'Lead Source',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      '', 'Cold Call', 'Existing Customer', 'Self Generated', 'Employee',
                      'Partner', 'Public Relations', 'Direct Mail', 'Conference',
                      'Trade Show', 'Web Site', 'Word of mouth', 'Email', 'Campaign', 'Other',
                    ].map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(v.isEmpty ? 'All Sources' : v),
                    )).toList(),
                    onChanged: (v) => setModalState(() => leadSource = v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: assignedTo,
                    decoration: const InputDecoration(
                      labelText: 'Assigned To',
                      hintText: 'Sales person / user name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => assignedTo = v.trim(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: Text(dateFrom.isEmpty ? 'From Date' : dateFrom),
                          onPressed: () => pickDate(sheetContext, true, setModalState),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: Text(dateTo.isEmpty ? 'To Date' : dateTo),
                          onPressed: () => pickDate(sheetContext, false, setModalState),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: sortBy,
                    decoration: const InputDecoration(
                      labelText: 'Sort By',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'date_created', child: Text('Date Created')),
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                      DropdownMenuItem(value: 'status', child: Text('Status')),
                      DropdownMenuItem(value: 'lead_source', child: Text('Lead Source')),
                      DropdownMenuItem(value: 'assigned_to', child: Text('Assigned To')),
                      DropdownMenuItem(value: 'company', child: Text('Company')),
                    ],
                    onChanged: (v) => setModalState(() => sortBy = v ?? 'date_created'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<bool>(
                    initialValue: ascending,
                    decoration: const InputDecoration(
                      labelText: 'Order',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: true, child: Text('Ascending')),
                      DropdownMenuItem(value: false, child: Text('Descending')),
                    ],
                    onChanged: (v) => setModalState(() => ascending = v ?? true),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext, const LeadFilter()),
                          child: const Text('CLEAR FILTERS'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(
                            sheetContext,
                            LeadFilter(
                              status: status,
                              leadSource: leadSource,
                              assignedTo: assignedTo,
                              dateFrom: dateFrom,
                              dateTo: dateTo,
                              sortBy: sortBy,
                              sortAscending: ascending,
                            ),
                          ),
                          child: const Text('APPLY'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        filter = result;
        offset = 0;
      });
      loadItems();
    }
  }


  Future<void> _chooseRecordScope() async {
    if (SessionManager.isAdmin) return;
    final result = await showStatsScopePicker(context, myStatsOnly);
    if (result == null || !mounted || result == myStatsOnly) return;
    setState(() {
      myStatsOnly = result;
      offset = 0;
    });
    loadItems();
  }
  @override
  Widget build(BuildContext context) {
    if (!PermissionManager.canList('Leads')) {
      return const Scaffold(
        body: Center(child: Text('You do not have permission to access Leads.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        actions: [
          if (!SessionManager.isAdmin)
            IconButton(
              tooltip: myStatsOnly ? 'Showing My Statistics' : 'Showing All Accessible',
              icon: Icon(myStatsOnly ? Icons.person : Icons.groups),
              onPressed: _chooseRecordScope,
            ),
          if (PermissionManager.canCreate('Leads'))
            IconButton(
              tooltip: 'New Lead',
              icon: const Icon(Icons.add),
              onPressed: _newLead,
            ),
          IconButton(
            tooltip: 'Filter Leads',
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Leads...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                _debounce?.cancel();
                setState(() {
                  search = value.trim();
                  offset = 0;
                });
                if (search.isEmpty) {
                  loadItems();
                  return;
                }
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  if (mounted) loadItems();
                });
              },
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: loadItems,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final lead = items[index];
                        return LeadCard(
                          lead: lead,
                          onTap: () async {
                            final changed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LeadDetailScreen(lead: lead),
                              ),
                            );
                            if (changed == true && mounted) loadItems();
                          },
                        );
                      },
                    ),
                  ),
          ),
          SafeArea(
            top: false,
            left: false,
            right: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: PagerWidget(
                page: currentPage,
                totalPages: totalPages,
                canGoPrevious: offset > 0,
                canGoNext: offset + pageSize < totalLeads,
                onPrevious: () {
                  setState(() {
                    offset -= pageSize;
                    if (offset < 0) offset = 0;
                  });
                  loadItems();
                },
                onNext: () {
                  setState(() => offset += pageSize);
                  loadItems();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
