import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/contact.dart';
import 'session_manager.dart';

class ContactService {
  String get _url => AppConfig.crmUrl + AppConfig.restEndpoint;

  Future<Map<String, dynamic>> _request(
    String method,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'method': method,
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode(data),
      },
    );

    final json = jsonDecode(response.body);

    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid SuiteCRM response.');
    }

    if (json['number'] != null && json['name'] != null) {
      throw Exception(
        'SuiteCRM error: ${json['name']} - ${json['description'] ?? ''}',
      );
    }

    return json;
  }

  String _query(String search, ContactFilter filter, bool myStatsOnly) {
    final conditions = <String>[];

    if (myStatsOnly && SessionManager.userId != null) {
      conditions.add("contacts.assigned_user_id = '${SessionManager.userId}'");
    }

    final safeSearch = search.replaceAll("'", "''");
    if (safeSearch.isNotEmpty) {
      conditions.add(
        "(contacts.first_name LIKE '%$safeSearch%' "
        "OR contacts.last_name LIKE '%$safeSearch%' "
        "OR contacts.title LIKE '%$safeSearch%')",
      );
    }

    if (filter.leadSource.isNotEmpty) {
      final value = filter.leadSource.replaceAll("'", "''");
      conditions.add("contacts.lead_source = '$value'");
    }

    if (filter.department.isNotEmpty) {
      final value = filter.department.replaceAll("'", "''");
      conditions.add("contacts.department = '$value'");
    }

    return conditions.isEmpty ? '' : conditions.join(' AND ');
  }

  String _orderBy(ContactFilter filter) {
    const allowed = {
      'last_name': 'last_name',
      'first_name': 'first_name',
      'date_created': 'date_created',
      'title': 'title',
      'department': 'department',
    };

    final field = allowed[filter.sortBy] ?? 'last_name';
    return '$field ${filter.sortAscending ? 'ASC' : 'DESC'}';
  }

  Future<List<Contact>> getContacts({
    String search = '',
    int offset = 0,
    int maxResults = 25,
    ContactFilter filter = const ContactFilter(),
    bool myStatsOnly = false,
  }) async {
    final json = await _request(
      'get_entry_list',
      {
        'session': SessionManager.sessionId,
        'module_name': 'Contacts',
        'query': _query(search, filter, myStatsOnly),
        'order_by': _orderBy(filter),
        'offset': offset,
        'select_fields': [
          'id',
          'first_name',
          'last_name',
          'account_name',
          'title',
          'department',
          'phone_work',
          'phone_mobile',
          'email1',
          'website',
          'primary_address_street',
          'primary_address_city',
          'primary_address_state',
          'primary_address_postalcode',
          'primary_address_country',
          'lead_source',
          'description',
          'assigned_user_name',
          'date_created',
        ],
        'max_results': maxResults,
        'deleted': 0,
      },
    );

    final entries = json['entry_list'];
    if (entries is! List) return [];

    return entries.map<Contact>((entry) {
      final fields = entry['name_value_list'] as Map;

      String value(String key) =>
          fields[key]?['value']?.toString() ?? '';

      return Contact(
        id: value('id'),
        firstName: value('first_name'),
        lastName: value('last_name'),
        accountName: value('account_name'),
        title: value('title'),
        department: value('department'),
        phoneWork: value('phone_work'),
        phoneMobile: value('phone_mobile'),
        email: value('email1'),
        website: value('website'),
        street: value('primary_address_street'),
        city: value('primary_address_city'),
        state: value('primary_address_state'),
        postalCode: value('primary_address_postalcode'),
        country: value('primary_address_country'),
        leadSource: value('lead_source'),
        description: value('description'),
        assignedTo: value('assigned_user_name'),
      );
    }).toList();
  }

  Future<int> getContactCount({
    String search = '',
    ContactFilter filter = const ContactFilter(),
    bool myStatsOnly = false,
  }) async {
    final json = await _request(
      'get_entries_count',
      {
        'session': SessionManager.sessionId,
        'module_name': 'Contacts',
        'query': _query(search, filter, myStatsOnly),
        'deleted': 0,
      },
    );

    return int.tryParse(json['result_count'].toString()) ?? 0;
  }

  Future<Contact?> getContact(String id) async {
    final json = await _request(
      'get_entry',
      {
        'session': SessionManager.sessionId,
        'module_name': 'Contacts',
        'id': id,
        'select_fields': [
          'id',
          'first_name',
          'last_name',
          'account_name',
          'title',
          'department',
          'phone_work',
          'phone_mobile',
          'email1',
          'website',
          'primary_address_street',
          'primary_address_city',
          'primary_address_state',
          'primary_address_postalcode',
          'primary_address_country',
          'lead_source',
          'description',
          'assigned_user_name',
        ],
      },
    );

    final entries = json['entry_list'];
    if (entries is! List || entries.isEmpty) return null;

    final fields = entries.first['name_value_list'] as Map;
    String value(String key) =>
        fields[key]?['value']?.toString() ?? '';

    return Contact(
      id: value('id'),
      firstName: value('first_name'),
      lastName: value('last_name'),
      accountName: value('account_name'),
      title: value('title'),
      department: value('department'),
      phoneWork: value('phone_work'),
      phoneMobile: value('phone_mobile'),
      email: value('email1'),
      website: value('website'),
      street: value('primary_address_street'),
      city: value('primary_address_city'),
      state: value('primary_address_state'),
      postalCode: value('primary_address_postalcode'),
      country: value('primary_address_country'),
      leadSource: value('lead_source'),
      description: value('description'),
      assignedTo: value('assigned_user_name'),
    );
  }

  Future<bool> _setEntry({
    String? id,
    required Map<String, String> values,
  }) async {
    final fields = <Map<String, String>>[];

    if (id != null) {
      fields.add({'name': 'id', 'value': id});
    }

    values.forEach((key, value) {
      fields.add({'name': key, 'value': value});
    });

    final json = await _request(
      'set_entry',
      {
        'session': SessionManager.sessionId,
        'module_name': 'Contacts',
        'name_value_list': fields,
      },
    );

    return json.containsKey('id');
  }

  Future<bool> createContact({
    required String firstName,
    required String lastName,
    String accountName = '',
    String title = '',
    String department = '',
    String phoneWork = '',
    String phoneMobile = '',
    String email = '',
    String website = '',
    String street = '',
    String city = '',
    String state = '',
    String postalCode = '',
    String country = '',
    String leadSource = '',
    String description = '',
    String assignedTo = '',
  }) {
    return _setEntry(
      values: {
        'first_name': firstName,
        'last_name': lastName,
        'account_name': accountName,
        'title': title,
        'department': department,
        'phone_work': phoneWork,
        'phone_mobile': phoneMobile,
        'email1': email,
        'website': website,
        'primary_address_street': street,
        'primary_address_city': city,
        'primary_address_state': state,
        'primary_address_postalcode': postalCode,
        'primary_address_country': country,
        'lead_source': leadSource,
        'description': description,
        if (assignedTo.isNotEmpty) 'assigned_user_name': assignedTo,
      },
    );
  }

  Future<bool> updateContact({
    required String id,
    required String firstName,
    required String lastName,
    String accountName = '',
    String title = '',
    String department = '',
    String phoneWork = '',
    String phoneMobile = '',
    String email = '',
    String website = '',
    String street = '',
    String city = '',
    String state = '',
    String postalCode = '',
    String country = '',
    String leadSource = '',
    String description = '',
    String assignedTo = '',
  }) {
    return _setEntry(
      id: id,
      values: {
        'first_name': firstName,
        'last_name': lastName,
        'account_name': accountName,
        'title': title,
        'department': department,
        'phone_work': phoneWork,
        'phone_mobile': phoneMobile,
        'email1': email,
        'website': website,
        'primary_address_street': street,
        'primary_address_city': city,
        'primary_address_state': state,
        'primary_address_postalcode': postalCode,
        'primary_address_country': country,
        'lead_source': leadSource,
        'description': description,
        if (assignedTo.isNotEmpty) 'assigned_user_name': assignedTo,
      },
    );
  }
}
