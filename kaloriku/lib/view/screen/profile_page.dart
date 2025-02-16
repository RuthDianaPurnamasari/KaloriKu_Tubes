import 'package:flutter/material.dart';
import 'package:kaloriku/services/auth_manager.dart';
import 'package:kaloriku/view/screen/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _ProfileCard(
                  name: 'Nida Sakina Aulia',
                  npm: '714220040',
                  icon: Icons.person,
                ),
                _ProfileCard(
                  name: 'Ruth Diana Purnamasari Sagala',
                  npm: '714220042',
                  icon: Icons.person,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildProfileOption(
            Icons.logout,
            "Logout",
            () => _showLogoutConfirmationDialog(context),
          ),
        ],
      ),
    );
  }

  // 🔹 Fungsi untuk menampilkan dialog logout
  static void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Anda yakin ingin logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                await AuthManager.logout();
                Navigator.pushAndRemoveUntil(
                  dialogContext,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Widget untuk membuat opsi profile seperti "Logout"
  static Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String npm;
  final IconData icon;

  const _ProfileCard({
    required this.name,
    required this.npm,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: Icon(icon, size: 50, color: Colors.blueAccent),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Text(
          'D4 Teknik Informatika',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        Text(
          'NPM $npm',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
