import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WARNA TEMA UNGU CYBERPUNK
    const Color startGradientColor = Color(0xFF1E0E3D);
    const Color middleGradientColor = Color(0xFF4C1D95);
    const Color endGradientColor = Color(0xFF6A5ACD);
    const Color primaryTextColor = Colors.white;
    const Color accentColor = Color(0xFFE0BBE4);

    // Warna untuk kilauan bingkai
    const Color glowColor1 = Color(0xFFD8BFD8);

    // WARNA SHIMMER PUTIH BARU
    const Color whiteShimmerColor = Colors.white;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [startGradientColor, middleGradientColor, endGradientColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.black.withOpacity(0.6),
                    boxShadow: [
                      // 1. Bayangan utama untuk kedalaman 3D
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        spreadRadius: 3,
                        blurRadius: 25,
                        offset: const Offset(5, 10),
                      ),

                      // 2. Kilauan Inti Ungu (Dipertahankan)
                      BoxShadow(
                        color: glowColor1.withOpacity(0.8),
                        spreadRadius: 2, // Sedikit diperkecil
                        blurRadius: 15,
                        offset: const Offset(0, 0),
                      ),

                      // 3. KILAUAN SHIMMER PUTIH BARU (Dikuatkan!)
                      BoxShadow(
                        color: whiteShimmerColor.withOpacity(
                          1.0,
                        ), // Opacity 1.0 (Paling Solid)
                        spreadRadius: 4, // Spread lebih besar dari ungu inti
                        blurRadius: 25, // Blur lebih besar
                        offset: const Offset(0, 0),
                      ),

                      // *BoxShadow ungu terluar Dihapus untuk memberi ruang pada Shimmer Putih*
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/logo.png',
                      height: 160,
                      width: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ... (Bagian Teks tetap sama)
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Text(
                        "NekoFeed",
                        style: GoogleFonts.audiowide(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: primaryTextColor,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Temukan anime favoritmu!",
                        style: GoogleFonts.poppins(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
