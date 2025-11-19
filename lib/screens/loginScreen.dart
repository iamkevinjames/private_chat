// // login_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homeScreen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Email & Password required');
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) {
        showMessage('Login failed — no user returned');
        setState(() => isLoading = false);
        return;
      }

      // Apply any pending profile saved at registration time
      await _applyPendingProfile(user.id);

      // Optionally ensure a minimal app_users row exists (if you disabled trigger)
      // final check = await supabase.from('app_users').select('id').eq('userId', user.id).maybeSingle();
      // if (check == null) { ... upsert ... }

      showMessage('Login successful!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(userId: user.id)),
      );
    } catch (e) {
      showMessage('Login error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _applyPendingProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getString('pending_profile');
    if (pending == null) return;

    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(pending) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to parse pending profile: $e');
      return;
    }

    try {
      await supabase
          .from('app_users')
          .upsert({
            'userId': userId,
            'name': payload['name'] ?? '',
            'email': payload['email'] ?? '',
            'username': payload['username'] ?? '',
            'phone': payload['phone'] ?? '',
            'website': payload['website'] ?? '',
          }, onConflict: 'userId')
          .select()
          .maybeSingle();

      // clear pending profile after successful upsert
      prefs.remove('pending_profile');
    } catch (e) {
      debugPrint('Failed to upsert pending profile after login: $e');
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Login",
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

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Don't have an account? Register"),
              ),

              const SizedBox(height: 12),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: login,
                      child: const Text("Login"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
