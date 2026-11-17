import 'package:flutter/material.dart';

import '../utils/html_utils.dart';

class CrmCallCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const CrmCallCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                children: [
                  const Icon(
                    Icons.call,
                    color: Color(0xFFF7941D),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      decodeHtmlEntities(item.name),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              if (item.dateStart.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(item.dateStart),
                    ),
                  ],
                ),
              ],

              if (item.phone.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 16),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(item.phone),
                    ),
                  ],
                ),
              ],

              if (item.status.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(item.status),
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