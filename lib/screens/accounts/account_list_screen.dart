import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../services/account_service.dart';
import '../../services/session_manager.dart';
import '../../widgets/stats_scope_picker.dart';
import '../../widgets/account_card.dart';
import '../../widgets/pager_widget.dart';
import 'account_detail_screen.dart';
import 'account_form_screen.dart';
import '../../services/permission_manager.dart';

class AccountListScreen extends StatefulWidget {
  final bool? myStatsOnly;

  const AccountListScreen({super.key, this.myStatsOnly});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  late bool myStatsOnly;
  final AccountService _service = AccountService();
  final TextEditingController searchController =
      TextEditingController();

  Timer? _searchDebounce;
  int _requestId = 0;

  List<Account> accounts = [];
  bool loading = true;

  int offset = 0;
  static const int pageSize = 25;
  int totalAccounts = 0;
  String search = '';

  AccountFilter filter = const AccountFilter();

  int get currentPage => (offset ~/ pageSize) + 1;

  int get totalPages =>
      totalAccounts == 0 ? 1 : (totalAccounts / pageSize).ceil();

  @override
  void initState() {
    super.initState();
    myStatsOnly = widget.myStatsOnly ?? !SessionManager.isAdmin;
    loadAccounts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadAccounts() async {
    final requestId = ++_requestId;

    setState(() {
      loading = true;
      totalAccounts = 0;
    });

    try {
      final results = await _service.getAccounts(
        search: search,
        offset: offset,
        maxResults: pageSize,
        filter: filter,
        myStatsOnly: myStatsOnly,
      );

      if (!mounted || requestId != _requestId) return;

      setState(() {
        accounts = results;
        totalAccounts = offset + results.length;
        loading = false;
      });

      try {
        final count = await _service
            .getAccountCount(
              search: search,
              filter: filter,
        myStatsOnly: myStatsOnly,
            )
            .timeout(const Duration(seconds: 5));

        if (!mounted || requestId != _requestId) return;

        setState(() {
          totalAccounts = count;
        });
      } catch (_) {
        // Results are already visible. A slow count must not block the UI.
      }
    } catch (e) {
      if (!mounted || requestId != _requestId) return;

      setState(() {
        accounts = [];
        totalAccounts = 0;
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load accounts.'),
        ),
      );
    }
  }

  Future<void> _newAccount() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AccountFormScreen(),
      ),
    );

    if (created == true && mounted) {
      loadAccounts();
    }
  }

  Future<void> _showFilter() async {
    var selectedType = filter.type;
    var selectedIndustry = filter.industry;
    var selectedSortBy = filter.sortBy;
    var selectedAscending = filter.sortAscending;

    const types = [
      '',
      'Analyst',
      'Competitor',
      'Customer',
      'Integrator',
      'Investor',
      'Partner',
      'Press',
      'Prospect',
      'Reseller',
      'Other',
    ];

    const industries = [
      '',
      'Apparel',
      'Banking',
      'Biotechnology',
      'Chemicals',
      'Communications',
      'Construction',
      'Consulting',
      'Education',
      'Electronics',
      'Energy',
      'Engineering',
      'Entertainment',
      'Environmental',
      'Finance',
      'Government',
      'Healthcare',
      'Hospitality',
      'Insurance',
      'Machinery',
      'Manufacturing',
      'Media',
      'Retail',
      'Technology',
      'Telecommunications',
      'Transportation',
      'Utilities',
      'Other',
    ];

    final result = await showModalBottomSheet<AccountFilter>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filter Accounts',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      _filterDropdown(
                        'Account Type',
                        selectedType,
                        types,
                        (v) => setModalState(
                          () => selectedType = v ?? '',
                        ),
                      ),
                      _filterDropdown(
                        'Industry',
                        selectedIndustry,
                        industries,
                        (v) => setModalState(
                          () => selectedIndustry = v ?? '',
                        ),
                      ),
                      _filterDropdown(
                        'Sort By',
                        selectedSortBy,
                        const [
                          'name',
                          'date_entered',
                          'industry',
                          'type',
                        ],
                        (v) => setModalState(
                          () => selectedSortBy = v ?? 'name',
                        ),
                        labels: const {
                          'name': 'Account Name',
                          'date_entered': 'Date Created',
                          'industry': 'Industry',
                          'type': 'Account Type',
                        },
                      ),
                      _filterDropdown(
                        'Order',
                        selectedAscending ? 'asc' : 'desc',
                        const ['asc', 'desc'],
                        (v) => setModalState(
                          () => selectedAscending = v == 'asc',
                        ),
                        labels: const {
                          'asc': 'A → Z / Oldest First',
                          'desc': 'Z → A / Newest First',
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                  const AccountFilter(),
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
                                  context,
                                  AccountFilter(
                                    type: selectedType,
                                    industry: selectedIndustry,
                                    sortBy: selectedSortBy,
                                    sortAscending: selectedAscending,
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

    if (result != null && mounted) {
      setState(() {
        filter = result;
        offset = 0;
      });
      loadAccounts();
    }
  }

  Widget _filterDropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String?> onChanged, {
    Map<String, String>? labels,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: values.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              labels?[item] ??
                  (item.isEmpty ? 'All' : item),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }


  Future<void> _chooseRecordScope() async {
    if (SessionManager.isAdmin) return;
    final result = await showStatsScopePicker(context, myStatsOnly);
    if (result == null || !mounted || result == myStatsOnly) return;
    setState(() {
      myStatsOnly = result;
      offset = 0;
    });
    loadAccounts();
  }
  @override
  Widget build(BuildContext context) {
    if (!PermissionManager.canList('Accounts')) {
      return const Scaffold(
        body: Center(
          child: Text('You do not have permission to access Accounts.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          if (!SessionManager.isAdmin)
            IconButton(
              tooltip: myStatsOnly ? 'Showing My Statistics' : 'Showing All Accessible',
              icon: Icon(myStatsOnly ? Icons.person : Icons.groups),
              onPressed: _chooseRecordScope,
            ),
          if (PermissionManager.canCreate('Accounts'))
            IconButton(
              tooltip: 'New Account',
            icon: const Icon(Icons.add),
            onPressed: _newAccount,
          ),
          IconButton(
            tooltip: 'Filter Accounts',
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Accounts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _searchDebounce?.cancel();

                setState(() {
                  search = value.trim();
                  offset = 0;
                });

                if (search.isEmpty) {
                  loadAccounts();
                  return;
                }

                _searchDebounce = Timer(
                  const Duration(milliseconds: 500),
                  () {
                    if (mounted) loadAccounts();
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
                    onRefresh: loadAccounts,
                    child: ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        final account = accounts[index];

                        return AccountCard(
                          account: account,
                          onTap: () async {
                            final result =
                                await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AccountDetailScreen(
                                  account: account,
                                ),
                              ),
                            );

                            if (result == true && mounted) {
                              loadAccounts();
                            }
                          },
                        );
                      },
                    ),
                  ),
          ),
          // Keep pagination outside the scrollable list and inside
          // SafeArea so it cannot be pushed behind the Android
          // navigation bar on smaller screens.
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
                canGoNext:
                    offset + pageSize < totalAccounts,
                onPrevious: () {
                  setState(() {
                    offset -= pageSize;
                    if (offset < 0) offset = 0;
                  });
                  loadAccounts();
                },
                onNext: () {
                  setState(() {
                    offset += pageSize;
                  });
                  loadAccounts();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
