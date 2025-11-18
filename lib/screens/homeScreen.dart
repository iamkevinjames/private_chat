import 'package:flutter/material.dart';
import 'package:private_chat/screens/aboutScreen.dart';
import 'package:private_chat/screens/loginScreen.dart';
import 'package:private_chat/screens/userScreen.dart';
import 'package:private_chat/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final String? userId;
  const HomeScreen({super.key, this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int counter = 0; // 🔹 This is your state variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Private Chat',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ApiService().signOutUser();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text("Logout"),
            ),
          ],
        ),
        toolbarHeight: 20,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Expanded(child: UserScreen(userId: widget.userId ?? '')),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AboutScreen(counter)),
            );
          }
        },
      ),
    );
  }
}
