import 'package:flutter/material.dart';

Future<bool?> showStatsScopePicker(
  BuildContext context,
  bool currentMyOnly,
) {
  return showModalBottomSheet<bool>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Record Scope',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose whether this module shows your records or all records you are permitted to access.',
            ),
            const SizedBox(height: 16),
            RadioGroup<bool>(
              groupValue: currentMyOnly,
              onChanged: (value) => Navigator.pop(sheetContext, value),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    value: true,
                    title: const Text('My Statistics'),
                    subtitle: const Text('Records assigned to me'),
                  ),
                  RadioListTile<bool>(
                    value: false,
                    title: const Text('All Accessible'),
                    subtitle: const Text('Everything SuiteCRM allows me to see'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
