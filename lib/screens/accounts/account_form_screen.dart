import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../services/account_service.dart';
import '../../services/session_manager.dart';

class AccountFormScreen extends StatefulWidget {
  final Account? account;

  const AccountFormScreen({
    super.key,
    this.account,
  });

  bool get isEditing => account != null;

  @override
  State<AccountFormScreen> createState() =>
      _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AccountService();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController faxController;
  late final TextEditingController websiteController;
  late final TextEditingController emailController;
  late final TextEditingController billingStreetController;
  late final TextEditingController billingCityController;
  late final TextEditingController billingStateController;
  late final TextEditingController billingPostalController;
  late final TextEditingController billingCountryController;
  late final TextEditingController shippingStreetController;
  late final TextEditingController shippingCityController;
  late final TextEditingController shippingStateController;
  late final TextEditingController shippingPostalController;
  late final TextEditingController shippingCountryController;
  late final TextEditingController revenueController;
  late final TextEditingController employeesController;
  late final TextEditingController descriptionController;
  late final TextEditingController assignedToController;

  String type = '';
  String industry = '';
  bool saving = false;

  static const types = [
    'Analyst',
    'Competitor',
    'Customer',
    'Integrator',
    'Investor',
    'Partner',
    'Press',
    'Prospect',
    'Reseller',
    'Other',
  ];

  static const industries = [
    'Apparel',
    'Banking',
    'Biotechnology',
    'Chemicals',
    'Communications',
    'Construction',
    'Consulting',
    'Education',
    'Electronics',
    'Energy',
    'Engineering',
    'Entertainment',
    'Environmental',
    'Finance',
    'Government',
    'Healthcare',
    'Hospitality',
    'Insurance',
    'Machinery',
    'Manufacturing',
    'Media',
    'Not For Profit',
    'Recreation',
    'Retail',
    'Shipping',
    'Technology',
    'Telecommunications',
    'Transportation',
    'Utilities',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    final a = widget.account;

    nameController = TextEditingController(text: a?.name ?? '');
    phoneController = TextEditingController(text: a?.officePhone ?? '');
    faxController = TextEditingController(text: a?.fax ?? '');
    websiteController = TextEditingController(text: a?.website ?? '');
    emailController = TextEditingController(text: a?.email ?? '');
    billingStreetController =
        TextEditingController(text: a?.billingStreet ?? '');
    billingCityController =
        TextEditingController(text: a?.billingCity ?? '');
    billingStateController =
        TextEditingController(text: a?.billingState ?? '');
    billingPostalController =
        TextEditingController(text: a?.billingPostalCode ?? '');
    billingCountryController =
        TextEditingController(text: a?.billingCountry ?? '');
    shippingStreetController =
        TextEditingController(text: a?.shippingStreet ?? '');
    shippingCityController =
        TextEditingController(text: a?.shippingCity ?? '');
    shippingStateController =
        TextEditingController(text: a?.shippingState ?? '');
    shippingPostalController =
        TextEditingController(text: a?.shippingPostalCode ?? '');
    shippingCountryController =
        TextEditingController(text: a?.shippingCountry ?? '');
    revenueController =
        TextEditingController(text: a?.annualRevenue ?? '');
    employeesController =
        TextEditingController(text: a?.employees ?? '');
    descriptionController =
        TextEditingController(text: a?.description ?? '');
    assignedToController = TextEditingController(
      text: a?.assignedTo ?? SessionManager.username ?? '',
    );

    type = a?.type ?? '';
    industry = a?.industry ?? '';
  }

