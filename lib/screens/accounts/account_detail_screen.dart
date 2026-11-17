import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../services/account_service.dart';
import 'account_form_screen.dart';

class AccountDetailScreen extends StatefulWidget {
  final Account account;

  const AccountDetailScreen({
    super.key,
    required this.account,
  });

  @override
  State<AccountDetailScreen> createState() =>
      _AccountDetailScreenState();
}

class _AccountDetailScreenState
    extends State<AccountDetailScreen> {
  final _service = AccountService();

  late Account account;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    account = widget.account;
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<Account>(
      context,
      MaterialPageRoute(
        builder: (_) => AccountFormScreen(account: account),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        account = updated;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() => loading = true);

    try {
      final fresh = await _service.getAccount(account.id);
      if (fresh != null && mounted) {
        setState(() => account = fresh);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            tooltip: 'Edit Account',
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
            _section(
              'Overview',
              [
                _row('Name', account.name),
                _row('Type', account.type),
                _row('Industry', account.industry),
                _row('Office Phone', account.officePhone),
                _row('Fax', account.fax),
                _row('Website', account.website),
                _row('Email', account.email),
                _row('Assigned To', account.assignedTo),
              ],
            ),
            const SizedBox(height: 12),
            _section(
              'Billing Address',
              [
                _row('Street', account.billingStreet),
                _row('City', account.billingCity),
                _row('State / Region', account.billingState),
                _row('Postal Code', account.billingPostalCode),
                _row('Country', account.billingCountry),
              ],
            ),
            const SizedBox(height: 12),
            _section(
              'Shipping Address',
              [
                _row('Street', account.shippingStreet),
                _row('City', account.shippingCity),
                _row('State / Region', account.shippingState),
                _row('Postal Code', account.shippingPostalCode),
                _row('Country', account.shippingCountry),
              ],
            ),
            const SizedBox(height: 12),
            _section(
              'More Information',
              [
                _row('Annual Revenue', account.annualRevenue),
                _row('Employees', account.employees),
                _row('Description', account.description),
              ],
            ),
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
