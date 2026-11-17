import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/meeting.dart';
import 'session_manager.dart';

class MeetingService {
  String get _url => AppConfig.crmUrl + AppConfig.restEndpoint;

  Future<Map<String,dynamic>> _request(String method, Map<String,dynamic> data) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type':'application/x-www-form-urlencoded'},
      body: {
        'method': method,
        'input_type':'JSON',
        'response_type':'JSON',
        'rest_data': jsonEncode(data),
      },
    );
    final json = jsonDecode(response.body);
    if (json is! Map<String,dynamic>) throw Exception('Invalid SuiteCRM response.');
    if (json['number'] != null && json['name'] != null) {
      throw Exception('SuiteCRM error: ${json['name']} - ${json['description'] ?? ''}');
    }
    return json;
  }

  String _query(String search, MeetingFilter filter, bool myStatsOnly) {
    final conditions = <String>[];
    if (myStatsOnly && SessionManager.userId != null) {
      conditions.add("meetings.assigned_user_id = '${SessionManager.userId}'");
    }
    final safe = search.replaceAll("'", "''");
    if (safe.isNotEmpty) {
      conditions.add("(meetings.name LIKE '%$safe%' OR meetings.location LIKE '%$safe%')");
    }
    if (filter.status.isNotEmpty) {
      final v=filter.status.replaceAll("'", "''");
      conditions.add("meetings.status = '$v'");
    }
    return conditions.isEmpty ? '' : conditions.join(' AND ');
  }

  String _orderBy(MeetingFilter filter) {
    const fields = {
      'date_start':'date_start',
      'name':'name',
      'status':'status',
      'location':'location',
    };
    return '${fields[filter.sortBy] ?? 'date_start'} ${filter.sortAscending ? 'ASC' : 'DESC'}';
  }

  List<String> get _fields => const [
    'id','name','date_start','duration_hours','duration_minutes',
    'status','location','assigned_user_name','parent_name','description'
  ];

  Meeting _parse(Map entry) {
    final f=entry['name_value_list'] as Map;
    String v(String k)=>f[k]?['value']?.toString() ?? '';
    return Meeting(
      id:v('id'), name:v('name'), dateStart:v('date_start'),
      durationHours:v('duration_hours'), durationMinutes:v('duration_minutes'),
      status:v('status'), location:v('location'),
      assignedTo:v('assigned_user_name'), parentName:v('parent_name'),
      description:v('description'),
    );
  }

  Future<List<Meeting>> getMeetings({
    String search='', int offset=0, int maxResults=25,
    MeetingFilter filter=const MeetingFilter(),
    bool myStatsOnly=false,
  }) async {
    final json=await _request('get_entry_list',{
      'session':SessionManager.sessionId,'module_name':'Meetings',
      'query':_query(search,filter,myStatsOnly),'order_by':_orderBy(filter),'offset':offset,
      'select_fields':_fields,'max_results':maxResults,'deleted':0,
    });
    final entries=json['entry_list'];
    if(entries is! List) return [];
    return entries.map<Meeting>((e)=>_parse(e)).toList();
  }

  Future<int> getMeetingCount({String search='', MeetingFilter filter=const MeetingFilter(), bool myStatsOnly=false}) async {
    final json=await _request('get_entries_count',{
      'session':SessionManager.sessionId,'module_name':'Meetings',
      'query':_query(search,filter,myStatsOnly),'deleted':0,
    });
    return int.tryParse(json['result_count'].toString()) ?? 0;
  }

  Future<Meeting?> getMeeting(String id) async {
    final json=await _request('get_entry',{
      'session':SessionManager.sessionId,'module_name':'Meetings','id':id,
      'select_fields':_fields,
    });
    final entries=json['entry_list'];
    if(entries is! List || entries.isEmpty) return null;
    return _parse(entries.first);
  }

  Future<bool> _set(String? id, Map<String,String> values) async {
    final list=<Map<String,String>>[];
    if(id!=null) list.add({'name':'id','value':id});
    values.forEach((k,v)=>list.add({'name':k,'value':v}));
    final json=await _request('set_entry',{
      'session':SessionManager.sessionId,'module_name':'Meetings',
      'name_value_list':list,
    });
    return json.containsKey('id');
  }

  Future<bool> createMeeting({
    required String name, String dateStart='', String durationHours='0',
    String durationMinutes='0', String status='Planned', String location='',
    String assignedTo='', String parentName='', String description='',
  }) => _set(null,{
    'name':name,'date_start':dateStart,'duration_hours':durationHours,
    'duration_minutes':durationMinutes,'status':status,'location':location,
    if(assignedTo.isNotEmpty) 'assigned_user_name':assignedTo,
    if(parentName.isNotEmpty) 'parent_name':parentName,
    'description':description,
  });

  Future<bool> updateMeeting({
    required String id, required String name, String dateStart='',
    String durationHours='0', String durationMinutes='0', String status='Planned',
    String location='', String assignedTo='', String parentName='', String description='',
  }) => _set(id,{
    'name':name,'date_start':dateStart,'duration_hours':durationHours,
    'duration_minutes':durationMinutes,'status':status,'location':location,
    if(assignedTo.isNotEmpty) 'assigned_user_name':assignedTo,
    if(parentName.isNotEmpty) 'parent_name':parentName,
    'description':description,
  });
}