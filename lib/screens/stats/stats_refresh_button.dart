import 'package:flutter/material.dart';

class StatsRefreshButton extends StatelessWidget {
  final VoidCallback onRefresh;
  const StatsRefreshButton({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Segarkan Statistik'),
        ),
      ),
    );
  }
}

