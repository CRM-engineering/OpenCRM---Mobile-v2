import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/meeting.dart';
import '../../services/meeting_service.dart';
import '../../services/session_manager.dart';
import '../../widgets/stats_scope_picker.dart';
import '../../services/permission_manager.dart';
import '../../widgets/meeting_card.dart';
import '../../widgets/pager_widget.dart';
import 'meeting_detail_screen.dart';
import 'meeting_form_screen.dart';

class MeetingListScreen extends StatefulWidget {
  final bool? myStatsOnly;

  const MeetingListScreen({super.key, this.myStatsOnly});
  @override State<MeetingListScreen> createState()=>_MeetingListScreenState();
}

class _MeetingListScreenState extends State<MeetingListScreen> {
  late bool myStatsOnly;
  final _service=MeetingService();
  final _searchController=TextEditingController();
  Timer? _debounce;
  int _requestId=0;
  List<Meeting> items=[];
  bool loading=true;
  int offset=0;
  static const pageSize=25;
  int totalMeetings=0;
  String search='';
  MeetingFilter filter=const MeetingFilter();

  int get currentPage=>(offset~/pageSize)+1;
  int get totalPages => totalMeetings == 0 ? 1 : ((totalMeetings + pageSize - 1) ~/ pageSize);

  @override void initState(){super.initState();myStatsOnly=widget.myStatsOnly ?? !SessionManager.isAdmin;loadItems();}
  @override void dispose(){_debounce?.cancel();_searchController.dispose();super.dispose();}

  Future<void> loadItems() async {
    final request=++_requestId;
    setState((){loading=true;totalMeetings=0;});
    try {
      final results=await _service.getMeetings(search:search,offset:offset,maxResults:pageSize,filter:filter,myStatsOnly:myStatsOnly);
      if(!mounted||request!=_requestId)return;
      setState((){items=results;totalMeetings=offset+results.length;loading=false;});
      try {
        final count=await _service.getMeetingCount(search:search,filter:filter,myStatsOnly:myStatsOnly).timeout(const Duration(seconds:5));
        if(!mounted||request!=_requestId)return;
        setState((){totalMeetings=count;});
      }catch(_){
      }
    }catch(_){
      if(!mounted||request!=_requestId)return;
      setState((){items=[];totalMeetings=0;loading=false;});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Could not load meetings.')));
    }
  }

  Future<void> _newItem() async {
    final created=await Navigator.push(context,MaterialPageRoute(builder:(_)=>const MeetingFormScreen()));
    if(created==true&&mounted)loadItems();
  }

  Future<void> _showFilter() async {
    
    var status=filter.status;
    var sortBy=filter.sortBy;
    var ascending=filter.sortAscending;
    final result=await showModalBottomSheet<MeetingFilter>(
      context:context,isScrollControlled:true,builder:(context)=>StatefulBuilder(
        builder:(context,setModalState)=>SafeArea(top:false,child:Padding(
          padding:const EdgeInsets.fromLTRB(20,20,20,12),
          child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
            const Align(alignment:Alignment.centerLeft,child:Text('Filter Meetings',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold))),
            const SizedBox(height:14),
            DropdownButtonFormField<String>(initialValue:status.isEmpty?null:status,decoration:const InputDecoration(labelText:'Status'),
              items:const ['','Planned','Held','Not Held'].map((v)=>DropdownMenuItem(value:v,child:Text(v.isEmpty?'All Statuses':v))).toList(),
              onChanged:(v)=>setModalState(()=>status=v??'')),
            const SizedBox(height:12),
            DropdownButtonFormField<String>(initialValue:sortBy,decoration:const InputDecoration(labelText:'Sort By'),
              items:const [
                DropdownMenuItem(value:'date_start',child:Text('Date / Time')),
                DropdownMenuItem(value:'name',child:Text('Name')),
                DropdownMenuItem(value:'status',child:Text('Status')),
                DropdownMenuItem(value:'location',child:Text('Location')),
              ],onChanged:(v)=>setModalState(()=>sortBy=v??'date_start')),
            const SizedBox(height:12),
            DropdownButtonFormField<bool>(initialValue:ascending,decoration:const InputDecoration(labelText:'Order'),
              items:const [DropdownMenuItem(value:true,child:Text('Ascending')),DropdownMenuItem(value:false,child:Text('Descending'))],
              onChanged:(v)=>setModalState(()=>ascending=v??true)),
            const SizedBox(height:20),
            Row(children:[
              Expanded(child:OutlinedButton(onPressed:()=>Navigator.pop(context,const MeetingFilter()),child:const Text('CLEAR FILTERS'))),
              const SizedBox(width:12),
              Expanded(child:ElevatedButton(onPressed:()=>Navigator.pop(context,MeetingFilter(status:status,sortBy:sortBy,sortAscending:ascending)),child:const Text('APPLY'))),
            ])
          ])))),
      ));
    if(result!=null&&mounted){setState((){filter=result;offset=0;});loadItems();}

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
    if (!PermissionManager.canList('Meetings')) {
      return const Scaffold(
        body: Center(child: Text('You do not have permission to access Meetings.')),
      );
    }

    return Scaffold(
    appBar:AppBar(title:const Text('Meetings'),actions:[
      if (!SessionManager.isAdmin)
        IconButton(tooltip: myStatsOnly ? 'Showing My Statistics' : 'Showing All Accessible', icon: Icon(myStatsOnly ? Icons.person : Icons.groups), onPressed: _chooseRecordScope),
      IconButton(tooltip:'Filter Meetings',icon:const Icon(Icons.filter_list),onPressed:_showFilter),
      if (PermissionManager.canCreate('Meetings'))
        IconButton(tooltip:'New Meetings',icon:const Icon(Icons.add),onPressed:_newItem),
    ]),
    body:Column(children:[
      Padding(padding:const EdgeInsets.all(12),child:TextField(
        controller:_searchController,
        decoration:InputDecoration(hintText:'Search Meetings...',prefixIcon:const Icon(Icons.search),
          border:OutlineInputBorder(borderRadius:BorderRadius.circular(12))),
        onChanged:(value){
          _debounce?.cancel();
          setState((){search=value.trim();offset=0;});
          if(search.isEmpty){loadItems();return;}
          _debounce=Timer(const Duration(milliseconds:500),(){if(mounted)loadItems();});
        },
      )),
      Expanded(child:loading?const Center(child:CircularProgressIndicator()):
        RefreshIndicator(onRefresh:loadItems,child:ListView.builder(
          physics:const AlwaysScrollableScrollPhysics(),itemCount:items.length,
          itemBuilder:(context,index)=>MeetingCard(
            item:items[index],
            onTap:()async{
              final changed=await Navigator.push(context,MaterialPageRoute(
                builder:(_)=>MeetingDetailScreen(item:items[index])));
              if(changed==true&&mounted)loadItems();
            },
          ),
        ))),
      SafeArea(top:false,left:false,right:false,child:Container(width:double.infinity,
        padding:const EdgeInsets.fromLTRB(8,4,8,8),child:PagerWidget(
          page:currentPage,totalPages:totalPages,canGoPrevious:offset>0,
          canGoNext:offset+pageSize<totalMeetings,
          onPrevious:(){setState((){offset-=pageSize;if(offset<0)offset=0;});loadItems();},
          onNext:(){setState((){offset+=pageSize;});loadItems();},
        ))),
    ]),
  );
}
}
