import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import '../../services/session_manager.dart';

class CrmTaskFormScreen extends StatefulWidget {
  final dynamic item;
  const CrmTaskFormScreen({super.key,this.item});
  @override State<CrmTaskFormScreen> createState()=>_CrmTaskFormScreenState();
}

class _CrmTaskFormScreenState extends State<CrmTaskFormScreen> {
  final _formKey=GlobalKey<FormState>();
  final _service=TaskService();
  late final TextEditingController nameController;
  late final TextEditingController dateStartController;
  late final TextEditingController dateDueController;
  late final TextEditingController parentNameController;
  late final TextEditingController descriptionController;
  String status='Not Started';
  String priority='Medium';
  bool saving=false;

  @override void initState(){
    super.initState();
    nameController=TextEditingController(text: widget.item?.name ?? '');
    dateStartController=TextEditingController(text: widget.item?.dateStart ?? '');
    dateDueController=TextEditingController(text: widget.item?.dateDue ?? '');
    parentNameController=TextEditingController(text: widget.item?.parentName ?? '');
    descriptionController=TextEditingController(text: widget.item?.description ?? '');
    status=widget.item?.status ?? 'Not Started';
    priority=widget.item?.priority ?? 'Medium';
  }

  @override void dispose(){
    for(final c in [
      nameController,
      dateStartController,
      dateDueController,
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
      ok=await _service.createTask(
        name: nameController.text.trim(),
            dateStart: dateStartController.text.trim(),
            dateDue: dateDueController.text.trim(),
            parentName: parentNameController.text.trim(),
            description: descriptionController.text.trim(),
        status:status,
        priority:priority,
        assignedTo:SessionManager.username ?? '',
      );
    }else{
      ok=await _service.updateTask(
        id:widget.item.id,
        name: nameController.text.trim(),
            dateStart: dateStartController.text.trim(),
            dateDue: dateDueController.text.trim(),
            parentName: parentNameController.text.trim(),
            description: descriptionController.text.trim(),
        status:status,
        priority:priority,
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
      appBar:AppBar(title:Text(editing?'Edit Task':'New Task')),
      body:Form(key:_formKey,child:ListView(padding:const EdgeInsets.all(16),children:[
          _field(nameController,'Task Name', required:true),
          _field(dateStartController,'Start Date', required:false),
          _field(dateDueController,'Due Date', required:false),
          _field(parentNameController,'Related To', required:false),
          _field(descriptionController,'Description', required:false),
          DropdownButtonFormField<String>(
            initialValue: status,
            decoration: const InputDecoration(labelText:'Status'),
            items: const [
              DropdownMenuItem(value:'Not Started',child:Text('Not Started')),
              DropdownMenuItem(value:'In Progress',child:Text('In Progress')),
              DropdownMenuItem(value:'Completed',child:Text('Completed')),
              DropdownMenuItem(value:'Pending Input',child:Text('Pending Input')),
              DropdownMenuItem(value:'Deferred',child:Text('Deferred')),
            ],
            onChanged:(v)=>setState(()=>status=v??'Not Started'),
          ),
          const SizedBox(height:12),
          DropdownButtonFormField<String>(
            initialValue: priority,
            decoration: const InputDecoration(labelText:'Priority'),
            items: const [
              DropdownMenuItem(value:'High',child:Text('High')),
              DropdownMenuItem(value:'Medium',child:Text('Medium')),
              DropdownMenuItem(value:'Low',child:Text('Low')),
            ],
            onChanged:(v)=>setState(()=>priority=v??'Medium'),
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
