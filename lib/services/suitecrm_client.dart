import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/opportunity.dart';
import '../config/app_config.dart';
import '../models/lead.dart';
import 'session_manager.dart';

class SuiteCRMClient {
  String _decodeHtml(String value) {
    return value
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  Future<Map<String, dynamic>> login(
    String username,
    String md5Password,
  ) async {
    final response = await http.post(
      Uri.parse(
        AppConfig.crmUrl + AppConfig.restEndpoint,
      ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'method': 'login',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'user_auth': {
            'user_name': username,
            'password': md5Password,
          },
          'application_name': 'OpenCRMMobile',
        }),
      },
    );

    return jsonDecode(response.body);
  }

  Future<int> getEntriesCount(
    String module,
  ) async {
    final response = await http.post(
      Uri.parse(
        AppConfig.crmUrl + AppConfig.restEndpoint,
      ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'method': 'get_entries_count',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': module,
          'query': '',
          'deleted': 0,
        }),
      },
    );

    final json = jsonDecode(response.body);

    return int.parse(
      json['result_count'].toString(),
    );
  }
  Future<int> getEntriesCountWhere(
    String module,
    String query,
  ) async {
    final response = await http.post(
      Uri.parse(
        AppConfig.crmUrl + AppConfig.restEndpoint,
      ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'method': 'get_entries_count',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': module,
          'query': query,
          'deleted': 0,
        }),
      },
    );

    final json = jsonDecode(response.body);

    return int.parse(
      json['result_count'].toString(),
    );
  }
  Future<int> getLeadCount({
    String search = '',
    LeadFilter? filter,
    bool myStatsOnly = false,
  }) async {
    final response = await http.post(
      Uri.parse(AppConfig.crmUrl + AppConfig.restEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'method': 'get_entries_count',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': 'Leads',
          'query': _buildLeadQuery(search, filter, myStatsOnly),
          'deleted': 0,
        }),
      },
    ).timeout(const Duration(seconds: 5));

    final json = jsonDecode(response.body);
    return int.tryParse(json['result_count'].toString()) ?? 0;
  }

  Future<List<Lead>> getLeadList({
    String search = '',
    int offset = 0,
    int maxResults = 25,
    LeadFilter? filter,
    bool myStatsOnly = false,
  }) async {
    final response = await http.post(
      Uri.parse(AppConfig.crmUrl + AppConfig.restEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'method': 'get_entry_list',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': 'Leads',
          'query': _buildLeadQuery(search, filter, myStatsOnly),
          'order_by': _getLeadOrderBy(filter),
          'offset': offset,
          'select_fields': [
            'id', 'first_name', 'last_name', 'account_name', 'title',
            'phone_work', 'phone_mobile', 'email1', 'website',
            'primary_address_street', 'primary_address_city',
            'primary_address_state', 'primary_address_postalcode',
            'primary_address_country', 'description', 'status',
            'lead_source', 'assigned_user_name', 'date_entered',
          ],
          'max_results': maxResults,
          'deleted': 0,
        }),
      },
    ).timeout(const Duration(seconds: 10));

    final json = jsonDecode(response.body);
    if (json['entry_list'] == null) {
      final error = json['name']?.toString() ??
          json['description']?.toString() ??
          response.body;
      // Lead search errors are surfaced to the caller/UI.
      throw Exception('SuiteCRM Lead search failed: $error');
    }

    final List<Lead> leads = [];
    for (final entry in json['entry_list']) {
      final fields = entry['name_value_list'] as Map<String, dynamic>;
      String value(String key) => fields[key]?['value']?.toString() ?? '';

      leads.add(Lead(
        id: value('id'),
        firstName: _decodeHtml(value('first_name')),
        lastName: _decodeHtml(value('last_name')),
        accountName: _decodeHtml(value('account_name')),
        title: _decodeHtml(value('title')),
        phoneWork: value('phone_work'),
        phoneMobile: value('phone_mobile'),
        email: value('email1'),
        website: value('website'),
        street: _decodeHtml(value('primary_address_street')),
        suburb: '',
        city: _decodeHtml(value('primary_address_city')),
        province: _decodeHtml(value('primary_address_state')),
        postalCode: value('primary_address_postalcode'),
        country: _decodeHtml(value('primary_address_country')),
        description: _decodeHtml(value('description')),
        status: _decodeHtml(value('status')),
        leadSource: _decodeHtml(value('lead_source')),
        assignedTo: _decodeHtml(value('assigned_user_name')),
        dateCreated: value('date_entered'),
      ));
    }
    return leads;
  }

  String _buildLeadQuery(String search, LeadFilter? filter, bool myStatsOnly) {
    final parts = <String>[];
    if (myStatsOnly && SessionManager.userId != null) {
      parts.add("leads.assigned_user_id = '${SessionManager.userId}'");
    }
    final safeSearch = search.replaceAll("'", "''").trim();

    if (safeSearch.isNotEmpty) {
      // Keep this identical to the proven SuiteCRM Leads search expression.
      // These are the standard searchable Leads columns and avoid adding
      // fields that can behave differently on customised SuiteCRM installs.
      parts.add("leads.first_name LIKE '%$safeSearch%' "
          "OR leads.last_name LIKE '%$safeSearch%' "
          "OR leads.account_name LIKE '%$safeSearch%'");
    }
    if (filter != null) {
      if (filter.status.isNotEmpty) {
        parts.add("leads.status = '${filter.status.replaceAll("'", "''")}'");
      }
      if (filter.leadSource.isNotEmpty) {
        parts.add("leads.lead_source = '${filter.leadSource.replaceAll("'", "''")}'");
      }
      if (filter.assignedTo.isNotEmpty) {
        final a = filter.assignedTo.replaceAll("'", "''");
        parts.add("leads.assigned_user_name LIKE '%$a%'");
      }
      if (filter.dateFrom.isNotEmpty) {
        parts.add("DATE(leads.date_entered) >= '${filter.dateFrom}'");
      }
      if (filter.dateTo.isNotEmpty) {
        parts.add("DATE(leads.date_entered) <= '${filter.dateTo}'");
      }
    }
    return parts.join(' AND ');
  }

  String _getLeadOrderBy(LeadFilter? filter) {
    final field = <String, String>{
      'date_created': 'date_entered',
      'name': 'last_name',
      'status': 'status',
      'lead_source': 'lead_source',
      'assigned_to': 'assigned_user_name',
      'company': 'account_name',
    }[filter?.sortBy] ?? 'date_entered';
    final direction = filter?.sortAscending == true ? 'ASC' : 'DESC';
    return '$field $direction';
  }

  Future<bool> createLead(Lead lead) async {
    final response = await http.post(
      Uri.parse(AppConfig.crmUrl + AppConfig.restEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'method': 'set_entry',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': 'Leads',
          'name_value_list': _leadNameValueList(lead),
        }),
      },
    );
    final json = jsonDecode(response.body);
    return json.containsKey('id');
  }

  Future<bool> updateLead(Lead lead) async {
    final response = await http.post(
      Uri.parse(AppConfig.crmUrl + AppConfig.restEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'method': 'set_entry',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': 'Leads',
          'name_value_list': [
            {'name': 'id', 'value': lead.id},
            ..._leadNameValueList(lead),
          ],
        }),
      },
    );
    final json = jsonDecode(response.body);
    return json.containsKey('id');
  }

  List<Map<String, String>> _leadNameValueList(Lead lead) => [
        {'name': 'first_name', 'value': lead.firstName},
        {'name': 'last_name', 'value': lead.lastName},
        {'name': 'account_name', 'value': lead.accountName},
        {'name': 'title', 'value': lead.title},
        {'name': 'phone_work', 'value': lead.phoneWork},
        {'name': 'phone_mobile', 'value': lead.phoneMobile},
        {'name': 'email1', 'value': lead.email},
        {'name': 'website', 'value': lead.website},
        {'name': 'primary_address_street', 'value': lead.street},
        {'name': 'primary_address_city', 'value': lead.city},
        {'name': 'primary_address_state', 'value': lead.province},
        {'name': 'primary_address_postalcode', 'value': lead.postalCode},
        {'name': 'primary_address_country', 'value': lead.country},
        {'name': 'description', 'value': lead.description},
        {'name': 'status', 'value': lead.status},
        {'name': 'lead_source', 'value': lead.leadSource},
        if (lead.assignedTo.isNotEmpty)
          {'name': 'assigned_user_name', 'value': lead.assignedTo},
      ];

  Future<bool> deleteLead(
    String id,
  ) async {
    final response = await http.post(
      Uri.parse(
        AppConfig.crmUrl + AppConfig.restEndpoint,
      ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'method': 'set_entry',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': 'Leads',
          'name_value_list': [
            {
              'name': 'id',
              'value': id,
            },
            {
              'name': 'deleted',
              'value': '1',
            },
          ],
        }),
      },
    );

    final json = jsonDecode(response.body);

    return json.containsKey('id');
  }

  Future<bool> createOpportunity({
    required String name,
    required String accountName,
    required String amount,
    required String salesStage,
    required String probability,
    required String dateClosed,
    required String type,
    required String leadSource,
    required String nextStep,
    required String description,
    String assignedTo = '',
  }) async {
    final response = await http.post(
      Uri.parse(
        AppConfig.crmUrl + AppConfig.restEndpoint,
      ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'method': 'set_entry',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': 'Opportunities',
          'name_value_list': [
            {'name': 'name', 'value': name},
            {'name': 'account_name', 'value': accountName},
            {'name': 'amount', 'value': amount},
            {'name': 'sales_stage', 'value': salesStage},
            {'name': 'probability', 'value': probability},
            {'name': 'date_closed', 'value': dateClosed},
            {'name': 'opportunity_type', 'value': type},
            {'name': 'lead_source', 'value': leadSource},
            {'name': 'next_step', 'value': nextStep},
            {'name': 'description', 'value': description},
            if (assignedTo.isNotEmpty)
              {'name': 'assigned_user_name', 'value': assignedTo},
          ],
        }),
      },
    );

    final json = jsonDecode(response.body);
    return json.containsKey('id');
  }

  Future<bool> updateOpportunity({
    required String id,
    required String name,
    required String accountName,
    required String amount,
    required String salesStage,
    required String probability,
    required String dateClosed,
    required String type,
    required String leadSource,
    required String nextStep,
    required String description,
    String assignedTo = '',
  }) async {
    final response = await http.post(
      Uri.parse(
        AppConfig.crmUrl + AppConfig.restEndpoint,
      ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'method': 'set_entry',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': 'Opportunities',
          'name_value_list': [
            {'name': 'id', 'value': id},
            {'name': 'name', 'value': name},
            {'name': 'account_name', 'value': accountName},
            {'name': 'amount', 'value': amount},
            {'name': 'sales_stage', 'value': salesStage},
            {'name': 'probability', 'value': probability},
            {'name': 'date_closed', 'value': dateClosed},
            {'name': 'opportunity_type', 'value': type},
            {'name': 'lead_source', 'value': leadSource},
            {'name': 'next_step', 'value': nextStep},
            {'name': 'description', 'value': description},
            if (assignedTo.isNotEmpty)
              {'name': 'assigned_user_name', 'value': assignedTo},
          ],
        }),
      },
    );

    final json = jsonDecode(response.body);
    return json.containsKey('id');
  }

  Future<double> getTotalOpportunityValue({String query = ''}) async {
    const batchSize = 1000;
    var offset = 0;
    var total = 0.0;

    while (true) {
      final response = await http
          .post(
            Uri.parse(
              AppConfig.crmUrl + AppConfig.restEndpoint,
            ),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {
              'method': 'get_entry_list',
              'input_type': 'JSON',
              'response_type': 'JSON',
              'rest_data': jsonEncode({
                'session': SessionManager.sessionId,
                'module_name': 'Opportunities',
                'query': query,
                'order_by': 'id ASC',
                'offset': offset,
                'select_fields': ['id', 'amount'],
                'max_results': batchSize,
                'deleted': 0,
              }),
            },
          )
          .timeout(const Duration(seconds: 15));

      final json = jsonDecode(response.body);
      final entries = json['entry_list'];

      if (entries is! List || entries.isEmpty) {
        break;
      }

      for (final entry in entries) {
        final fields = entry['name_value_list'];
        final amount = double.tryParse(
              fields['amount']?['value']?.toString() ?? '0',
            ) ??
            0;
        total += amount;
      }

      if (entries.length < batchSize) {
        break;
      }

      offset += batchSize;
    }

    return total;
  }

  Future<int> getOpportunityCount({
    String search = "",
    OpportunityFilter? filter,
    bool myStatsOnly = false,
  }) async {
    final response = await http.post(
      Uri.parse(
        AppConfig.crmUrl + AppConfig.restEndpoint,
      ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'method': 'get_entries_count',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': 'Opportunities',
          'query': _buildOpportunityQuery(search, filter, myStatsOnly),
          'deleted': 0,
        }),
      },
    ).timeout(const Duration(seconds: 5));

    final json = jsonDecode(response.body);

    return int.parse(
      json['result_count'].toString(),
    );
  }

  Future<List<Opportunity>> getOpportunityList({
    String search = "",
    int offset = 0,
    int maxResults = 25,
    OpportunityFilter? filter,
    bool myStatsOnly = false,
  }) async {
    final response = await http.post(
      Uri.parse(
        AppConfig.crmUrl + AppConfig.restEndpoint,
      ),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'method': 'get_entry_list',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': 'Opportunities',
          'query': _buildOpportunityQuery(search, filter, myStatsOnly),
          'order_by': _getOpportunityOrderBy(filter),
          'offset': offset,
          'select_fields': [
            'id',
            'name',
            'account_name',
            'amount',
            'sales_stage',
            'probability',
            'date_closed',
            'opportunity_type',
            'lead_source',
            'next_step',
            'description',
            'assigned_user_name',
          ],
          'max_results': maxResults,
          'deleted': 0,
        }),
      },
    );

    final json = jsonDecode(response.body);

    if (json['entry_list'] == null) {
      throw Exception(
        'SuiteCRM Opportunity search failed: ${response.body}',
      );
    }

    final List<Opportunity> opportunities = [];

    final entries = json['entry_list'];

    for (final entry in entries) {
      final fields = entry['name_value_list'];

      final amount =
          double.tryParse(
            fields['amount']?['value']?.toString() ?? '0',
          ) ??
          0;

      final probability =
          int.tryParse(
            fields['probability']?['value']?.toString() ?? '0',
          ) ??
          0;

      opportunities.add(
        Opportunity(
          id: fields['id']?['value'] ?? '',
          name: _decodeHtml(
            fields['name']?['value']?.toString() ?? '',
          ),
          accountName:
              fields['account_name']?['value'] ?? '',
          amount: amount,
          probability: probability,
          salesStage:
              fields['sales_stage']?['value'] ?? '',
          expectedCloseDate:
              fields['date_closed']?['value'] ?? '',
          type:
              fields['opportunity_type']?['value'] ?? '',
          leadSource:
              fields['lead_source']?['value'] ?? '',
          nextStep:
              fields['next_step']?['value'] ?? '',
          description:
              fields['description']?['value'] ?? '',
          assignedTo:
              fields['assigned_user_name']?['value']?.toString() ?? '',
        ),
      );
    }

    return opportunities;
  }

  String _getOpportunityOrderBy(OpportunityFilter? filter) {
    if (filter == null || filter.sortBy.isEmpty) {
      return 'date_closed ASC';
    }

    const allowedSortFields = {
      'date_closed': 'date_closed',
      'name': 'name',
      'amount': 'amount',
      'probability': 'probability',
      'sales_stage': 'sales_stage',
    };

    final field = allowedSortFields[filter.sortBy] ?? 'date_closed';
    final direction = filter.sortAscending ? 'ASC' : 'DESC';

    return '$field $direction';
  }

  String _buildOpportunityQuery(
    String search,
    OpportunityFilter? filter,
    bool myStatsOnly,
  ) {
    final conditions = <String>[];

    if (myStatsOnly && SessionManager.userId != null) {
      conditions.add("opportunities.assigned_user_id = '${SessionManager.userId}'");
    }

    if (search.isNotEmpty) {
      // Search the real Opportunities name field. `account_name` is a
      // SuiteCRM relate/display field and is not reliably queryable as
      // opportunities.account_name in the REST SQL-style query.
      final safeSearch = search.replaceAll("'", "''");

      conditions.add(
        "opportunities.name LIKE '%$safeSearch%'",
      );
    }

    if (filter != null) {
      if (filter.salesStage.isNotEmpty) {
        conditions.add(
          "opportunities.sales_stage = '${filter.salesStage}'",
        );
      }

      if (filter.assignedTo.isNotEmpty) {
        final safeAssigned = filter.assignedTo.replaceAll("'", "''");
        conditions.add(
          "opportunities.assigned_user_name = '$safeAssigned'",
        );
      }

      if (filter.dateFrom.isNotEmpty) {
        conditions.add(
          "opportunities.date_closed >= '${filter.dateFrom}'",
        );
      }

      if (filter.dateTo.isNotEmpty) {
        conditions.add(
          "opportunities.date_closed <= '${filter.dateTo}'",
        );
      }
    }

    return conditions.join(' AND ');
  }
  Future<Map<String, Map<String, bool>>> getAvailableModulePermissions() async {
    final response = await http.post(
      Uri.parse(AppConfig.crmUrl + AppConfig.restEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'method': 'get_available_modules',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'filter': 'all',
        }),
      },
    ).timeout(const Duration(seconds: 10));

    final json = jsonDecode(response.body);
    final modules = json['modules'];
    final result = <String, Map<String, bool>>{};

    if (modules is List) {
      for (final module in modules) {
        if (module is! Map) continue;
        final key = module['module_key']?.toString() ?? '';
        if (key.isEmpty) continue;
        final acl = <String, bool>{};
        final acls = module['acls'];
        if (acls is List) {
          for (final entry in acls) {
            if (entry is! Map) continue;
            final action = entry['action']?.toString().toLowerCase() ?? '';
            if (action.isEmpty) continue;
            final access = entry['access'];
            acl[action] = access == true ||
                access.toString().toLowerCase() == 'true' ||
                access.toString() == '1';
          }
        }
        result[key] = acl;
      }
    }

    return result;
  }

  Future<List<String>> getModuleFieldOptions(
    String module,
    String field,
  ) async {
    final response = await http.post(
      Uri.parse(AppConfig.crmUrl + AppConfig.restEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'method': 'get_module_fields',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': module,
          'fields': [field],
        }),
      },
    ).timeout(const Duration(seconds: 10));

    final json = jsonDecode(response.body);
    final moduleFields = json['module_fields'];
    if (moduleFields is! Map) return [];

    final fieldDefinition = moduleFields[field];
    if (fieldDefinition is! Map) return [];

    final options = fieldDefinition['options'];
    if (options is! List) return [];

    final values = <String>[];
    for (final option in options) {
      if (option is! Map) continue;
      final value = option['value']?.toString().trim() ?? '';
      final name = option['name']?.toString().trim() ?? '';
      final display = value.isNotEmpty ? value : name;
      if (display.isNotEmpty) values.add(display);
    }
    return values;
  }

  Future<List<String>> getSimpleEntryNames(String module) async {
    final response = await http.post(
      Uri.parse(AppConfig.crmUrl + AppConfig.restEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'method': 'get_entry_list',
        'input_type': 'JSON',
        'response_type': 'JSON',
        'rest_data': jsonEncode({
          'session': SessionManager.sessionId,
          'module_name': module,
          'query': '',
          'order_by': 'name ASC',
          'offset': 0,
          'select_fields': ['id', 'name'],
          'max_results': 100,
          'deleted': 0,
        }),
      },
    ).timeout(const Duration(seconds: 10));

    final json = jsonDecode(response.body);
    final entries = json['entry_list'];
    if (entries is! List) return [];

    final names = <String>[];
    for (final entry in entries) {
      if (entry is! Map) continue;
      final fields = entry['name_value_list'];
      if (fields is! Map) continue;
      final name = fields['name']?['value']?.toString().trim() ?? '';
      if (name.isNotEmpty) names.add(_decodeHtml(name));
    }
    return names;
  }

}
