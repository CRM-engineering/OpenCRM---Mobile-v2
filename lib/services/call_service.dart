import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/call.dart';
import 'session_manager.dart';

class CallService {
  String get _url => AppConfig.crmUrl + AppConfig.restEndpoint;

  Future<Map<String,dynamic>> _request(String method, Map<String,dynamic> data) async {
    final response=await http.post(Uri.parse(_url),
      headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:{'method':method,'input_type':'JSON','response_type':'JSON','rest_data':jsonEncode(data)});
    final json=jsonDecode(response.body);
    if(json is! Map<String,dynamic>) throw Exception('Invalid SuiteCRM response.');
    if(json['number']!=null && json['name']!=null) throw Exception('SuiteCRM error: ${json['name']} - ${json['description'] ?? ''}');
    return json;
  }

  String _query(String search, CallFilter filter, bool myStatsOnly) {
    final conditions=<String>[];
    if(myStatsOnly && SessionManager.userId != null) {
      conditions.add("calls.assigned_user_id = '${SessionManager.userId}'");
    }
    final safe=search.replaceAll("'", "''");
    if(safe.isNotEmpty) conditions.add("(calls.name LIKE '%$safe%' OR calls.phone LIKE '%$safe%')");
    if(filter.status.isNotEmpty) {
      final v=filter.status.replaceAll("'", "''");
      conditions.add("calls.status = '$v'");
    }
    if(filter.direction.isNotEmpty) {
      final v=filter.direction.replaceAll("'", "''");
      conditions.add("calls.direction = '$v'");
    }
    return conditions.isEmpty ? '' : conditions.join(' AND ');
  }

  String _orderBy(CallFilter filter) {
    const fields={'date_start':'date_start','name':'name','status':'status','direction':'direction'};
    return '${fields[filter.sortBy] ?? 'date_start'} ${filter.sortAscending ? 'ASC' : 'DESC'}';
  }

  List<String> get _fields => const [
    'id','name','date_start','duration_hours','duration_minutes','status',
    'direction','phone','assigned_user_name','parent_name','description'
  ];

  CrmCall _parse(Map entry) {
    final f=entry['name_value_list'] as Map;
    String v(String k)=>f[k]?['value']?.toString() ?? '';
    return CrmCall(id:v('id'),name:v('name'),dateStart:v('date_start'),
      durationHours:v('duration_hours'),durationMinutes:v('duration_minutes'),
      status:v('status'),direction:v('direction'),phone:v('phone'),
      assignedTo:v('assigned_user_name'),parentName:v('parent_name'),
      description:v('description'));
  }

  Future<List<CrmCall>> getCalls({String search='',int offset=0,int maxResults=25,CallFilter filter=const CallFilter(), bool myStatsOnly=false}) async {
    final json=await _request('get_entry_list',{
      'session':SessionManager.sessionId,'module_name':'Calls','query':_query(search,filter,myStatsOnly),
      'order_by':_orderBy(filter),'offset':offset,'select_fields':_fields,
      'max_results':maxResults,'deleted':0});
    final entries=json['entry_list'];
    if(entries is! List) return [];
    return entries.map<CrmCall>((e)=>_parse(e)).toList();
  }

  Future<int> getCallCount({String search='',CallFilter filter=const CallFilter(), bool myStatsOnly=false}) async {
    final json=await _request('get_entries_count',{
      'session':SessionManager.sessionId,'module_name':'Calls',
      'query':_query(search,filter,myStatsOnly),'deleted':0});
    return int.tryParse(json['result_count'].toString()) ?? 0;
  }

  Future<CrmCall?> getCall(String id) async {
    final json=await _request('get_entry',{
      'session':SessionManager.sessionId,'module_name':'Calls','id':id,'select_fields':_fields});
    final entries=json['entry_list'];
    if(entries is! List || entries.isEmpty) return null;
    return _parse(entries.first);
  }

  Future<bool> _set(String? id,Map<String,String> values) async {
    final list=<Map<String,String>>[];
    if(id!=null) list.add({'name':'id','value':id});
    values.forEach((k,v)=>list.add({'name':k,'value':v}));
    final json=await _request('set_entry',{
      'session':SessionManager.sessionId,'module_name':'Calls','name_value_list':list});
    return json.containsKey('id');
  }

  Future<bool> createCall({required String name,String dateStart='',String durationHours='0',
    String durationMinutes='0',String status='Planned',String direction='Outbound',
    String phone='',String assignedTo='',String parentName='',String description=''}) =>
    _set(null,{'name':name,'date_start':dateStart,'duration_hours':durationHours,
      'duration_minutes':durationMinutes,'status':status,'direction':direction,'phone':phone,
      if(assignedTo.isNotEmpty)'assigned_user_name':assignedTo,
      if(parentName.isNotEmpty)'parent_name':parentName,'description':description});

  Future<bool> updateCall({required String id,required String name,String dateStart='',
    String durationHours='0',String durationMinutes='0',String status='Planned',
    String direction='Outbound',String phone='',String assignedTo='',String parentName='',
    String description=''}) =>
    _set(id,{'name':name,'date_start':dateStart,'duration_hours':durationHours,
      'duration_minutes':durationMinutes,'status':status,'direction':direction,'phone':phone,
      if(assignedTo.isNotEmpty)'assigned_user_name':assignedTo,
      if(parentName.isNotEmpty)'parent_name':parentName,'description':description});
}