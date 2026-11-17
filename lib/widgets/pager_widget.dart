import 'package:flutter/material.dart';

class PagerWidget extends StatelessWidget {
  final int page;
  final int totalPages;

  final bool canGoPrevious;
  final bool canGoNext;

  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PagerWidget({
    super.key,
    required this.page,
    required this.totalPages,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: canGoPrevious ? onPrevious : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text("Previous"),
          ),

          const Spacer(),

          Text(
            "Page $page of $totalPages",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const Spacer(),

          ElevatedButton.icon(
            onPressed: canGoNext ? onNext : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text("Next"),
          ),
        ],
      ),
    );
  }
}