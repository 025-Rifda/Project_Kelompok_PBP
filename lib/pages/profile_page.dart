import 'package:sizer/sizer.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'maps_page.dart';
import 'package:latlong2/latlong.dart';

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
  LatLng? _lastLocation;

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

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final newUsername = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newAddress = _addressController.text.trim();

    // Update preferences
    await prefs.setString('username', newUsername);
    await prefs.setString('user_email_$newUsername', newEmail);
    await prefs.setString('user_phone_$newUsername', newPhone);
    await prefs.setString('user_address_$newUsername', newAddress);

    // If username changed, migrate image data
    if (newUsername != _username) {
      final oldImageBase64 = prefs.getString('user_image_base64_$_username');
      final oldImagePath = prefs.getString('user_image_path_$_username');
      if (oldImageBase64 != null) {
        await prefs.setString('user_image_base64_$newUsername', oldImageBase64);
        await prefs.remove('user_image_base64_$_username');
      }
      if (oldImagePath != null) {
        await prefs.setString('user_image_path_$newUsername', oldImagePath);
        await prefs.remove('user_image_path_$_username');
      }
    }

    setState(() {
      _username = newUsername;
      _email = newEmail;
      _phone = newPhone;
      _address = newAddress;
      _isEditing = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan')));
  }

  void _cancelEditing() {
    _usernameController.text = _username;
    _emailController.text = _email;
    _phoneController.text = _phone;
    _addressController.text = _address;
    setState(() {
      _isEditing = false;
    });
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

    double? lat = prefs.getDouble('user_latitude');
    double? lng = prefs.getDouble('user_longitude');

    if (lat != null && lng != null) {
      _lastLocation = LatLng(lat, lng);
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

  Future<void> _pickImage({bool useCamera = false}) async {
    try {
      final picker = ImagePicker();

      // PLATFORM WEB
      if (kIsWeb) {
        final picked = await picker.pickImage(
          source: useCamera ? ImageSource.camera : ImageSource.gallery,
        );

        if (picked != null) {
          final bytes = await picked.readAsBytes();
          setState(() => _profileImageBytes = bytes);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'user_image_base64_$_username',
            base64Encode(bytes),
          );
        }
        return; // STOP DI WEB
      }

      // PLATFORM MOBILE (ANDROID / IOS)
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage, // Android <13
        Permission.photos, // iOS
        Permission.camera, // Untuk kamera
      ].request();

      if (statuses[Permission.storage]!.isGranted ||
          statuses[Permission.photos]!.isGranted ||
          statuses[Permission.camera]!.isGranted) {
        final picked = await picker.pickImage(
          source: useCamera ? ImageSource.camera : ImageSource.gallery,
        );

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
          }

          setState(() {
            _profileImageBytes = bytes;
            _profileImagePath = filePath;
          });
        }
      } else if (statuses[Permission.photos]!.isPermanentlyDenied ||
          statuses[Permission.storage]!.isPermanentlyDenied) {
        openAppSettings();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Izin ditolak')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _openMapPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapsPage(
          initialLocation:
              _lastLocation ?? LatLng(-6.2, 106.8), // default Jakarta
          onLocationSelected: (LatLng pos, String address) async {
            final prefs = await SharedPreferences.getInstance();

            await prefs.setDouble('user_latitude', pos.latitude);
            await prefs.setDouble('user_longitude', pos.longitude);
            await prefs.setString('user_address_${_username}', address);

            setState(() {
              _lastLocation = pos;
              _address = address;
              _addressController.text = address;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    if (isMobile) {
      // TAMPILAN MOBILE
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
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
          title: const Text(
            'Profil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
        body: _buildContent(),
      );
    }

    // TAMPILAN DESKTOP
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(selectedPage: 'Profil'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Container(
      padding: EdgeInsets.all(isMobile ? 9 : 20),
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
            onPressed: () => context.go('/dashboard'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Profil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 17.sp),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final imageSize = isMobile ? 150.0 : 300.0;
    return SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT: FOTO
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // FOTO DI ATAS
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          _profileImageBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.memory(
                                    _profileImageBytes!,
                                    width: imageSize,
                                    height: imageSize,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: imageSize,
                                  height: imageSize,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: isMobile ? 75.0 : 150.0,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () async {
                                final isCamera = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Pilih Sumber Gambar'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Galeri'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Kamera'),
                                      ),
                                    ],
                                  ),
                                );
                                _pickImage(useCamera: isCamera ?? false);
                              },
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
                        _isEditing ? _usernameController.text : _username,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        _isEditing ? _emailController.text : _email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // FORM DI BAWAH FOTO
                  Column(
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Address',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: _isEditing
                                      ? TextField(
                                          controller: _addressController,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: Colors.pink.shade200,
                                            ),
                                          ),
                                          child: Text(
                                            _addressController.text,
                                            style: TextStyle(fontSize: 11.sp),
                                          ),
                                        ),
                                ),
                              ],
                            ),

                            // 🔥 TARUH DISINI DENGAN IF DI DALAM LIST
                            if (_isEditing)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton.icon(
                                  onPressed: _openMapPage,
                                  icon: const Icon(Icons.location_on),
                                  label: const Text("Pilih di Peta"),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      _buildProfileField('Bergabung Sejak', _joinDate),
                      const SizedBox(height: 20),
                      if (_isEditing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Simpan'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _cancelEditing,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Batal'),
                            ),
                          ],
                        )
                      else
                        Center(
                          child: ElevatedButton(
                            onPressed: _toggleEditing,
                            child: const Text('Edit Profil'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: editable
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
                          style: TextStyle(fontSize: 11.sp),
                        ),
                      ),
              ),
            ],
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
