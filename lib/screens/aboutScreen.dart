import 'package:flutter/material.dart';
import 'package:private_chat/models/user.dart';
import 'package:private_chat/screens/loginScreen.dart';
import 'package:private_chat/services/api_service.dart';

class AboutScreen extends StatefulWidget {
  final String? userId;
  const AboutScreen({super.key, this.userId});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late Future<UserDetails> userInfo;

  @override
  void initState() {
    super.initState();
    userInfo = ApiService().fetchUser(widget.userId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<UserDetails>(
          future: userInfo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
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
                          userInfo = ApiService().fetchUser(
                            widget.userId ?? '',
                          );
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 20,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.blueAccent.shade100,
                          child: Text(
                            (user.name.isNotEmpty ? user.name[0] : 'U')
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

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

                        Text(
                          user.username ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),

                        SizedBox(height: 10),

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
                                _infoRow(
                                  Icons.phone,
                                  'Phone',
                                  user.phone ?? 'N/A',
                                ),
                                const Divider(),
                                _infoRow(
                                  Icons.language,
                                  'Website',
                                  user.website ?? 'N/A',
                                ),
                                const Divider(),
                                _infoRow(
                                  Icons.location_city,
                                  'Address',
                                  '${user.address.street}, ${user.address.city}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await ApiService().signOutUser();
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
      ),
    );
  }
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ],
  );
}
