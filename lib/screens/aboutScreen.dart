import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  final int counter;

  const AboutScreen(this.counter, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "about - " + this.counter.toString(),
              style: TextStyle(fontSize: 24),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ],
      ),
    );
  }
}
