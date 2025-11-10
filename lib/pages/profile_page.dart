import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/sidebar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  String _username = 'Pengguna';
  String _email = 'pengguna@example.com';
  String _favoriteAnime = 'One Piece, Naruto';

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _favoriteController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _favoriteController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Pengguna';
      _email = prefs.getString('email') ?? 'pengguna@example.com';
      _favoriteAnime = prefs.getString('favorite_anime') ?? 'One Piece, Naruto';
    });
    _usernameController.text = _username;
    _emailController.text = _email;
    _favoriteController.text = _favoriteAnime;
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('favorite_anime', _favoriteController.text);
    setState(() {
      _username = _usernameController.text;
      _email = _emailController.text;
      _favoriteAnime = _favoriteController.text;
      _isEditing = false; // keluar dari mode edit
    });
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
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
            onPressed: () => context.go('/settings'),
          ),
          Text(
            'Profil',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onPrimary),
            ),
            const SizedBox(height: 20),
            Text(
              _username,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Penggemar Anime',
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6), fontSize: 16),
            ),
            const SizedBox(height: 30),
            _buildProfileItem(
              'Nama',
              _usernameController,
              editable: _isEditing,
            ),
            _buildProfileItem('Email', _emailController, editable: _isEditing),
            _buildProfileItem('Bergabung Sejak', 'Januari 2024'),
            _buildProfileItem(
              'Anime Favorit',
              _favoriteController,
              editable: _isEditing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    String label,
    dynamic value, {
    bool editable = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: editable
            ? TextField(
                controller: value,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
              )
            : Text(value is TextEditingController ? value.text : value),
      ),
    );
  }
}
