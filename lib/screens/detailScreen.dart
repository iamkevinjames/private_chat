import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:private_chat/local_db/chat_message.dart';
import 'package:private_chat/models/chat_message.dart';
import 'package:private_chat/models/user.dart';
import 'package:private_chat/services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final String name;
  final int id;
  final String? userId;
  const DetailScreen({
    super.key,
    required this.name,
    required this.id,
    this.userId,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final msgController = TextEditingController();

  void sendMessage() async {
    print('Sending message from userId: ${widget.id}');
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.id.toString(), // from Supabase session
      content: msgController.text.trim(),
      timestamp: DateTime.now(),
    );

    await saveMessage(msg, widget.id.toString());
    msgController.clear();
  }

  void clearChat() async {
    await clearMessage(widget.id.toString());
  }

  @override
  void initState() {
    super.initState();
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
        actions: [IconButton(onPressed: (clearChat), icon: Icon(Icons.delete))],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded(
            //   child: Padding(
            //     padding: EdgeInsetsGeometry.symmetric(
            //       horizontal: 12,
            //       vertical: 4,
            //     ),
            //     child: SingleChildScrollView(
            // child: FutureBuilder<UserDetails>(
            //   future: userDetails,
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return Center(child: CircularProgressIndicator());
            //     }
            //     if (snapshot.hasError) {
            //       return Center(child: Text("Error: ${snapshot.error}"));
            //     }

            //     final data = snapshot.data!;
            //     return Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(data.address.street),
            //         Text(data.address.city),
            //         Text(data.address.zipcode),
            //         Text("Phone: ${data.phone}"),
            //       ],
            //     );
            //   },
            // ),
            //     ),
            //   ),
            // ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<ChatMessage>('messages').listenable(),
                builder: (context, Box<ChatMessage> box, _) {
                  var messages = box.values
                      .where((m) => m.senderId == widget.id.toString())
                      .toList();
                  if (messages.isEmpty) {
                    return Center(
                      child: Text("No messages yet. Start the conversation!"),
                    );
                  }
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      final msg = messages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1),
                            child: ListTile(
                              title: Text(msg.content),
                              subtitle: Text(
                                DateFormat('hh:mm a').format(msg.timestamp),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
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
                    onPressed: () => sendMessage(),
                  ),
                ),
                controller: msgController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
