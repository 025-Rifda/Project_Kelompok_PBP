import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../bloc/anime_bloc.dart';
import '../../../bloc/anime_event.dart';
import 'favorite_rating_dialog.dart';

class FavoriteFilterBar extends StatelessWidget {
  const FavoriteFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 4.w : 2.w,
        vertical: isMobile ? 1.2.h : 1.h,
      ),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Favorit',
            style: TextStyle(
              fontSize: isMobile ? 16.sp : 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          SizedBox(height: isMobile ? 1.h : 0.5.h),

          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 1.5.w,
              runSpacing: 1.w,
              children: [
                _filterButton(
                  icon: Icons.star,
                  label: 'Rating',
                  color: const Color.fromARGB(255, 152, 209, 255),
                  onPressed: () => showRatingFilterDialog(context),
                  isMobile: isMobile,
                ),
                _filterButton(
                  icon: Icons.delete_sweep,
                  label: 'Hapus Semua',
                  color: Colors.red,
                  onPressed: () => _clearAllFavorites(context),
                  isMobile: isMobile,
                ),
                _filterButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  color: Colors.grey,
                  onPressed: () {
                    context.read<AnimeBloc>().add(ResetFilterEvent());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sorting favorit direset'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  isMobile: isMobile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isMobile,
  }) {
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

  void _clearAllFavorites(BuildContext context) {
    final bloc = context.read<AnimeBloc>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus semua favorit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              bloc.add(ClearAllFavoritesEvent());

              // Wait longer for the event to process
              await Future.delayed(const Duration(milliseconds: 500));

              if (context.mounted) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua favorit telah dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
