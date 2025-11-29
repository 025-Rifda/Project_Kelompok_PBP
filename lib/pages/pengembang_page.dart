import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class PengembangPage extends StatefulWidget {
  const PengembangPage({super.key});

  @override
  State<PengembangPage> createState() => _PengembangPageState();
}

class _PengembangPageState extends State<PengembangPage> {
  final ScrollController _scrollController = ScrollController();
  int _activeIndex = 0;
  List<double> _closeness = [];
  late final List<GlobalKey> _cardKeys;
  final Set<int> _seen = {};

  final List<Map<String, String>> developers = [
    {
      "Role": "DOSEN PENGAMPU",
      "Nama": "Saifuddin Yahya, S.Kom., M.T.I.",
      "NIPD": "0020129004",
      "img": "assets/foto pengembang/pak yahya.jpg",
      "github": "https://github.com/saifudin",
      "instagram": "https://instagram.com/",
    },
    {
      "Role": "KETUA",
      "Nama": "Almas Rifda Zatadin",
      "NIM": "24111814025",
      "Quotes": "Jika commit aja jarang, apalagi komitmen nyata.",
      "img": "assets/foto pengembang/rifda.jpg",
      "github": "https://github.com/025-rifda",
      "instagram": "https://instagram.com/rizenka.airin0701",
    },
    {
      "Role": "ANGGOTA-1",
      "Nama": "Chantika Putri Meunasah",
      "NIM": "24111814037",
      "Quotes": "Enjoy your process",
      "img": "assets/foto pengembang/chantika.jpg",
      "github": "https://github.com/Chantikaputrii",
      "instagram": "https://www.instagram.com/channntk",
    },
    {
      "Role": "ANGGOTA-2",
      "Nama": "Dea Suci Ramadani",
      "NIM": "24111814128",
      "Quotes": "Ketenangan adalah kekuatan yang jarang ada di dalam hati.",
      "img": "assets/foto pengembang/dea.jpg",
      "github": "https://github.com/128-Dea",
      "instagram": "https://www.instagram.com/dhesurha_/",
    },
    {
      "Role": "ANGGOTA-3",
      "Nama": "Dinda Dwi Febiani",
      "NIM": "241118114019",
      "Quotes":
          "Jangan menunggu arah untuk melangkah, tapi melangkah lah agar kau tau arah",
      "img": "assets/foto pengembang/dinda.jpg",
      "github": "https://github.com/Dinda-2802",
      "instagram": "https://www.instagram.com/dindafbiani",
    },
    {
      "Role": "ANGGOTA-4",
      "Nama": "Elysa Hayu Noorhaini",
      "NIM": "24111814078",
      "Quotes":
          "Keinginan sering timeout-sepertinya server realita lagi penuh drama.",
      "img": "assets/foto pengembang/elysa.jpg",
      "github": "https://github.com/Elysa-21",
      "instagram": "https://www.instagram.com/elysaaa21_/",
    },
    {
      "Role": "ANGGOTA-5",
      "Nama": "Dewi Berliana",
      "NIM": "24111814003",
      "Quotes":
          "Jangan takut jadi beda. Bahkan dalam database,\n"
          "yang unik itu justru jadi primary key.",
      "img": "assets/foto pengembang/lian.jpg",
      "github": "https://github.com/Berliana003",
      "instagram": "https://www.instagram.com/berliand_aa",
    },
    {
      "Role": "ANGGOTA-6",
      "Nama": "Rista",
      "NIM": "iSI SENDIRI",
      "Quotes": "ISI SENDIRI",
      "img": "assets/foto pengembang/rista.jpg",
      "github": "https://github.com/",
      "instagram": "https://instagram.com/",
    },
  ];

  @override
  void initState() {
    super.initState();
    _cardKeys = List.generate(developers.length, (_) => GlobalKey());
    _closeness = List.filled(developers.length, 0);
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleScroll());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final height = MediaQuery.of(context).size.height;
    final viewportCenter = height * 0.5;

    int closestIndex = _activeIndex;
    double closestScore = -1;
    final newCloseness = List<double>.filled(developers.length, 0);

    for (var i = 0; i < _cardKeys.length; i++) {
      final ctx = _cardKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final offset = box.localToGlobal(Offset.zero);
      final centerY = offset.dy + box.size.height / 2;
      final distance = (centerY - viewportCenter).abs();
      final score = (1 - (distance / viewportCenter)).clamp(0.0, 1.0);
      newCloseness[i] = score;
      if (score > closestScore) {
        closestScore = score;
        closestIndex = i;
      }
    }