  @override
  void dispose() {
    for (final controller in [
      nameController,
      phoneController,
      faxController,
      websiteController,
      emailController,
      billingStreetController,
      billingCityController,
      billingStateController,
      billingPostalController,
      billingCountryController,
      shippingStreetController,
      shippingCityController,
      shippingStateController,
      shippingPostalController,
      shippingCountryController,
      revenueController,
      employeesController,
      descriptionController,
      assignedToController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      final success = widget.isEditing
          ? await _service.updateAccount(
              id: widget.account!.id,
              name: nameController.text.trim(),
              officePhone: phoneController.text.trim(),
              fax: faxController.text.trim(),
              website: websiteController.text.trim(),
              email: emailController.text.trim(),
              billingStreet: billingStreetController.text.trim(),
              billingCity: billingCityController.text.trim(),
              billingState: billingStateController.text.trim(),
              billingPostalCode: billingPostalController.text.trim(),
              billingCountry: billingCountryController.text.trim(),
              shippingStreet: shippingStreetController.text.trim(),
              shippingCity: shippingCityController.text.trim(),
              shippingState: shippingStateController.text.trim(),
              shippingPostalCode: shippingPostalController.text.trim(),
              shippingCountry: shippingCountryController.text.trim(),
              type: type,
              industry: industry,
              annualRevenue: revenueController.text.trim(),
              employees: employeesController.text.trim(),
              description: descriptionController.text.trim(),
              assignedTo: assignedToController.text.trim(),
            )
          : await _service.createAccount(
              name: nameController.text.trim(),
              officePhone: phoneController.text.trim(),
              fax: faxController.text.trim(),
              website: websiteController.text.trim(),
              email: emailController.text.trim(),
              billingStreet: billingStreetController.text.trim(),
              billingCity: billingCityController.text.trim(),
              billingState: billingStateController.text.trim(),
              billingPostalCode: billingPostalController.text.trim(),
              billingCountry: billingCountryController.text.trim(),
              shippingStreet: shippingStreetController.text.trim(),
              shippingCity: shippingCityController.text.trim(),
              shippingState: shippingStateController.text.trim(),
              shippingPostalCode: shippingPostalController.text.trim(),
              shippingCountry: shippingCountryController.text.trim(),
              type: type,
              industry: industry,
              annualRevenue: revenueController.text.trim(),
              employees: employeesController.text.trim(),
              description: descriptionController.text.trim(),
              assignedTo: assignedToController.text.trim(),
            );

      if (!mounted) return;

      if (!success) {
        throw Exception('SuiteCRM did not accept the account.');
      }

      if (widget.isEditing) {
        final fresh = await _service.getAccount(widget.account!.id);
        if (!mounted) return;
        Navigator.pop(context, fresh ?? widget.account);
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save account: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Account' : 'New Account'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(nameController, 'Name', required: true),
            _field(phoneController, 'Office Phone'),
            _field(faxController, 'Fax'),
            _field(websiteController, 'Website'),
            _field(emailController, 'Email'),
            _dropdown(
              label: 'Type',
              value: type,
              items: types,
              onChanged: (v) => setState(() => type = v ?? ''),
            ),
            _dropdown(
              label: 'Industry',
              value: industry,
              items: industries,
              onChanged: (v) => setState(() => industry = v ?? ''),
            ),
            _field(revenueController, 'Annual Revenue'),
            _field(
              employeesController,
              'Employees',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            const Text(
              'Billing Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _field(billingStreetController, 'Street', maxLines: 3),
            _field(billingCityController, 'City'),
            _field(billingStateController, 'State / Region'),
            _field(billingPostalController, 'Postal Code'),
            _field(billingCountryController, 'Country'),
            const SizedBox(height: 8),
            const Text(
              'Shipping Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _field(shippingStreetController, 'Street', maxLines: 3),
            _field(shippingCityController, 'City'),
            _field(shippingStateController, 'State / Region'),
            _field(shippingPostalController, 'Postal Code'),
            _field(shippingCountryController, 'Country'),
            const SizedBox(height: 8),
            _field(
              descriptionController,
              'Description',
              maxLines: 5,
            ),
            _field(assignedToController, 'Assigned To'),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  saving
                      ? 'Saving...'
                      : widget.isEditing
                          ? 'SAVE CHANGES'
                          : 'CREATE ACCOUNT',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        scrollPadding: const EdgeInsets.only(bottom: 360),
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value.isEmpty ? null : value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(
            value: '',
            child: Text('Not Set'),
          ),
          ...items.map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
