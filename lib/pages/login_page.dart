import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Jika user masih login (token masih aktif)
      await Future.delayed(const Duration(milliseconds: 500)); // biar smooth
      if (mounted) context.go('/dashboard');
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Tampilkan loading sementara
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        // Login dengan Firebase Auth
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Tutup loading
        if (context.mounted) Navigator.pop(context);

        // Simpan data user ke SharedPreferences setelah login berhasil
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          final username = user.displayName ?? 'Pengguna';
          final email = user.email ?? _usernameController.text.trim();
          final joinDate =
              user.metadata.creationTime?.toIso8601String() ??
              DateTime.now().toIso8601String();

          await prefs.setString('username', username);
          await prefs.setString('user_email_$username', email);
          await prefs.setString('user_join_date_$username', joinDate);
          // Only set default if not already set
          if (prefs.getString('user_phone_$username') == null) {
            await prefs.setString('user_phone_$username', '+62');
          }
          if (prefs.getString('user_address_$username') == null) {
            await prefs.setString('user_address_$username', 'Belum diisi');
          }
        }

        // Arahkan ke dashboard (misal)
        context.go('/dashboard');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (context.mounted) Navigator.pop(context);

        String message = 'Password lama salah';
        if (e.code == 'user-not-found') {
          message = 'Pengguna tidak ditemukan. Silakan daftar dulu.';
        } else if (e.code == 'wrong-password') {
          message = 'Password lama salah';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E0E3D), Color(0xFF4C1D95), Color(0xFF6A5ACD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo dari assets
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.black.withOpacity(0.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.7),
                          spreadRadius: 3,
                          blurRadius: 25,
                          offset: const Offset(5, 10),
                        ),
                        BoxShadow(
                          color: const Color(0xFFD8BFD8).withOpacity(0.8),
                          spreadRadius: 2,
                          blurRadius: 15,
                          offset: const Offset(0, 0),
                        ),
                        // Efek glow putih/terang di sekitar logo
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Judul dan Subjudul
                  Column(
                    // Memastikan teks di tengah agar tidak terpengaruh wrapping
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        // Menggunakan kata yang lebih pendek/ukuran font lebih kecil
                        'Masuk ke NekoFeed',
                        style: GoogleFonts.audiowide(
                          // FONT SIZE DIKECILKAN (28 -> 24)
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          // LETTER SPACING DIKURANGI (2 -> 1)
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Temukan anime favoritmu!',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFE0BBE4),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.white70,
                      ),
                      // Desain border disederhanakan dan diperjelas
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!value.contains('@')) {
                        return 'Masukkan email yang valid';
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Field Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      // Desain border disederhanakan dan diperjelas
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Tombol Login
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0BBE4),
                      foregroundColor: const Color(0xFF1E0E3D),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Masuk',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Link ke Register
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text(
                      'Belum punya akun? Daftar di sini',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFE0BBE4),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
