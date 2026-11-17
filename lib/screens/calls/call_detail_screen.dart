import 'package:flutter/material.dart';
import '../../services/call_service.dart';
import 'call_form_screen.dart';

class CrmCallDetailScreen extends StatefulWidget {
  final dynamic item;
  const CrmCallDetailScreen({super.key, required this.item});
  @override State<CrmCallDetailScreen> createState()=>_CrmCallDetailScreenState();
}

class _CrmCallDetailScreenState extends State<CrmCallDetailScreen> {
  final _service=CallService();
  late dynamic item;
  bool loading=false;

  @override void initState(){super.initState();item=widget.item;}

  Future<void> _edit() async {
    final changed=await Navigator.push(
      context,MaterialPageRoute(builder:(_)=>CrmCallFormScreen(item:item)));
    if(changed==true && mounted){
      final fresh=await _service.getCall(item.id);
      if(fresh!=null && mounted)setState(()=>item=fresh);
    }
  }

  Future<void> _refresh() async {
    setState(()=>loading=true);
    try{
      final fresh=await _service.getCall(item.id);
      if(fresh!=null && mounted)setState(()=>item=fresh);
    }finally{if(mounted)setState(()=>loading=false);}
  }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Call'),actions:[
      IconButton(tooltip:'Edit Call',icon:const Icon(Icons.edit_outlined),onPressed:_edit),
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
                    _row('Direction', item.direction),
                    _row('Phone', item.phone),
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
