import 'package:flutter/material.dart';

import '../../models/contact.dart';
import '../../services/contact_service.dart';
import '../../services/session_manager.dart';

class ContactFormScreen extends StatefulWidget {
  final Contact? contact;

  const ContactFormScreen({
    super.key,
    this.contact,
  });

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ContactService();

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController accountController;
  late final TextEditingController titleController;
  late final TextEditingController departmentController;
  late final TextEditingController phoneWorkController;
  late final TextEditingController phoneMobileController;
  late final TextEditingController emailController;
  late final TextEditingController websiteController;
  late final TextEditingController streetController;
  late final TextEditingController cityController;
  late final TextEditingController stateController;
  late final TextEditingController postalController;
  late final TextEditingController countryController;
  late final TextEditingController descriptionController;
  late final TextEditingController assignedToController;

  String leadSource = '';
  bool saving = false;

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
    final c = widget.contact;

    firstNameController =
        TextEditingController(text: c?.firstName ?? '');
    lastNameController =
        TextEditingController(text: c?.lastName ?? '');
    accountController =
        TextEditingController(text: c?.accountName ?? '');
    titleController =
        TextEditingController(text: c?.title ?? '');
    departmentController =
        TextEditingController(text: c?.department ?? '');
    phoneWorkController =
        TextEditingController(text: c?.phoneWork ?? '');
    phoneMobileController =
        TextEditingController(text: c?.phoneMobile ?? '');
    emailController =
        TextEditingController(text: c?.email ?? '');
    websiteController =
        TextEditingController(text: c?.website ?? '');
    streetController =
        TextEditingController(text: c?.street ?? '');
    cityController =
        TextEditingController(text: c?.city ?? '');
    stateController =
        TextEditingController(text: c?.state ?? '');
    postalController =
        TextEditingController(text: c?.postalCode ?? '');
    countryController =
        TextEditingController(text: c?.country ?? '');
    descriptionController =
        TextEditingController(text: c?.description ?? '');
    assignedToController = TextEditingController(
      text: c?.assignedTo ?? SessionManager.username ?? '',
    );

    leadSource = c?.leadSource ?? '';
  }

  @override
  void dispose() {
    for (final controller in [
      firstNameController,
      lastNameController,
      accountController,
      titleController,
      departmentController,
      phoneWorkController,
      phoneMobileController,
      emailController,
      websiteController,
      streetController,
      cityController,
      stateController,
      postalController,
      countryController,
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

    final ok = widget.contact == null
        ? await _service.createContact(
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            accountName: accountController.text.trim(),
            title: titleController.text.trim(),
            department: departmentController.text.trim(),
            phoneWork: phoneWorkController.text.trim(),
            phoneMobile: phoneMobileController.text.trim(),
            email: emailController.text.trim(),
            website: websiteController.text.trim(),
            street: streetController.text.trim(),
            city: cityController.text.trim(),
            state: stateController.text.trim(),
            postalCode: postalController.text.trim(),
            country: countryController.text.trim(),
            leadSource: leadSource,
            description: descriptionController.text.trim(),
            assignedTo: assignedToController.text.trim(),
          )
        : await _service.updateContact(
            id: widget.contact!.id,
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            accountName: accountController.text.trim(),
            title: titleController.text.trim(),
            department: departmentController.text.trim(),
            phoneWork: phoneWorkController.text.trim(),
            phoneMobile: phoneMobileController.text.trim(),
            email: emailController.text.trim(),
            website: websiteController.text.trim(),
            street: streetController.text.trim(),
            city: cityController.text.trim(),
            state: stateController.text.trim(),
            postalCode: postalController.text.trim(),
            country: countryController.text.trim(),
            leadSource: leadSource,
            description: descriptionController.text.trim(),
            assignedTo: assignedToController.text.trim(),
          );

    if (!mounted) return;

    setState(() => saving = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save contact.')),
      );
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        scrollPadding: const EdgeInsets.only(bottom: 360),
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                ? 'Required'
                : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contact == null ? 'New Contact' : 'Edit Contact',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionTitle('Overview'),
            Row(
              children: [
                Expanded(
                  child: _field(
                    firstNameController,
                    'First Name',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    lastNameController,
                    'Last Name',
                    required: true,
                  ),
                ),
              ],
            ),
            _field(accountController, 'Account Name'),
            _field(titleController, 'Title'),
            _field(departmentController, 'Department'),

            DropdownButtonFormField<String>(
              initialValue:
                  leadSource.isEmpty ? null : leadSource,
              decoration: const InputDecoration(
                labelText: 'Lead Source',
              ),
              items: leadSources
                  .map((source) => DropdownMenuItem(
                        value: source,
                        child: Text(source),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => leadSource = value ?? '');
              },
            ),

            const SizedBox(height: 12),

            const _SectionTitle('Contact Information'),
            _field(
              phoneWorkController,
              'Office Phone',
              keyboardType: TextInputType.phone,
            ),
            _field(
              phoneMobileController,
              'Mobile',
              keyboardType: TextInputType.phone,
            ),
            _field(
              emailController,
              'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            _field(websiteController, 'Website'),

            const _SectionTitle('Address'),
            _field(streetController, 'Street'),
            _field(cityController, 'City'),
            _field(stateController, 'State / Region'),
            _field(postalController, 'Postal Code'),
            _field(countryController, 'Country'),

            const _SectionTitle('Other'),
            _field(
              descriptionController,
              'Description',
              maxLines: 5,
            ),
            _field(assignedToController, 'Assigned To'),

            const SizedBox(height: 12),

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
                        widget.contact == null ? 'SAVE' : 'UPDATE',
                      ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed:
                  saving ? null : () => Navigator.pop(context),
              child: const Text('CANCEL'),
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
      padding: const EdgeInsets.only(top: 8, bottom: 14),
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
