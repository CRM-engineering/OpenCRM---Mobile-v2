import 'package:flutter/material.dart';

import '../../models/opportunity.dart';
import '../../utils/html_utils.dart';
import '../../widgets/status_chip.dart';
import 'opportunity_form_screen.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final Opportunity opportunity;

  const OpportunityDetailScreen({
    super.key,
    required this.opportunity,
  });

  String _money(double amount) => 'R ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity'),
        actions: [
          IconButton(
            tooltip: 'Edit Opportunity',
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OpportunityFormScreen(
                    opportunity: opportunity,
                  ),
                ),
              );

              if (updated == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  decodeHtmlEntities(
                    opportunity.name.isEmpty
                        ? 'Unnamed Opportunity'
                        : opportunity.name,
                  ),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _money(opportunity.amount),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              if (opportunity.salesStage.isNotEmpty)
                StatusChip(status: opportunity.salesStage),
              _InfoPill(
                icon: Icons.percent,
                text: '${opportunity.probability}%',
              ),
              _InfoPill(
                icon: Icons.trending_up,
                text: 'Weighted ${_money(opportunity.weightedAmount)}',
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Divider(),
          _detailTile(
            Icons.business,
            'Account',
            decodeHtmlEntities(opportunity.accountName),
          ),
          _detailTile(
            Icons.calendar_today,
            'Expected Close Date',
            opportunity.expectedCloseDate,
          ),
          _detailTile(
            Icons.category,
            'Type',
            opportunity.type,
          ),
          _detailTile(
            Icons.source,
            'Lead Source',
            opportunity.leadSource,
          ),
          _detailTile(
            Icons.person_outline,
            'Assigned To',
            opportunity.assignedTo,
          ),
          _detailTile(
            Icons.next_plan,
            'Next Step',
            opportunity.nextStep,
          ),
          if (opportunity.description.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              decodeHtmlEntities(opportunity.description),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailTile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value.isEmpty ? '-' : value,
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}
