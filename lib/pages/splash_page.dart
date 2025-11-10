import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  late AnimationController _textController;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Animasi Logo (Scale & Fade In)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInCubic),
    );

    // 2. Animasi Teks (Slide Up & Fade In)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textController.forward();
      }
    });

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Pindah ke halaman berikutnya setelah 4 detik
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Warna tema
    const Color color1 = Color(0xFF1E0E3D);
    const Color color2 = Color(0xFF4C1D95);
    const Color color3 = Color(0xFF6A5ACD);

    const Color primaryTextColor = Colors.white;
    const Color accentColor = Color(0xFF03DAC6);
    const Color secondaryAccentColor = Color(0xFFBB86FC);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2, color3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // LOGO
              FadeTransition(
                opacity: _logoFadeAnimation,
                child: ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Image.asset(
                    'assets/splash.png',
                    height: 250,
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 2),

              // TEKS NekoFeed + Jepang
              FadeTransition(
                opacity: _textFadeAnimation,
                child: SlideTransition(
                  position: _textSlideAnimation,
                  child: Column(
                    children: [
                      Text(
                        "NekoFeed",
                        style: GoogleFonts.audiowide(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: primaryTextColor,
                          letterSpacing: 5,
                          shadows: [
                            Shadow(
                              color: accentColor.withOpacity(0.7),
                              blurRadius: 15,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "アエメキース",
                        style: GoogleFonts.poppins(
                          color: secondaryAccentColor.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          shadows: [
                            Shadow(
                              color: secondaryAccentColor.withOpacity(0.5),
                              blurRadius: 5,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // === LOADING ANIMATION ===
              FadeTransition(
                opacity: _textFadeAnimation,
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: accentColor,
                  size: 60,
                ),
              ),

              const SizedBox(height: 25),

              // === NAMA KELOMPOK ===
              FadeTransition(
                opacity: _textFadeAnimation,
                child: Text(
                  "By Kelompok 1",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    letterSpacing: 1,
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
