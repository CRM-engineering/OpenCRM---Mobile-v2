import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/permission_manager.dart';
import '../../models/opportunity.dart';
import '../../services/opportunity_service.dart';
import '../../services/session_manager.dart';
import '../../widgets/stats_scope_picker.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/pager_widget.dart';
import 'opportunity_detail_screen.dart';
import 'opportunity_form_screen.dart';

class OpportunityListScreen extends StatefulWidget {
  final bool? myStatsOnly;

  const OpportunityListScreen({super.key, this.myStatsOnly});

  @override
  State<OpportunityListScreen> createState() => _OpportunityListScreenState();
}

class _OpportunityListScreenState extends State<OpportunityListScreen> {
  late bool myStatsOnly;
  final OpportunityService _service = OpportunityService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  int _requestId = 0;

  List<Opportunity> opportunities = [];
  bool loading = true;

  int offset = 0;
  static const int pageSize = 25;
  int totalOpportunities = 0;

  String search = '';
  OpportunityFilter filter = const OpportunityFilter();

  int get currentPage => (offset ~/ pageSize) + 1;

  int get totalPages =>
      totalOpportunities == 0
          ? 1
          : ((totalOpportunities + pageSize - 1) ~/ pageSize);

  @override
  void initState() {
    super.initState();
    myStatsOnly = widget.myStatsOnly ?? !SessionManager.isAdmin;
    loadOpportunities();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadOpportunities() async {
    final request = ++_requestId;

    setState(() {
      loading = true;
      totalOpportunities = 0;
    });

    try {
      final results = await _service.getOpportunities(
        search: search,
        offset: offset,
        maxResults: pageSize,
        filter: filter,
        myStatsOnly: myStatsOnly,
      );

      if (!mounted || request != _requestId) return;

      setState(() {
        opportunities = results;
        totalOpportunities = offset + results.length;
        loading = false;
      });

      try {
        final count = await _service
            .getOpportunityCount(search: search, filter: filter, myStatsOnly: myStatsOnly)
            .timeout(const Duration(seconds: 5));

        if (!mounted || request != _requestId) return;

        setState(() {
          totalOpportunities = count;
        });
      } catch (_) {
        // Records are already displayed; keep the temporary pager count.
      }
    } catch (_) {
      if (!mounted || request != _requestId) return;

      setState(() {
        opportunities = [];
        totalOpportunities = 0;
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load opportunities.'),
        ),
      );
    }
  }

  Future<void> _newOpportunity() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OpportunityFormScreen(),
      ),
    );

    if (created == true && mounted) {
      loadOpportunities();
    }
  }

  Future<void> _showFilter() async {
    var stage = filter.salesStage;
    var assignedTo = filter.assignedTo;
    var dateFrom = filter.dateFrom;
    var dateTo = filter.dateTo;
    var sortBy = filter.sortBy;
    var ascending = filter.sortAscending;

    final result = await showModalBottomSheet<OpportunityFilter>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDate(bool from) async {
              final current = DateTime.tryParse(
                    from ? dateFrom : dateTo,
                  ) ??
                  DateTime.now();

              final picked = await showDatePicker(
                context: context,
                initialDate: current,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (picked == null) return;

              final value =
                  '${picked.year.toString().padLeft(4, '0')}-'
                  '${picked.month.toString().padLeft(2, '0')}-'
                  '${picked.day.toString().padLeft(2, '0')}';

              setModalState(() {
                if (from) {
                  dateFrom = value;
                } else {
                  dateTo = value;
                }
              });
            }

            const stages = [
              '',
              'Prospecting',
              'Qualification',
              'Needs Analysis',
              'Value Proposition',
              'Identifying Decision Makers',
              'Perception Analysis',
              'Proposal/Price Quote',
              'Negotiation/Review',
              'Closed Won',
              'Closed Lost',
            ];

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filter Opportunities',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Sales Stage',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: stage,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: stages
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value.isEmpty ? 'All Stages' : value,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setModalState(() {
                            stage = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        initialValue: assignedTo,
                        decoration: const InputDecoration(
                          labelText: 'Assigned To',
                          hintText: 'Sales person / user name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          assignedTo = value.trim();
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                dateFrom.isEmpty
                                    ? 'From Date'
                                    : dateFrom,
                              ),
                              onPressed: () => pickDate(true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                dateTo.isEmpty ? 'To Date' : dateTo,
                              ),
                              onPressed: () => pickDate(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Sort By',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: sortBy,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'date_closed',
                            child: Text('Close Date'),
                          ),
                          DropdownMenuItem(
                            value: 'name',
                            child: Text('Opportunity Name'),
                          ),
                          DropdownMenuItem(
                            value: 'amount',
                            child: Text('Amount'),
                          ),
                          DropdownMenuItem(
                            value: 'probability',
                            child: Text('Probability'),
                          ),
                          DropdownMenuItem(
                            value: 'sales_stage',
                            child: Text('Sales Stage'),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            sortBy = value ?? 'date_closed';
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<bool>(
                        initialValue: ascending,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: true,
                            child: Text('Ascending'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Descending'),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            ascending = value ?? true;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(
                                  sheetContext,
                                  const OpportunityFilter(),
                                );
                              },
                              child: const Text('CLEAR FILTERS'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(
                                  sheetContext,
                                  OpportunityFilter(
                                    salesStage: stage,
                                    assignedTo: assignedTo,
                                    dateFrom: dateFrom,
                                    dateTo: dateTo,
                                    sortBy: sortBy,
                                    sortAscending: ascending,
                                  ),
                                );
                              },
                              child: const Text('APPLY'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;

    setState(() {
      filter = result;
      offset = 0;
    });

    loadOpportunities();
  }


  Future<void> _chooseRecordScope() async {
    if (SessionManager.isAdmin) return;
    final result = await showStatsScopePicker(context, myStatsOnly);
    if (result == null || !mounted || result == myStatsOnly) return;
    setState(() {
      myStatsOnly = result;
      offset = 0;
    });
    loadOpportunities();
  }
  @override
  Widget build(BuildContext context) {
    if (!PermissionManager.canList('Opportunities')) {
      return const Scaffold(
        body: Center(
          child: Text('You do not have permission to access Opportunities.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunities'),
        actions: [
          if (!SessionManager.isAdmin)
            IconButton(
              tooltip: myStatsOnly ? 'Showing My Statistics' : 'Showing All Accessible',
              icon: Icon(myStatsOnly ? Icons.person : Icons.groups),
              onPressed: _chooseRecordScope,
            ),
          IconButton(
            tooltip: 'New Opportunity',
            icon: const Icon(Icons.add),
            onPressed: _newOpportunity,
          ),
          IconButton(
            tooltip: 'Filter Opportunities',
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
                hintText: 'Search Opportunities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _debounce?.cancel();

                setState(() {
                  search = value.trim();
                  offset = 0;
                });

                if (search.isEmpty) {
                  loadOpportunities();
                  return;
                }

                _debounce = Timer(
                  const Duration(milliseconds: 500),
                  () {
                    if (mounted) loadOpportunities();
                  },
                );
              },
            ),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: loadOpportunities,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: opportunities.length,
                      itemBuilder: (context, index) {
                        final opportunity = opportunities[index];

                        return OpportunityCard(
                          opportunity: opportunity,
                          onTap: () async {
                            final changed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OpportunityDetailScreen(
                                  opportunity: opportunity,
                                ),
                              ),
                            );

                            if (changed == true && mounted) {
                              loadOpportunities();
                            }
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
                canGoNext: offset + pageSize < totalOpportunities,
                onPrevious: () {
                  setState(() {
                    offset -= pageSize;
                    if (offset < 0) offset = 0;
                  });
                  loadOpportunities();
                },
                onNext: () {
                  setState(() {
                    offset += pageSize;
                  });
                  loadOpportunities();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
