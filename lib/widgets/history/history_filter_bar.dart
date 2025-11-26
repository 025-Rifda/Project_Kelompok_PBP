import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({
    super.key,
    required this.onFilterRating,
    required this.onToggleDate,
    required this.onClearAll,
    required this.isMobile,
  });

  final VoidCallback onFilterRating;
  final VoidCallback onToggleDate;
  final VoidCallback onClearAll;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Riwayat',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: isMobile ? 16.sp : 14.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 10,
              children: [
                _FilterButton(
                  icon: Icons.star,
                  label: 'Rating',
                  color: const Color(0xFF98D1FF),
                  onPressed: onFilterRating,
                  isMobile: isMobile,
                ),
                _FilterButton(
                  icon: Icons.sort,
                  label: 'Tanggal',
                  color: const Color(0xFF81C784),
                  onPressed: onToggleDate,
                  isMobile: isMobile,
                ),
                _FilterButton(
                  icon: Icons.delete_sweep,
                  label: 'Hapus Semua',
                  color: Colors.red,
                  onPressed: onClearAll,
                  isMobile: isMobile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    required this.isMobile,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isMobile ? 14.sp : 12.sp),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textStyle: TextStyle(fontSize: isMobile ? 14.sp : 12.sp),
      ),
    );
  }
}
