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
  int _currentIndex = 0;

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
          ],
        ),
        toolbarHeight: 20,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Expanded(child: UserScreen(userId: widget.userId ?? '')),
            ],
          ),
          AboutScreen(userId: widget.userId),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            activeIcon: Icon(Icons.home_filled),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
            activeIcon: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}
