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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: isMobile ? 1.2.h : 1.h,
      ),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Text(
            'Filter Favorit',
            style: TextStyle(
              fontSize: isMobile ? 16.sp : 13.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 2.w,
            children: [
              _filterButton(
                icon: Icons.star,
                label: 'Rating',
                color: const Color.fromARGB(255, 152, 209, 255),
                onPressed: () => showRatingFilterDialog(context),
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
}
