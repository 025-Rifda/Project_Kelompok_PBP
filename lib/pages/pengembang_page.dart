import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class PengembangPage extends StatelessWidget {
  PengembangPage({super.key});

  final List<Map<String, String>> developers = [
    {
      "Nama": "Chantika",
      "NIM": "iSI SENDIRI",
      "Quotes": "ISI SENDIRI",
      "img": "assets/foto pengembang/chantika.jpg",
      "github": "https://github.com/",
      "instagram": "https://instagram.com/",
    },
    {
      "Nama": "Dea",
      "NIM": "iSI SENDIRI",
      "Quotes": "ISI SENDIRI",
      "img": "assets/foto pengembang/dea.jpg",
      "github": "https://github.com/",
      "instagram": "https://instagram.com/",
    },
    {
      "Nama": "Dinda",
      "NIM": "iSI SENDIRI",
      "Quotes": "ISI SENDIRI",
      "img": "assets/foto pengembang/dinda.jpg",
      "github": "https://github.com/",
      "instagram": "https://instagram.com/",
    },
    {
      "Nama": "Elysa Hayu Noorhaini",
      "NIM": "24111814078",
      "Quotes": "ISI SENDIRI",
      "img": "assets/foto pengembang/elysa.jpg",
      "github": "https://github.com/Elysa-21",
      "instagram": "https://www.instagram.com/elysaaa21_?igsh=bjllNTJlNWcycjd3",
    },
    {
      "Nama": "Lian",
      "NIM": "iSI SENDIRI",
      "Quotes": "ISI SENDIRI",
      "img": "assets/foto pengembang/lian.jpg",
      "github": "https://github.com/",
      "instagram": "https://instagram.com/",
    },
    {
      "Nama": "Rifda",
      "NIM": "iSI SENDIRI",
      "Quotes": "ISI SENDIRI",
      "img": "assets/foto pengembang/rifda.jpg",
      "github": "https://github.com/",
      "instagram": "https://instagram.com/",
    },
    {
      "Nama": "Rista",
      "NIM": "iSI SENDIRI",
      "Quotes": "ISI SENDIRI",
      "img": "assets/foto pengembang/rista.jpg",
      "github": "https://github.com/",
      "instagram": "https://instagram.com/",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        centerTitle: true,
        backgroundColor: const Color(0xFFAC82DC),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // FOTO BESAR HEADER
            SizedBox(
              width: double.infinity,
              height: 30.h,
              child: Image.asset(
                "assets/foto pengembang/bersama.jpg",
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 2.h),

            // JUDUL
            Text(
              "Our Developers Team 💜",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            SizedBox(height: 2.h),

            // GRID PENGEMBANG
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: developers.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 2 : 4,
                  childAspectRatio: isMobile ? 0.60 : 0.70,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 2.h,
                ),
                itemBuilder: (context, index) {
                  final dev = developers[index];

                  return Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            dev["img"]!,
                            height: isMobile ? 13.h : 18.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 1.h),

                        Text(
                          dev["Nama"]!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "NIM: ${dev["NIM"]}",
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.grey[700],
                          ),
                        ),

                        Text(
                          "Quotes: ${dev["Quotes"]}",
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.grey[700],
                          ),
                        ),

                        SizedBox(height: 1.h),

                        // SOCIAL LINKS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.code,
                                color: Colors.black87,
                              ),
                              onPressed: () => _launch(dev["github"]!),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.purple,
                              ),
                              onPressed: () => _launch(dev["instagram"]!),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 3.h),

            // ABOUT TEXT
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About This Project",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Aplikasi ini dikembangkan oleh tim kami sebagai proyek pembelajaran "
                    "dengan tujuan meningkatkan keterampilan Flutter, API integration, "
                    "UI/UX modern, dan kolaborasi kelompok.",
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
