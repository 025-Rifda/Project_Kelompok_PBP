import 'package:flutter/material.dart';

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 100,
            color: colorScheme.onBackground.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada riwayat kunjungan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Riwayat anime yang dikunjungi akan muncul di sini',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
