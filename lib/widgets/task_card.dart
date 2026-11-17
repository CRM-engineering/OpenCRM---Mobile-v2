import 'package:flutter/material.dart';
class CrmTaskCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const CrmTaskCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.task_alt, color: Color(0xFFF7941D)),
              const SizedBox(width: 10),
              Expanded(child: Text(
                item.name,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              )),
            ]),
              if (item.dateDue.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.event, size: 16),
                  const SizedBox(width: 7),
                  Expanded(child: Text(item.dateDue)),
                ]),
              ],              if (item.priority.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.priority_high, size: 16),
                  const SizedBox(width: 7),
                  Expanded(child: Text(item.priority)),
                ]),
              ],              if (item.status.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 7),
                  Expanded(child: Text(item.status)),
                ]),
              ],
          ]),
        ),
      ),
    );
  }
}
