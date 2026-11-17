import 'package:flutter/material.dart';

import '../models/opportunity.dart';
import '../utils/html_utils.dart';

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback? onTap;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.onTap,
  });

  String _money(double amount) => 'R ${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _money(opportunity.amount),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              if (opportunity.accountName.isNotEmpty) ...[
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(Icons.business, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        decodeHtmlEntities(opportunity.accountName),
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 9),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      opportunity.salesStage.isEmpty
                          ? 'No Stage'
                          : opportunity.salesStage,
                    ),
                  ),
                  Chip(
                    avatar: const Icon(Icons.percent, size: 16),
                    label: Text('${opportunity.probability}%'),
                  ),
                ],
              ),
              if (opportunity.expectedCloseDate.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Close: ${opportunity.expectedCloseDate}',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
