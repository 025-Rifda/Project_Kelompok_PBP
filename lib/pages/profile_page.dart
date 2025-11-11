import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/sidebar.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../services/image_upload_service.dart';
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
  String? _profileImageUrl; // Firebase Storage URL
  Uint8List? _profileImageBytes;

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  final ImageUploadService _imageUploadService = ImageUploadService();

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
    final profileImageUrl = prefs.getString('user_image_url_$username');
    final profileImagePath = prefs.getString('user_image_path_$username');

    String joinDate = 'Januari 2024';
    if (joinDateIso != null) {
      final date = DateTime.parse(joinDateIso);
      joinDate = '${_getMonthName(date.month)} ${date.year}';
    }

    Uint8List? imageBytes;
    if (profileImagePath != null) {
      final file = File(profileImagePath);
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
      _profileImageUrl = profileImageUrl;
      _profileImageBytes = imageBytes;
    });
    _usernameController.text = _username;
    _emailController.text = _email;
    _phoneController.text = _phone;
    _addressController.text = _address;
  }

  Future<void> _saveProfile() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
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

      // Handle image upload if a new image was selected
      if (_profileImagePath != null) {
        // Delete old image if exists
        if (_profileImageUrl != null) {
          await _imageUploadService.deleteOldProfileImage(_profileImageUrl);
        }

        // Upload new image to Firebase Storage
        final newImageUrl = await _imageUploadService.uploadProfileImage(
          _profileImageBytes!,
        );
        if (newImageUrl != null) {
          await prefs.setString(
            'user_image_url_${_usernameController.text}',
            newImageUrl,
          );
          _profileImageUrl = newImageUrl;
        }

        // Save image to local storage
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'profile_${_usernameController.text}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = path.join(directory.path, fileName);
        final file = File(filePath);
        await file.writeAsBytes(_profileImageBytes!);

        // Save file path to SharedPreferences
        await prefs.setString(
          'user_image_path_${_usernameController.text}',
          filePath,
        );
      }

      setState(() {
        _username = _usernameController.text;
        _email = _emailController.text;
        _phone = _phoneController.text;
        _address = _addressController.text;
        _isEditing = false; // keluar dari mode edit
      });

      // Close loading
      if (context.mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sudah berhasil disimpan', textAlign: TextAlign.center),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading
      if (context.mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving profile: $e',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _profileImagePath = picked.path;
          _profileImageBytes = bytes;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e', textAlign: TextAlign.center),
        ),
      );
    }
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
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => context.go('/settings'),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Profil',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check_circle : Icons.edit,
              color: Theme.of(context).colorScheme.primary,
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
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FOTO PROFIL
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
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
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
                                    );
                                  },
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
                        ).colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 40),

              // DATA PROFIL
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_isEditing) {
                              _saveProfile();
                            } else {
                              setState(() => _isEditing = true);
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: Text(
                            _isEditing ? 'Simpan Perubahan' : 'Edit Profile',
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: _showChangePasswordDialog,
                          icon: const Icon(Icons.lock),
                          label: const Text('Ubah Password'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2.0),
                    ),
                    isDense: true,
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
                    style: const TextStyle(fontSize: 15),
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

  void _showChangePasswordDialog() {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    bool _isOldPasswordVisible = false;
    bool _isNewPasswordVisible = false;
    bool _isConfirmPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ubah Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: !_isOldPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password Lama',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOldPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isOldPasswordVisible = !_isOldPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: !_isNewPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Konfirmasi password tidak cocok',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'User tidak ditemukan',
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Re-authenticate with old password
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: oldPasswordController.text,
                  );
                  await user.reauthenticateWithCredential(credential);

                  // Update password in Firebase
                  await user.updatePassword(newPasswordController.text);

                  // Update local SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                    'user_password_$_username',
                    newPasswordController.text,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Password berhasil diubah',
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                } on FirebaseAuthException catch (e) {
                  String message = 'Terjadi kesalahan.';
                  if (e.code == 'wrong-password') {
                    message = 'Password lama salah';
                  } else if (e.code == 'weak-password') {
                    message = 'Password baru terlalu lemah';
                  } else if (e.code == 'requires-recent-login') {
                    message = 'Sesi login telah berakhir, silakan login ulang';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message, textAlign: TextAlign.center),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e', textAlign: TextAlign.center),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Ubah'),
            ),
          ],
        ),
      ),
    );
  }
}
