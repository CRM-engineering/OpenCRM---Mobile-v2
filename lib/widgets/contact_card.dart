import 'package:flutter/material.dart';

import '../models/contact.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ContactCard({
    super.key,
    required this.contact,
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
                  const Icon(Icons.person_outline,
                      color: Color(0xFFF7941D)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      contact.fullName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (contact.title.isNotEmpty ||
                  contact.department.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text([
                  if (contact.title.isNotEmpty) contact.title,
                  if (contact.department.isNotEmpty) contact.department,
                ].join(' • ')),
              ],
              if (contact.accountName.isNotEmpty) ...[
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(Icons.business_outlined, size: 16),
                    const SizedBox(width: 7),
                    Expanded(child: Text(contact.accountName)),
                  ],
                ),
              ],
              if (contact.phoneWork.isNotEmpty ||
                  contact.phoneMobile.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 16),
                    const SizedBox(width: 7),
                    Text(
                      contact.phoneWork.isNotEmpty
                          ? contact.phoneWork
                          : contact.phoneMobile,
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
