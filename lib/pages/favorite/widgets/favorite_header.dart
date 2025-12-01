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
    if (isMobile) {
      // MOBILE MODE
      return AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
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
        ),
        title: Text(
          'Anime Favorit',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBack,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      );
    }

    // DESKTOP MODE
    return Container(
      padding: const EdgeInsets.all(20),
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
