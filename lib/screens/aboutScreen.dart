// avatarImagePath: /mnt/data/0e2c0708-c0c0-4de9-a8e4-0bc9b315e03a.png

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:private_chat/models/user.dart';
import 'package:private_chat/screens/loginScreen.dart';
import 'package:private_chat/screens/homeScreen.dart';
import 'package:private_chat/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final ApiService _api = ApiService();
  late Future<Users?> _futureUser;
  int _selectedIndex = 1; // 0 -> Home, 1 -> About

  @override
  void initState() {
    super.initState();
    _futureUser = _loadCurrentUser();
  }

  Future<Users?> _loadCurrentUser() async {
    final current = Supabase.instance.client.auth.currentUser;
    final currentId = current?.id;
    if (currentId == null) return null;

    final all = await _api.fetchUsers(null);
    for (final u in all) {
      if (u.userId == currentId) return u;
    }
    return null;
  }

  void _onNavTap(int idx) {
    if (idx == _selectedIndex) return;
    setState(() => _selectedIndex = idx);
    if (idx == 0) {
      // go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              HomeScreen(userId: Supabase.instance.client.auth.currentUser?.id),
        ),
      );
    }
    // idx == 1 -> stay on About
  }

  @override
  Widget build(BuildContext context) {
    const double sidePadding = 20;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Me'),
        // no back button as requested
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: FutureBuilder<Users?>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error loading profile:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('User profile not found'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureUser = _loadCurrentUser();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final avatar = CircleAvatar(
            radius: 48,
            backgroundColor: Colors.blueAccent.shade100,
            child: Text(
              (user.name.isNotEmpty ? user.name[0] : 'U').toUpperCase(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: sidePadding,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  avatar,
                  const SizedBox(height: 18),

                  // Big name
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[900],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    user.username ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),

                  const SizedBox(height: 20),

                  // Details card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _infoRow(Icons.email, 'Email', user.email),
                          const Divider(),
                          _infoRow(
                            Icons.person,
                            'Username',
                            user.username ?? 'N/A',
                          ),
                          const Divider(),
                          _infoRow(Icons.phone, 'Phone', user.phone ?? 'N/A'),
                          const Divider(),
                          _infoRow(
                            Icons.language,
                            'Website',
                            user.website ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _api.signOutUser();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Sign out failed: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'About'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
