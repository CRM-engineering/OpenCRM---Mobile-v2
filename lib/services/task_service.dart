
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/task.dart';
import 'session_manager.dart';

class TaskService {
  String get _url => AppConfig.crmUrl + AppConfig.restEndpoint;

  Future<Map<String,dynamic>> _request(String method,Map<String,dynamic> data) async {
    final response=await http.post(Uri.parse(_url),
      headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:{'method':method,'input_type':'JSON','response_type':'JSON','rest_data':jsonEncode(data)});
    final json=jsonDecode(response.body);
    if(json is! Map<String,dynamic>) throw Exception('Invalid SuiteCRM response.');
    if(json['number']!=null && json['name']!=null) throw Exception('SuiteCRM error: ${json['name']} - ${json['description'] ?? ''}');
    return json;
  }

  String _query(String search,TaskFilter filter, bool myStatsOnly) {
    final conditions=<String>[];
    if(myStatsOnly && SessionManager.userId != null) {
      conditions.add("tasks.assigned_user_id = '${SessionManager.userId}'");
    }
    final safe=search.replaceAll("'", "''");
    if(safe.isNotEmpty) conditions.add("(tasks.name LIKE '%$safe%' OR tasks.description LIKE '%$safe%')");
    if(filter.status.isNotEmpty) {
      final v=filter.status.replaceAll("'", "''");
      conditions.add("tasks.status = '$v'");
    }
    if(filter.priority.isNotEmpty) {
      final v=filter.priority.replaceAll("'", "''");
      conditions.add("tasks.priority = '$v'");
    }
    return conditions.isEmpty ? '' : conditions.join(' AND ');
  }

  String _orderBy(TaskFilter filter) {
    const fields={'date_due':'date_due','date_start':'date_start','name':'name','status':'status','priority':'priority'};
    return '${fields[filter.sortBy] ?? 'date_due'} ${filter.sortAscending ? 'ASC' : 'DESC'}';
  }

  List<String> get _fields => const [
    'id','name','date_start','date_due','status','priority',
    'assigned_user_name','parent_name','description'
  ];

  CrmTask _parse(Map entry) {
    final f=entry['name_value_list'] as Map;
    String v(String k)=>f[k]?['value']?.toString() ?? '';
    return CrmTask(id:v('id'),name:v('name'),dateStart:v('date_start'),
      dateDue:v('date_due'),status:v('status'),priority:v('priority'),
      assignedTo:v('assigned_user_name'),parentName:v('parent_name'),
      description:v('description'));
  }

  Future<List<CrmTask>> getTasks({String search='',int offset=0,int maxResults=25,TaskFilter filter=const TaskFilter(), bool myStatsOnly=false}) async {
    final json=await _request('get_entry_list',{
      'session':SessionManager.sessionId,'module_name':'Tasks','query':_query(search,filter,myStatsOnly),
      'order_by':_orderBy(filter),'offset':offset,'select_fields':_fields,
      'max_results':maxResults,'deleted':0});
    final entries=json['entry_list'];
    if(entries is! List) return [];
    return entries.map<CrmTask>((e)=>_parse(e)).toList();
  }

  Future<int> getTaskCount({String search='',TaskFilter filter=const TaskFilter(), bool myStatsOnly=false}) async {
    final json=await _request('get_entries_count',{
      'session':SessionManager.sessionId,'module_name':'Tasks',
      'query':_query(search,filter,myStatsOnly),'deleted':0});
    return int.tryParse(json['result_count'].toString()) ?? 0;
  }

  Future<CrmTask?> getTask(String id) async {
    final json=await _request('get_entry',{
      'session':SessionManager.sessionId,'module_name':'Tasks','id':id,'select_fields':_fields});
    final entries=json['entry_list'];
    if(entries is! List || entries.isEmpty) return null;
    return _parse(entries.first);
  }

  Future<bool> _set(String? id,Map<String,String> values) async {
    final list=<Map<String,String>>[];
    if(id!=null) list.add({'name':'id','value':id});
    values.forEach((k,v)=>list.add({'name':k,'value':v}));
    final json=await _request('set_entry',{
      'session':SessionManager.sessionId,'module_name':'Tasks','name_value_list':list});
    return json.containsKey('id');
  }

  Future<bool> createTask({required String name,String dateStart='',String dateDue='',
    String status='Not Started',String priority='Medium',String assignedTo='',
    String parentName='',String description=''}) =>
    _set(null,{'name':name,'date_start':dateStart,'date_due':dateDue,'status':status,
      'priority':priority,if(assignedTo.isNotEmpty)'assigned_user_name':assignedTo,
      if(parentName.isNotEmpty)'parent_name':parentName,'description':description});

  Future<bool> updateTask({required String id,required String name,String dateStart='',
    String dateDue='',String status='Not Started',String priority='Medium',
    String assignedTo='',String parentName='',String description=''}) =>
    _set(id,{'name':name,'date_start':dateStart,'date_due':dateDue,'status':status,
      'priority':priority,if(assignedTo.isNotEmpty)'assigned_user_name':assignedTo,
      if(parentName.isNotEmpty)'parent_name':parentName,'description':description});
}
