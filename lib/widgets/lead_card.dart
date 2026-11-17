import 'package:flutter/material.dart';
import '../models/lead.dart';
import '../utils/html_utils.dart';
import 'status_chip.dart';

class LeadCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback? onTap;
  const LeadCard({super.key, required this.lead, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(
                lead.fullName.isEmpty ? 'Unnamed Lead' : decodeHtmlEntities(lead.fullName),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
              const Icon(Icons.chevron_right_rounded),
            ]),
            if (lead.accountName.isNotEmpty) ...[
              const SizedBox(height: 5),
              Row(children: [
                const Icon(Icons.business_outlined, size: 16),
                const SizedBox(width: 7),
                Expanded(child: Text(decodeHtmlEntities(lead.accountName))),
              ]),
            ],
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (lead.status.isNotEmpty) StatusChip(status: lead.status),
              if (lead.leadSource.isNotEmpty) Chip(
                avatar: const Icon(Icons.source_outlined, size: 16),
                label: Text(decodeHtmlEntities(lead.leadSource)),
              ),
            ]),
            if (lead.phoneWork.isNotEmpty || lead.email.isNotEmpty) ...[
              const SizedBox(height: 8),
              if (lead.phoneWork.isNotEmpty) Row(children: [
                const Icon(Icons.phone_outlined, size: 16), const SizedBox(width: 7),
                Expanded(child: Text(lead.phoneWork)),
              ]),
              if (lead.email.isNotEmpty) ...[
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(Icons.email_outlined, size: 16), const SizedBox(width: 7),
                  Expanded(child: Text(lead.email)),
                ]),
              ],
            ],
          ]),
        ),
      ),
    );
  }
}
