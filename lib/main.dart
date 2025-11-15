import 'package:flutter/material.dart';
import 'package:private_chat/screens/homeScreen.dart';
import 'package:private_chat/screens/loginScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// void main() => runApp(MyApp());
Future<void> main() async {
  await Supabase.initialize(
    url: 'https://mfvourenqycssmtavqyi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1mdm91cmVucXljc3NtdGF2cXlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMxOTcwMzksImV4cCI6MjA3ODc3MzAzOX0.i-zjXGrg7xVi-wBaVwgj18UfuycsIM4l_c45-TebFuk',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final bool loggedIn = supabase.auth.currentUser != null;
    return MaterialApp(
      home: loggedIn
          ? HomeScreen(supabase.auth.currentUser!.id ?? '')
          : LoginScreen(),
    );
  }
}