    setState(() {
      _activeIndex = closestIndex;
      _closeness = newCloseness;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "About Us",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color.fromARGB(255, 236, 185, 245),
                Color.fromARGB(255, 172, 130, 220),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    Color(0xFF1B1829),
                    Color(0xFF161324),
                    Color(0xFF120F1E),
                  ] // Palet gelap selaras dengan halaman pengaturan
                : const [
                    Color(0xFFF4ECFF),
                    Color(0xFFEDE7FF),
                    Color(0xFFF7F1FF),
                  ],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 40.h,
                    child: Image.asset(
                      "assets/foto pengembang/bersama.jpg",
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Our Developers Team Nekofeed",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color.fromARGB(255, 148, 108, 217)
                          : Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 6.h),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final dev = developers[index];
                  final hasSeen = _seen.contains(index);
                  if (!hasSeen) _seen.add(index);

                  final t = index < _closeness.length ? _closeness[index] : 0.0;
                  // Buat animasi lebih terlihat tapi tetap halus
                  final scale = 0.99 + (0.03 * t); // max ~1.02
                  final opacity = 0.9 + (0.1 * t);
                  final lift = 2 + (10 * t);
                  final blur = 4 + (8 * t);
                  final isPrimary = index == _activeIndex;

                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 340 + (index * 25)),
                    curve: Curves.easeOut,
                    tween: Tween(begin: hasSeen ? 0 : 18, end: 0),
                    builder: (context, offsetY, child) {
                      return KeyedSubtree(
                        key: _cardKeys[index],
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1180),
                            child: Transform.translate(
                              offset: Offset(0, -lift),
                              child: AnimatedOpacity(
                                opacity: opacity,
                                duration: const Duration(milliseconds: 220),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: isMobile ? 2.h : 2.5.h,
                                  ),
                                  child: Transform.translate(
                                    offset: Offset(0, offsetY),
                                    child: AnimatedScale(
                                      scale: scale,
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      curve: Curves.easeOut,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),
                                        curve: Curves.easeOut,
                                        padding: EdgeInsets.all(
                                          isMobile ? 4.w : 2.5.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Theme.of(context).cardColor
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          boxShadow: isDark
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(
                                                          0.35 * t + 0.1,
                                                        ),
                                                    blurRadius: blur,
                                                    spreadRadius: 0.4 * t,
                                                    offset: Offset(
                                                      0,
                                                      10 - (5 * t),
                                                    ),
                                                  ),
                                                ]
                                              : [
                                                  BoxShadow(
                                                    color: Colors.deepPurple
                                                        .withOpacity(
                                                          0.12 * t + 0.06,
                                                        ),
                                                    blurRadius: blur,
                                                    spreadRadius: 0.8 * t,
                                                    offset: Offset(
                                                      0,
                                                      14 - (6 * t),
                                                    ),
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.white
                                                        .withOpacity(0.75),
                                                    blurRadius: 10,
                                                    offset: const Offset(
                                                      -3,
                                                      -3,
                                                    ),
                                                  ),
                                                ],
                                          gradient: isDark
                                              ? null
                                              : LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white,
                                                    Color.lerp(
                                                          Colors.white,
                                                          const Color(
                                                            0xFFF3ECFF,
                                                          ),
                                                          0.3 * t,
                                                        ) ??
                                                        Colors.white,
                                                  ],
                                                ),
                                        ),
                                        child: isMobile
                                            ? _buildColumnCard(
                                                context,
                                                dev,
                                                isPrimary,
                                              )
                                            : _buildRowCard(
                                                context,
                                                dev,
                                                isPrimary,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: developers.length),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 1.h),
                    Text(
                      "About This Project",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color.fromARGB(255, 148, 108, 217)
                            : Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "Aplikasi ini dikembangkan oleh tim kami sebagai proyek pembelajaran "
                      "dengan tujuan meningkatkan keterampilan Flutter, API integration, "
                      "UI/UX modern, dan kolaborasi kelompok.",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white : null,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      "Kata-Kata Mutiara",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color.fromARGB(255, 148, 108, 217)
                            : Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "\"Kolaborasi yang tulus melahirkan karya yang bermakna.\"",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white : Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowCard(
    BuildContext context,
    Map<String, String> dev,
    bool isPrimary,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.asset(
                dev["img"]!,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(flex: 4, child: _buildInfo(context, dev, isPrimary, false)),
      ],
    );
  }

  Widget _buildColumnCard(
    BuildContext context,
    Map<String, String> dev,
    bool isPrimary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Image.asset(
              dev["img"]!,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        _buildInfo(context, dev, isPrimary, true),
      ],
    );
  }

  Widget _buildInfo(
    BuildContext context,
    Map<String, String> dev,
    bool isPrimary,
    bool centered,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final iconGithubColor = isDark ? Colors.white : Colors.black87;
    final iconInstagramColor = isDark ? primaryColor : Colors.pinkAccent;
    final textColor = isDark ? Colors.white : Colors.grey[700];

    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dev["Role"] ?? "",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? const Color.fromARGB(255, 148, 108, 217)
                : Colors.deepPurple.shade600,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          dev["Nama"]!,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isDark
                ? const Color.fromARGB(255, 148, 108, 217)
                : Colors.deepPurple.shade700,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(() {
          if (dev.containsKey("NIPD")) {
            return "NIPD: ${dev["NIPD"] ?? "-"}";
          }
          return "NIM: ${dev["NIM"] ?? "-"}";
        }(), style: TextStyle(fontSize: 12.sp, color: textColor)),
        Text(
          "Quotes: ${dev["Quotes"]}",
          style: TextStyle(
            fontSize: 12.sp,
            color: textColor,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: centered
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(
              Icons.bolt,
              size: 18,
              color: isPrimary
                  ? (isDark ? primaryColor : Colors.deepPurple)
                  : (isDark ? Colors.grey[400] : Colors.grey[500]),
            ),
            const SizedBox(width: 6),
            Text(
              isPrimary ? "Sedang tampil" : "Scroll untuk lihat",
              style: TextStyle(
                fontSize: 10.sp,
                color: isDark
                    ? Colors.white
                    : (isPrimary ? Colors.deepPurple : Colors.grey[600]),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: centered
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            _IconButton(
              icon: FontAwesomeIcons.github,
              color: iconGithubColor,
              onTap: () => _launch(dev["github"]!),
            ),
            SizedBox(width: centered ? 5.w : 1.5.w),
            _IconButton(
              icon: FontAwesomeIcons.instagram,
              color: iconInstagramColor,
              onTap: () => _launch(dev["instagram"]!),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    // Keep behavior simple: buka persis URL yang diberikan di luar (mirip contoh kode awal).
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: FaIcon(icon, color: color, size: 28),
      ),
    );
  }
}
