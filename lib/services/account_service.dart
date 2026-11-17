import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/account.dart';
import 'session_manager.dart';

class AccountService {
  Future<List<Account>> getAccounts({
    String search = '',
    int offset = 0,
    int maxResults = 25,
    AccountFilter? filter,
    bool myStatsOnly = false,
  }) async {
    final response = await _post({
      'method': 'get_entry_list',
      'input_type': 'JSON',
      'response_type': 'JSON',
      'rest_data': jsonEncode({
        'session': SessionManager.sessionId,
        'module_name': 'Accounts',
        'query': _buildQuery(search, filter, myStatsOnly),
        'order_by': _getOrderBy(filter),
        'offset': offset,
        'select_fields': _selectFields,
        'max_results': maxResults,
        'deleted': 0,
      }),
    });

    final json = jsonDecode(response.body);

    if (json['entry_list'] == null) {
      throw Exception('SuiteCRM Accounts request failed: ${response.body}');
    }

    return (json['entry_list'] as List)
        .map((entry) => _fromEntry(entry['name_value_list']))
        .toList();
  }

  Future<int> getAccountCount({
    String search = '',
    AccountFilter? filter,
    bool myStatsOnly = false,
  }) async {
    final response = await _post({
      'method': 'get_entries_count',
      'input_type': 'JSON',
      'response_type': 'JSON',
      'rest_data': jsonEncode({
        'session': SessionManager.sessionId,
        'module_name': 'Accounts',
        'query': _buildQuery(search, filter, myStatsOnly),
        'deleted': 0,
      }),
    }).timeout(const Duration(seconds: 5));

    final json = jsonDecode(response.body);

    return int.tryParse(json['result_count']?.toString() ?? '0') ?? 0;
  }

  Future<Account?> getAccount(String id) async {
    final response = await _post({
      'method': 'get_entry',
      'input_type': 'JSON',
      'response_type': 'JSON',
      'rest_data': jsonEncode({
        'session': SessionManager.sessionId,
        'module_name': 'Accounts',
        'id': id,
        'select_fields': _selectFields,
      }),
    });

    final json = jsonDecode(response.body);
    final fields = json['entry_list']?[0]?['name_value_list'];

    if (fields == null) return null;
    return _fromEntry(fields);
  }

  Future<bool> createAccount({
    required String name,
    String officePhone = '',
    String fax = '',
    String website = '',
    String email = '',
    String billingStreet = '',
    String billingCity = '',
    String billingState = '',
    String billingPostalCode = '',
    String billingCountry = '',
    String shippingStreet = '',
    String shippingCity = '',
    String shippingState = '',
    String shippingPostalCode = '',
    String shippingCountry = '',
    String type = '',
    String industry = '',
    String annualRevenue = '',
    String employees = '',
    String description = '',
    String assignedTo = '',
  }) async {
    final json = await _setEntry(
      id: null,
      values: {
        'name': name,
        'phone_office': officePhone,
        'fax': fax,
        'website': website,
        'email1': email,
        'billing_address_street': billingStreet,
        'billing_address_city': billingCity,
        'billing_address_state': billingState,
        'billing_address_postalcode': billingPostalCode,
        'billing_address_country': billingCountry,
        'shipping_address_street': shippingStreet,
        'shipping_address_city': shippingCity,
        'shipping_address_state': shippingState,
        'shipping_address_postalcode': shippingPostalCode,
        'shipping_address_country': shippingCountry,
        'account_type': type,
        'industry': industry,
        'annual_revenue': annualRevenue,
        'employees': employees,
        'description': description,
        if (assignedTo.isNotEmpty) 'assigned_user_name': assignedTo,
      },
    );

    return json.containsKey('id');
  }

  Future<bool> updateAccount({
    required String id,
    required String name,
    String officePhone = '',
    String fax = '',
    String website = '',
    String email = '',
    String billingStreet = '',
    String billingCity = '',
    String billingState = '',
    String billingPostalCode = '',
    String billingCountry = '',
    String shippingStreet = '',
    String shippingCity = '',
    String shippingState = '',
    String shippingPostalCode = '',
    String shippingCountry = '',
    String type = '',
    String industry = '',
    String annualRevenue = '',
    String employees = '',
    String description = '',
    String assignedTo = '',
  }) async {
    final json = await _setEntry(
      id: id,
      values: {
        'name': name,
        'phone_office': officePhone,
        'fax': fax,
        'website': website,
        'email1': email,
        'billing_address_street': billingStreet,
        'billing_address_city': billingCity,
        'billing_address_state': billingState,
        'billing_address_postalcode': billingPostalCode,
        'billing_address_country': billingCountry,
        'shipping_address_street': shippingStreet,
        'shipping_address_city': shippingCity,
        'shipping_address_state': shippingState,
        'shipping_address_postalcode': shippingPostalCode,
        'shipping_address_country': shippingCountry,
        'account_type': type,
        'industry': industry,
        'annual_revenue': annualRevenue,
        'employees': employees,
        'description': description,
        if (assignedTo.isNotEmpty) 'assigned_user_name': assignedTo,
      },
    );

    return json.containsKey('id');
  }

