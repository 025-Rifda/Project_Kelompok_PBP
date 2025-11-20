import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/sidebar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  String _username = 'Pengguna';
  String _email = 'pengguna@example.com';
  String _joinDate = 'Januari 2024';
  String _phone = '+62';
  String _address = 'Belum diisi';

  String? _profileImagePath;
  Uint8List? _profileImageBytes;

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Pengguna';

    final email =
        prefs.getString('user_email_$username') ?? 'pengguna@example.com';
    final joinDateIso = prefs.getString('user_join_date_$username');
    final phone = prefs.getString('user_phone_$username') ?? '+62';
    final address = prefs.getString('user_address_$username') ?? 'Belum diisi';

    final savedImagePath = prefs.getString('user_image_path_$username');
    final savedImageBase64 = prefs.getString('user_image_base64_$username');

    String joinDate = 'Januari 2024';
    if (joinDateIso != null) {
      final date = DateTime.parse(joinDateIso);
      joinDate = '${_getMonthName(date.month)} ${date.year}';
    }

    Uint8List? imageBytes;
    if (savedImageBase64 != null && savedImageBase64.isNotEmpty) {
      try {
        imageBytes = base64Decode(savedImageBase64);
      } catch (_) {
        imageBytes = null;
      }
    }
    if (imageBytes == null && savedImagePath != null && !kIsWeb) {
      final file = File(savedImagePath);
      if (await file.exists()) {
        imageBytes = await file.readAsBytes();
      }
    }

    setState(() {
      _username = username;
      _email = email;
      _joinDate = joinDate;
      _phone = phone;
      _address = address;
      _profileImagePath = savedImagePath;
      _profileImageBytes = imageBytes;
    });

    _usernameController.text = _username;
    _emailController.text = _email;
    _phoneController.text = _phone;
    _addressController.text = _address;
  }

  // PERBAIKAN BESAR DI SINI 🔥
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          'user_image_base64_$_username',
          base64Encode(bytes),
        );

        String? filePath;
        if (!kIsWeb) {
          final directory = await getApplicationDocumentsDirectory();
          final fileName =
              'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
          filePath = path.join(directory.path, fileName);

          final file = File(filePath);
          await file.writeAsBytes(bytes);

          await prefs.setString('user_image_path_$_username', filePath);
        } else {
          await prefs.remove('user_image_path_$_username');
        }

        setState(() {
          _profileImagePath = filePath;
          _profileImageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('username', _usernameController.text);
    await prefs.setString(
      'user_email_${_usernameController.text}',
      _emailController.text,
    );
    await prefs.setString(
      'user_phone_${_usernameController.text}',
      _phoneController.text,
    );
    await prefs.setString(
      'user_address_${_usernameController.text}',
      _addressController.text,
    );

    setState(() {
      _username = _usernameController.text;
      _email = _emailController.text;
      _phone = _phoneController.text;
      _address = _addressController.text;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sudah berhasil disimpan', textAlign: TextAlign.center),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedPage: 'Profil'),
          Expanded(child: Column(children: [_buildHeader(), _buildContent()])),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/settings'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Profil',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check_circle : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT: FOTO
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _profileImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                _profileImageBytes!,
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 150,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _username,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _email,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 40),

            // RIGHT: DATA PROFIL
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildProfileField(
                    'Nama',
                    _usernameController,
                    editable: _isEditing,
                  ),
                  _buildProfileField(
                    'Email',
                    _emailController,
                    editable: _isEditing,
                  ),
                  _buildProfileField(
                    'Phone Number',
                    _phoneController,
                    editable: _isEditing,
                  ),
                  _buildProfileField(
                    'Address',
                    _addressController,
                    editable: _isEditing,
                  ),
                  _buildProfileField('Bergabung Sejak', _joinDate),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    dynamic value, {
    bool editable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 5),
          editable
              ? TextField(
                  controller: value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.pink.shade200),
                  ),
                  child: Text(
                    value is TextEditingController ? value.text : value,
                  ),
                ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }
}
