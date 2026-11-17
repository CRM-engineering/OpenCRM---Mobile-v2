import 'package:flutter/material.dart';
import '../../services/meeting_service.dart';
import 'meeting_form_screen.dart';

class MeetingDetailScreen extends StatefulWidget {
  final dynamic item;
  const MeetingDetailScreen({super.key, required this.item});
  @override State<MeetingDetailScreen> createState()=>_MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  final _service=MeetingService();
  late dynamic item;
  bool loading=false;

  @override void initState(){super.initState();item=widget.item;}

  Future<void> _edit() async {
    final changed=await Navigator.push(
      context,MaterialPageRoute(builder:(_)=>MeetingFormScreen(item:item)));
    if(changed==true && mounted){
      final fresh=await _service.getMeeting(item.id);
      if(fresh!=null && mounted)setState(()=>item=fresh);
    }
  }

  Future<void> _refresh() async {
    setState(()=>loading=true);
    try{
      final fresh=await _service.getMeeting(item.id);
      if(fresh!=null && mounted)setState(()=>item=fresh);
    }finally{if(mounted)setState(()=>loading=false);}
  }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Meeting'),actions:[
      IconButton(tooltip:'Edit Meeting',icon:const Icon(Icons.edit_outlined),onPressed:_edit),
    ]),
    body:RefreshIndicator(
      onRefresh:_refresh,
      child:ListView(padding:const EdgeInsets.all(16),children:[
        Card(child:Padding(padding:const EdgeInsets.all(18),child:Text(
          item.name,style:const TextStyle(fontSize:25,fontWeight:FontWeight.bold)))),
        const SizedBox(height:12),
        Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('Details',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            const Divider(height:24),
                    _row('Date / Time', item.dateStart),
                    _row('Duration Hours', item.durationHours),
                    _row('Duration Minutes', item.durationMinutes),
                    _row('Status', item.status),
                    _row('Location', item.location),
                    _row('Assigned To', item.assignedTo),
                    _row('Related To', item.parentName),
                    _row('Description', item.description),
          ]))),
      ]),
    ),
  );

  Widget _row(String label,String value){
    if(value.isEmpty)return const SizedBox.shrink();
    return Padding(padding:const EdgeInsets.only(bottom:12),child:Row(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        SizedBox(width:125,child:Text(label,style:const TextStyle(color:Colors.grey))),
        Expanded(child:Text(value)),
      ]));
  }
}