  Future<Map<String, dynamic>> _setEntry({
    required String? id,
    required Map<String, String> values,
  }) async {
    final list = <Map<String, String>>[
      if (id != null) {'name': 'id', 'value': id},
      ...values.entries.map(
        (e) => {'name': e.key, 'value': e.value},
      ),
    ];

    final response = await _post({
      'method': 'set_entry',
      'input_type': 'JSON',
      'response_type': 'JSON',
      'rest_data': jsonEncode({
        'session': SessionManager.sessionId,
        'module_name': 'Accounts',
        'name_value_list': list,
      }),
    });

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<http.Response> _post(Map<String, String> body) {
    return http.post(
      Uri.parse(AppConfig.crmUrl + AppConfig.restEndpoint),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );
  }

  static const _selectFields = [
    'id',
    'name',
    'phone_office',
    'fax',
    'website',
    'email1',
    'billing_address_street',
    'billing_address_city',
    'billing_address_state',
    'billing_address_postalcode',
    'billing_address_country',
    'shipping_address_street',
    'shipping_address_city',
    'shipping_address_state',
    'shipping_address_postalcode',
    'shipping_address_country',
    'account_type',
    'industry',
    'annual_revenue',
    'employees',
    'description',
    'assigned_user_name',
  ];

  String _buildQuery(String search, AccountFilter? filter, bool myStatsOnly) {
    final conditions = <String>["accounts.deleted = 0"];

    if (myStatsOnly && SessionManager.userId != null) {
      conditions.add("accounts.assigned_user_id = '${SessionManager.userId}'");
    }

    final safe = search.trim().replaceAll("'", "''");

    if (safe.isNotEmpty) {
      conditions.add(
        "(accounts.name LIKE '%$safe%' "
        "OR accounts.phone_office LIKE '%$safe%' "
        "OR accounts.website LIKE '%$safe%' "
        "OR accounts.billing_address_city LIKE '%$safe%')",
      );
    }

    if (filter?.type.isNotEmpty == true) {
      conditions.add(
        "accounts.account_type = '${filter!.type.replaceAll("'", "''")}'",
      );
    }

    if (filter?.industry.isNotEmpty == true) {
      conditions.add(
        "accounts.industry = '${filter!.industry.replaceAll("'", "''")}'",
      );
    }

    if (filter?.assignedTo.isNotEmpty == true) {
      conditions.add(
        "accounts.assigned_user_name = '${filter!.assignedTo.replaceAll("'", "''")}'",
      );
    }

    return conditions.join(' AND ');
  }

  String _getOrderBy(AccountFilter? filter) {
    final f = filter ?? const AccountFilter();
    final direction = f.sortAscending ? 'ASC' : 'DESC';

    switch (f.sortBy) {
      case 'date_entered':
        return 'accounts.date_entered $direction';
      case 'industry':
        return 'accounts.industry $direction';
      case 'type':
        return 'accounts.account_type $direction';
      default:
        return 'accounts.name $direction';
    }
  }

  Account _fromEntry(Map<String, dynamic> fields) {
    String value(String key) =>
        _decode(fields[key]?['value']?.toString() ?? '');

    return Account(
      id: value('id'),
      name: value('name'),
      officePhone: value('phone_office'),
      fax: value('fax'),
      website: value('website'),
      email: value('email1'),
      billingStreet: value('billing_address_street'),
      billingCity: value('billing_address_city'),
      billingState: value('billing_address_state'),
      billingPostalCode: value('billing_address_postalcode'),
      billingCountry: value('billing_address_country'),
      shippingStreet: value('shipping_address_street'),
      shippingCity: value('shipping_address_city'),
      shippingState: value('shipping_address_state'),
      shippingPostalCode: value('shipping_address_postalcode'),
      shippingCountry: value('shipping_address_country'),
      type: value('account_type'),
      industry: value('industry'),
      annualRevenue: value('annual_revenue'),
      employees: value('employees'),
      description: value('description'),
      assignedTo: value('assigned_user_name'),
    );
  }

  String _decode(String value) {
    return value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
}
