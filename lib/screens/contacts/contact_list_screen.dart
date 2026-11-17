import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/contact.dart';
import '../../services/contact_service.dart';
import '../../services/session_manager.dart';
import '../../widgets/stats_scope_picker.dart';
import '../../widgets/pager_widget.dart';
import '../../widgets/contact_card.dart';
import 'contact_detail_screen.dart';
import 'contact_form_screen.dart';
import '../../services/permission_manager.dart';

class ContactListScreen extends StatefulWidget {
  final bool? myStatsOnly;

  const ContactListScreen({super.key, this.myStatsOnly});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  late bool myStatsOnly;
  final _service = ContactService();
  final searchController = TextEditingController();

  Timer? _debounce;
  int _requestId = 0;

  List<Contact> contacts = [];
  bool loading = true;
  int offset = 0;
  static const pageSize = 25;
  int totalContacts = 0;
  String search = '';
  ContactFilter filter = const ContactFilter();

  int get currentPage => (offset ~/ pageSize) + 1;
  int get totalPages =>
      totalContacts == 0 ? 1 : (totalContacts / pageSize).ceil();

  @override
  void initState() {
    super.initState();
    myStatsOnly = widget.myStatsOnly ?? !SessionManager.isAdmin;
    loadContacts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadContacts() async {
    final request = ++_requestId;

    setState(() {
      loading = true;
      totalContacts = 0;
    });

    try {
      final results = await _service.getContacts(
        search: search,
        offset: offset,
        maxResults: pageSize,
        filter: filter,
        myStatsOnly: myStatsOnly,
      );

      if (!mounted || request != _requestId) return;

      setState(() {
        contacts = results;
        totalContacts = offset + results.length;
        loading = false;
      });

      try {
        final count = await _service
            .getContactCount(
              search: search,
              filter: filter,
        myStatsOnly: myStatsOnly,
            )
            .timeout(const Duration(seconds: 5));

        if (!mounted || request != _requestId) return;

        setState(() => totalContacts = count);
      } catch (_) {}
    } catch (_) {
      if (!mounted || request != _requestId) return;

      setState(() {
        contacts = [];
        totalContacts = 0;
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load contacts.'),
        ),
      );
    }
  }

  Future<void> _newContact() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ContactFormScreen(),
      ),
    );

    if (created == true && mounted) loadContacts();
  }

  Future<void> _showFilter() async {
    var source = filter.leadSource;
    var department = filter.department;
    var sortBy = filter.sortBy;
    var ascending = filter.sortAscending;

    const sources = [
      '',
      'Cold Call',
      'Existing Customer',
      'Self Generated',
      'Employee',
      'Partner',
      'Public Relations',
      'Direct Mail',
      'Conference',
      'Trade Show',
      'Web Site',
      'Word of mouth',
      'Email',
      'Campaign',
      'Other',
    ];

    final result = await showModalBottomSheet<ContactFilter>(
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
                              'Filter Contacts',
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
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        initialValue:
                            source.isEmpty ? null : source,
                        decoration: const InputDecoration(
                          labelText: 'Lead Source',
                        ),
                        items: sources
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value.isEmpty ? 'All Sources' : value,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setModalState(() {
                            source = value ?? '';
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        initialValue: department,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                        ),
                        onChanged: (value) {
                          department = value.trim();
                        },
                      ),

                      const SizedBox(height: 18),
                      const Text(
                        'Sort By',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      DropdownButtonFormField<String>(
                        initialValue: sortBy,
                        decoration: const InputDecoration(
                          labelText: 'Field',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'last_name',
                            child: Text('Last Name'),
                          ),
                          DropdownMenuItem(
                            value: 'first_name',
                            child: Text('First Name'),
                          ),
                          DropdownMenuItem(
                            value: 'date_created',
                            child: Text('Date Created'),
                          ),
                          DropdownMenuItem(
                            value: 'title',
                            child: Text('Title'),
                          ),
                          DropdownMenuItem(
                            value: 'department',
                            child: Text('Department'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => sortBy = value);
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<bool>(
                        initialValue: ascending,
                        decoration: const InputDecoration(
                          labelText: 'Order',
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
                          if (value != null) {
                            setModalState(() => ascending = value);
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                  const ContactFilter(),
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
                                  ContactFilter(
                                    leadSource: source,
                                    department: department,
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

    if (result != null && mounted) {
      setState(() {
        filter = result;
        offset = 0;
      });
      loadContacts();
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
    loadContacts();
  }
  @override
  Widget build(BuildContext context) {
    if (!PermissionManager.canList('Contacts')) {
      return const Scaffold(
        body: Center(
          child: Text('You do not have permission to access Contacts.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          if (!SessionManager.isAdmin)
            IconButton(
              tooltip: myStatsOnly ? 'Showing My Statistics' : 'Showing All Accessible',
              icon: Icon(myStatsOnly ? Icons.person : Icons.groups),
              onPressed: _chooseRecordScope,
            ),
          IconButton(
            tooltip: 'Filter Contacts',
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilter,
          ),
          if (PermissionManager.canCreate('Contacts'))
            IconButton(
              tooltip: 'New Contact',
              icon: const Icon(Icons.add),
              onPressed: _newContact,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search Contacts...',
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
                  loadContacts();
                  return;
                }

                _debounce = Timer(
                  const Duration(milliseconds: 500),
                  () {
                    if (mounted) loadContacts();
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
                    onRefresh: loadContacts,
                    child: ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];

                        return ContactCard(
                          contact: contact,
                          onTap: () async {
                            final changed =
                                await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ContactDetailScreen(
                                  contact: contact,
                                ),
                              ),
                            );

                            if (changed == true && mounted) {
                              loadContacts();
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
              padding:
                  const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: PagerWidget(
                page: currentPage,
                totalPages: totalPages,
                canGoPrevious: offset > 0,
                canGoNext:
                    offset + pageSize < totalContacts,
                onPrevious: () {
                  setState(() {
                    offset -= pageSize;
                    if (offset < 0) offset = 0;
                  });
                  loadContacts();
                },
                onNext: () {
                  setState(() => offset += pageSize);
                  loadContacts();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
