import 'package:flutter/material.dart';

import '../../models/opportunity.dart';
import '../../services/opportunity_service.dart';
import '../../services/session_manager.dart';

class OpportunityFormScreen extends StatefulWidget {
  final Opportunity? opportunity;

  const OpportunityFormScreen({
    super.key,
    this.opportunity,
  });

  bool get isEditing => opportunity != null;

  @override
  State<OpportunityFormScreen> createState() =>
      _OpportunityFormScreenState();
}

class _OpportunityFormScreenState
    extends State<OpportunityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = OpportunityService();

  late final TextEditingController nameController;
  late final TextEditingController accountController;
  late final TextEditingController amountController;
  late final TextEditingController probabilityController;
  late final TextEditingController dateController;
  late final TextEditingController nextStepController;
  late final TextEditingController descriptionController;
  late final TextEditingController assignedToController;

  String salesStage = 'Prospecting';
  String type = '';
  String leadSource = '';

  bool saving = false;

  static const stages = [
    'Prospecting',
    'Qualification',
    'Needs Analysis',
    'Value Proposition',
    'Identifying Decision Makers',
    'Perception Analysis',
    'Proposal/Price Quote',
    'Negotiation/Review',
    'Closed Won',
    'Closed Lost',
  ];

  static const leadSources = [
    'Cold Call',
    'Existing Customer',
    'Self Generated',
    'Employee',
    'Partner',
    'Public Relations',
    'Direct Mail',
    'Conference',
    'Trade Show',
    'Web Site',
    'Word of mouth',
    'Email',
    'Campaign',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    final o = widget.opportunity;

    nameController = TextEditingController(text: o?.name ?? '');
    accountController =
        TextEditingController(text: o?.accountName ?? '');
    amountController = TextEditingController(
      text: o == null ? '' : o.amount.toStringAsFixed(2),
    );
    probabilityController = TextEditingController(
      text: o == null ? '10' : o.probability.toString(),
    );
    dateController =
        TextEditingController(text: o?.expectedCloseDate ?? '');
    nextStepController =
        TextEditingController(text: o?.nextStep ?? '');
    descriptionController =
        TextEditingController(text: o?.description ?? '');
    assignedToController = TextEditingController(
      text: SessionManager.username ?? '',
    );

    if (o != null) {
      salesStage = o.salesStage.isEmpty ? 'Prospecting' : o.salesStage;
      type = o.type;
      leadSource = o.leadSource;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    accountController.dispose();
    amountController.dispose();
    probabilityController.dispose();
    dateController.dispose();
    nextStepController.dispose();
    descriptionController.dispose();
    assignedToController.dispose();
    super.dispose();
  }

  void _updateProbability(String stage) {
    const probabilities = {
      'Prospecting': 10,
      'Qualification': 20,
      'Needs Analysis': 30,
      'Value Proposition': 40,
      'Identifying Decision Makers': 50,
      'Perception Analysis': 60,
      'Proposal/Price Quote': 70,
      'Negotiation/Review': 80,
      'Closed Won': 100,
      'Closed Lost': 0,
    };

    final current = int.tryParse(probabilityController.text);
    if (current == null || current == 0 || current == 10) {
      probabilityController.text =
          (probabilities[stage] ?? 10).toString();
    }
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime.now();

    if (dateController.text.isNotEmpty) {
      final parsed = DateTime.tryParse(dateController.text);
      if (parsed != null) {
        initial = parsed;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateController.text =
          '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    final success = widget.isEditing
        ? await _service.updateOpportunity(
            id: widget.opportunity!.id,
            name: nameController.text.trim(),
            accountName: accountController.text.trim(),
            amount: amountController.text.trim(),
            salesStage: salesStage,
            probability: probabilityController.text.trim(),
            dateClosed: dateController.text.trim(),
            type: type,
            leadSource: leadSource,
            nextStep: nextStepController.text.trim(),
            description: descriptionController.text.trim(),
            assignedTo: assignedToController.text.trim(),
          )
        : await _service.createOpportunity(
            name: nameController.text.trim(),
            accountName: accountController.text.trim(),
            amount: amountController.text.trim(),
            salesStage: salesStage,
            probability: probabilityController.text.trim(),
            dateClosed: dateController.text.trim(),
            type: type,
            leadSource: leadSource,
            nextStep: nextStepController.text.trim(),
            description: descriptionController.text.trim(),
            assignedTo: assignedToController.text.trim(),
          );

    if (!mounted) return;

    setState(() {
      saving = false;
    });

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not save the opportunity.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Edit Opportunity'
              : 'New Opportunity',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionTitle('Overview'),

            TextFormField(
              controller: nameController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: 'Opportunity Name',
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: accountController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: 'Account Name',
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: amountController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: 'Opportunity Amount',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                final amount = double.tryParse(value.trim());
                if (amount == null || amount < 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: salesStage,
              decoration: const InputDecoration(
                labelText: 'Sales Stage *',
              ),
              items: stages.map((stage) {
                return DropdownMenuItem(
                  value: stage,
                  child: Text(stage),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  salesStage = value;
                });
                _updateProbability(value);
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: probabilityController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: 'Probability (%)',
              ),
              keyboardType: TextInputType.number,

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                final probability = int.tryParse(value.trim());
                if (probability == null || probability < 0 || probability > 100) {
                  return 'Enter a value from 0 to 100';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: dateController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: 'Expected Close Date *',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: type.isEmpty ? null : type,
              decoration: const InputDecoration(
                labelText: 'Type',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Existing Business',
                  child: Text('Existing Business'),
                ),
                DropdownMenuItem(
                  value: 'New Business',
                  child: Text('New Business'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  type = value ?? '';
                });
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: leadSource.isEmpty ? null : leadSource,
              decoration: const InputDecoration(
                labelText: 'Lead Source',
              ),
              items: leadSources.map((source) {
                return DropdownMenuItem(
                  value: source,
                  child: Text(source),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  leadSource = value ?? '';
                });
              },
            ),

            TextFormField(
              controller: nextStepController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: 'Next Step',
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: descriptionController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 10),

            const _SectionTitle('Other'),

            TextFormField(
              controller: assignedToController,
              scrollPadding: const EdgeInsets.only(bottom: 360),
              decoration: const InputDecoration(
                labelText: 'Assigned To',
              ),
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 20),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.isEditing
                            ? 'UPDATE'
                            : 'SAVE',
                      ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: saving
                    ? null
                    : () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 14,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
