import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FavoriteHeader extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onBack;

  const FavoriteHeader({
    super.key,
    required this.isMobile,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 1.5.h : 2.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 236, 185, 245),
            Color.fromARGB(255, 172, 130, 220),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 17.sp),
            onPressed: onBack,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Anime Favorit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 15.sp : 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
