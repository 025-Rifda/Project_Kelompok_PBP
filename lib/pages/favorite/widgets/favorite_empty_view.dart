import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FavoriteEmptyView extends StatelessWidget {
  const FavoriteEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 18.w,
            color: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(height: 2.h),
          Text(
            'Belum ada anime favorit',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tambahkan anime dari halaman detail',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
