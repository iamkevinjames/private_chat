import 'package:flutter/material.dart';
import 'package:private_chat/models/user.dart';
import 'package:private_chat/services/api_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DetailScreen extends StatefulWidget {
  final String name;
  final int id;
  const DetailScreen({super.key, required this.name, required this.id});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<UserDetails> userDetails;

  @override
  void initState() {
    super.initState();
    userDetails = ApiService().fetchUser(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: SingleChildScrollView(
                  child: FutureBuilder<UserDetails>(
                    future: userDetails,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      final data = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.address.street),
                          Text(data.address.city),
                          Text(data.address.zipcode),
                          Text("Phone: ${data.phone}"),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Type your message",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      // send message logic
                      print("Message sent");
                    },
                  ),
                ),
                onSubmitted: (value) {
                  // Handle message submission
                  print("Message submitted: $value");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
