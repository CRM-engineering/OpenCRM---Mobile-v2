import 'package:flutter/material.dart';
import '../../services/call_service.dart';
import '../../services/session_manager.dart';

class CrmCallFormScreen extends StatefulWidget {
  final dynamic item;
  const CrmCallFormScreen({super.key,this.item});
  @override State<CrmCallFormScreen> createState()=>_CrmCallFormScreenState();
}

class _CrmCallFormScreenState extends State<CrmCallFormScreen> {
  final _formKey=GlobalKey<FormState>();
  final _service=CallService();
  late final TextEditingController nameController;
  late final TextEditingController dateStartController;
  late final TextEditingController durationHoursController;
  late final TextEditingController durationMinutesController;
  late final TextEditingController phoneController;
  late final TextEditingController parentNameController;
  late final TextEditingController descriptionController;
  String status='Planned';
  String direction='Outbound';
  bool saving=false;

  @override void initState(){
    super.initState();
    nameController=TextEditingController(text: widget.item?.name ?? '');
    dateStartController=TextEditingController(text: widget.item?.dateStart ?? '');
    durationHoursController=TextEditingController(text: widget.item?.durationHours ?? '');
    durationMinutesController=TextEditingController(text: widget.item?.durationMinutes ?? '');
    phoneController=TextEditingController(text: widget.item?.phone ?? '');
    parentNameController=TextEditingController(text: widget.item?.parentName ?? '');
    descriptionController=TextEditingController(text: widget.item?.description ?? '');
    status=widget.item?.status ?? 'Planned';
    direction=widget.item?.direction ?? 'Outbound';
  }

  @override void dispose(){
    for(final c in [
      nameController,
      dateStartController,
      durationHoursController,
      durationMinutesController,
      phoneController,
      parentNameController,
      descriptionController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(()=>saving=true);
    bool ok;
    if(widget.item==null){
      ok=await _service.createCall(
        name: nameController.text.trim(),
            dateStart: dateStartController.text.trim(),
            durationHours: durationHoursController.text.trim(),
            durationMinutes: durationMinutesController.text.trim(),
            phone: phoneController.text.trim(),
            parentName: parentNameController.text.trim(),
            description: descriptionController.text.trim(),
        status:status,
        direction:direction,
        assignedTo:SessionManager.username ?? '',
      );
    }else{
      ok=await _service.updateCall(
        id:widget.item.id,
        name: nameController.text.trim(),
            dateStart: dateStartController.text.trim(),
            durationHours: durationHoursController.text.trim(),
            durationMinutes: durationMinutesController.text.trim(),
            phone: phoneController.text.trim(),
            parentName: parentNameController.text.trim(),
            description: descriptionController.text.trim(),
        status:status,
        direction:direction,
        assignedTo:SessionManager.username ?? '',
      );
    }
    if(!mounted)return;
    setState(()=>saving=false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save record.')),
      );
    }
  }

  Widget _field(TextEditingController c,String label,{bool required=false,int maxLines=1})=>Padding(
    padding:const EdgeInsets.only(bottom:12),
    child:TextFormField(controller:c,maxLines:maxLines,decoration:InputDecoration(labelText:label),
    scrollPadding: const EdgeInsets.only(bottom: 360),
      validator:required?(v)=>v==null||v.trim().isEmpty?'Required':null:null));

  @override Widget build(BuildContext context){
    final editing=widget.item!=null;
    return Scaffold(
      appBar:AppBar(title:Text(editing?'Edit Call':'New Call')),
      body:Form(key:_formKey,child:ListView(padding:const EdgeInsets.all(16),children:[
          _field(nameController,'Call Name', required:true),
          _field(dateStartController,'Date / Time', required:false),
          _field(durationHoursController,'Duration Hours', required:false),
          _field(durationMinutesController,'Duration Minutes', required:false),
          _field(phoneController,'Phone', required:false),
          _field(parentNameController,'Related To', required:false),
          _field(descriptionController,'Description', required:false),
          DropdownButtonFormField<String>(
            initialValue: status,
            decoration: const InputDecoration(labelText:'Status'),
            items: const [
              DropdownMenuItem(value:'Planned',child:Text('Planned')),
              DropdownMenuItem(value:'Held',child:Text('Held')),
              DropdownMenuItem(value:'Not Held',child:Text('Not Held')),
            ],
            onChanged:(v)=>setState(()=>status=v??'Planned'),
          ),
          const SizedBox(height:12),
          DropdownButtonFormField<String>(
            initialValue: direction,
            decoration: const InputDecoration(labelText:'Direction'),
            items: const [
              DropdownMenuItem(value:'Inbound',child:Text('Inbound')),
              DropdownMenuItem(value:'Outbound',child:Text('Outbound')),
            ],
            onChanged:(v)=>setState(()=>direction=v??'Outbound'),
          ),
        const SizedBox(height:12),
        SizedBox(height:52,child:ElevatedButton(onPressed:saving?null:_save,
          child:saving?const SizedBox(width:22,height:22,child:CircularProgressIndicator(strokeWidth:2)):
          Text(editing?'UPDATE':'SAVE'))),
        const SizedBox(height:10),
        OutlinedButton(onPressed:saving?null:()=>Navigator.pop(context),child:const Text('CANCEL')),
      ])),
    );
  }
}
