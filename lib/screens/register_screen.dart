// // register_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'loginscreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final websiteController = TextEditingController();

  final supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();
    final website = websiteController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      showMessage("Email, password and username are required");
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await supabase.auth.signUp(email: email, password: password);
      final user = res.user;

      final profilePayload = {
        'name': name.isNotEmpty ? name : email,
        'email': email,
        'username': username,
        'phone': phone,
        'website': website,
      };

      if (user != null) {
        // We have an authenticated user immediately — try to upsert profile now
        try {
          await supabase
              .from('app_users')
              .upsert({
                'userId': user.id,
                'name': name,
                'email': email,
                'username': username,
                'phone': phone,
                'website': website,
              }, onConflict: 'userId')
              .select()
              .maybeSingle();
        } catch (e) {
          debugPrint('Immediate upsert failed: $e');
          // Save locally as fallback
          await _savePendingProfile(profilePayload);
        }

        showMessage("Account created! Please login.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        // Email confirmation flow: save profile locally and instruct user to confirm
        await _savePendingProfile(profilePayload);
        showMessage("Account created! Confirm your email, then login.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      showMessage('Signup error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _savePendingProfile(Map<String, String> profile) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('pending_profile', jsonEncode(profile));
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // avoids overflow when keyboard opens
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Register",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Full name (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username (required)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: websiteController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: "Website (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: register,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Text("Register"),
                          ),
                        ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text("Already have an account? Login"),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
