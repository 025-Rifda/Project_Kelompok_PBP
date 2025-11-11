import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

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
    final profileImage = prefs.getString('user_image_$username');
    final profileImageBytes = prefs.getString('user_image_bytes_$username');

    String joinDate = 'Januari 2024';
    if (joinDateIso != null) {
      final date = DateTime.parse(joinDateIso);
      joinDate = '${_getMonthName(date.month)} ${date.year}';
    }
    setState(() {
      _username = username;
      _email = email;
      _joinDate = joinDate;
      _phone = phone;
      _address = address;
      _profileImagePath = profileImage;
      if (profileImageBytes != null) {
        _profileImageBytes = base64Decode(profileImageBytes);
      }
    });
    _usernameController.text = _username;
    _emailController.text = _email;
    _phoneController.text = _phone;
    _addressController.text = _address;
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
    if (_profileImagePath != null) {
      await prefs.setString(
        'user_image_${_usernameController.text}',
        _profileImagePath!,
      );
      // Save image bytes for cross-platform compatibility
      final file = File(_profileImagePath!);
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      await prefs.setString(
        'user_image_bytes_${_usernameController.text}',
        base64String,
      );
    }

    setState(() {
      _username = _usernameController.text;
      _email = _emailController.text;
      _phone = _phoneController.text;
      _address = _addressController.text;
      _isEditing = false; // keluar dari mode edit
    });
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
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
                    border: Border.all(color: Colors.grey.shade300),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Lama'),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru'),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password Baru',
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
              final prefs = await SharedPreferences.getInstance();
              final storedPassword = prefs.getString(
                'user_password_$_username',
              );
              if (storedPassword == oldPasswordController.text) {
                if (newPasswordController.text ==
                    confirmPasswordController.text) {
                  await prefs.setString(
                    'user_password_$_username',
                    newPasswordController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password berhasil diubah')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Konfirmasi password tidak cocok'),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password lama salah')),
                );
              }
            },
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
  }
}
