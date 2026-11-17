import 'package:flutter/material.dart';

import '../../models/lead.dart';
import '../../services/lead_service.dart';
import '../../widgets/status_chip.dart';
import 'lead_form_screen.dart';

class LeadDetailScreen extends StatelessWidget {
  final Lead lead;

  const LeadDetailScreen({
    super.key,
    required this.lead,
  });

  Future<void> _deleteLead(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Lead"),
        content: Text(
          "Are you sure you want to delete '${lead.fullName}'?\n\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await LeadService().deleteLead(lead.id);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lead deleted successfully."),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete lead."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lead.fullName),
        actions: [
          IconButton(
            tooltip: "Edit Lead",
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeadFormScreen(
                    lead: lead,
                  ),
                ),
              );

              if (updated == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            tooltip: "Delete Lead",
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteLead(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            lead.fullName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerLeft,
            child: StatusChip(
              status: lead.status,
            ),
          ),

          const SizedBox(height: 25),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.business),
            title: const Text("Company"),
            subtitle: Text(
              lead.accountName.isEmpty ? "-" : lead.accountName,
            ),
          ),

          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text("Business Phone"),
            subtitle: Text(
              lead.phoneWork.isEmpty ? "-" : lead.phoneWork,
            ),
          ),

          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Email"),
            subtitle: Text(
              lead.email.isEmpty ? "-" : lead.email,
            ),
          ),

          const Divider(),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("EDIT"),
                  onPressed: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LeadFormScreen(
                          lead: lead,
                        ),
                      ),
                    );

                    if (updated == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text("DELETE"),
                  onPressed: () => _deleteLead(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}