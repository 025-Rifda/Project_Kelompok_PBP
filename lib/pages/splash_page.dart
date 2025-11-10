import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // Efek Scale In dengan memantul (menarik)
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
    // Teks mulai setelah logo muncul
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textController.forward();
      }
    });

    // Jarak slide teks dibuat LEBIH JAUH (0.4) agar animasi terlihat dramatis
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
    // WARNA GRADIENT TIGA WARNA DARI PERMINTAAN ANDA
    const Color color1 = Color(0xFF1E0E3D); // Ungu gelap
    const Color color2 = Color(0xFF4C1D95); // Ungu sedang
    const Color color3 = Color(0xFF6A5ACD); // Ungu terang (Lavender)

    // Warna teks tetap serasi dengan tema futuristik
    const Color primaryTextColor = Colors.white;
    const Color accentColor = Color(0xFF03DAC6); // Biru-Hijau terang
    const Color secondaryAccentColor = Color(0xFFBB86FC); // Ungu elektrik

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // MENGGUNAKAN TIGA WARNA BARU
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
              // LOGO (Kucing + 4 TV)
              FadeTransition(
                opacity: _logoFadeAnimation,
                child: ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Image.asset(
                    'assets/splash.png', // Logo transparan Anda
                    height: 250,
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Jarak antara logo dan teks SANGAT RAPAT (2 piksel)
              const SizedBox(height: 2),

              // TEKS "NekoFeed" & Jepang (Dengan Animasi Menonjol)
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
                      // Jarak antara judul & subjudul
                      const SizedBox(height: 5),
                      Text(
                        "アエメキース", // Teks Jepang
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
            ],
          ),
        ),
      ),
    );
  }
}
