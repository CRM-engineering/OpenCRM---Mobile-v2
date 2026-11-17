import 'package:flutter/material.dart';

import '../../models/contact.dart';
import '../../services/contact_service.dart';
import 'contact_form_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;

  const ContactDetailScreen({
    super.key,
    required this.contact,
  });

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  final _service = ContactService();
  late Contact contact;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(
        builder: (_) => ContactFormScreen(contact: contact),
      ),
    );

    if (updated != null && mounted) {
      setState(() => contact = updated);
    }
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    try {
      final fresh = await _service.getContact(contact.id);
      if (fresh != null && mounted) setState(() => contact = fresh);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
        actions: [
          IconButton(
            tooltip: 'Edit Contact',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _edit,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.fullName,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (contact.title.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(contact.title),
                    ],
                    if (contact.accountName.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        contact.accountName,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _section('Contact Information', [
              _row('Office Phone', contact.phoneWork),
              _row('Mobile', contact.phoneMobile),
              _row('Email', contact.email),
              _row('Website', contact.website),
              _row('Department', contact.department),
              _row('Lead Source', contact.leadSource),
              _row('Assigned To', contact.assignedTo),
            ]),
            const SizedBox(height: 12),
            _section('Address', [
              _row('Street', contact.street),
              _row('City', contact.city),
              _row('State / Region', contact.state),
              _row('Postal Code', contact.postalCode),
              _row('Country', contact.country),
            ]),
            if (contact.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              _section('Description', [
                _row('Description', contact.description),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(label,
                style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
