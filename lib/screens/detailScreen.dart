import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:private_chat/local_db/chat_message.dart';
import 'package:private_chat/models/chat_message.dart';
import 'package:private_chat/models/user.dart';
import 'package:private_chat/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailScreen extends StatefulWidget {
  final String name;
  final String id;
  final String? userId;
  final String roomId;

  const DetailScreen({
    super.key,
    required this.name,
    required this.id,
    this.userId,
    required this.roomId,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final msgController = TextEditingController();
  late Future<List<Messages>> messages;
  List<Messages> message = [];
  RealtimeChannel? _channel;

  void sendMessage() async {
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.id.toString(),
      content: msgController.text.trim(),
      timestamp: DateTime.now(),
    );

    await saveMessage(msg, widget.id.toString(), widget.userId ?? '');
    msgController.clear();
  }

  void clearChat() async {
    await clearMessage(widget.id.toString());
  }

  @override
  void initState() {
    super.initState();
    messages = ApiService().fetchMessages(
      widget.userId ?? '',
      widget.id,
      (incomingMessage) => setState(() {
        message = incomingMessage;
      }),
    );
    _channel = listenToMessages(
      roomId: widget.roomId,
      currentUserId: widget.id,
      otherUserId: widget.userId ?? '',
      onMessageReceived: (newMessage) {
        if (!mounted) return; // <-- guard against disposed State
        setState(() {
          message.add(newMessage);
        });
      },
    );
  }

  @override
  void dispose() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
      _channel = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: clearChat, icon: const Icon(Icons.delete)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- MESSAGES LIST ----------------
            Expanded(
              child: (message.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet. Start the conversation!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      itemCount: message.length,
                      itemBuilder: (_, index) {
                        final msg = message[index];
                        // YOU SAID NOT TO EDIT LOGIC → SO KEEPING isMe = true always
                        bool isMe = msg.receiverId == widget.userId;

                        final bubbleColor = isMe
                            ? const Color.fromARGB(255, 114, 220, 120)
                            : Colors.grey.shade200;

                        final textColor = isMe ? Colors.white : Colors.black87;

                        const radius = Radius.circular(16);
                        final bubbleRadius = BorderRadius.only(
                          topLeft: radius,
                          topRight: radius,
                          bottomLeft: !isMe ? radius : const Radius.circular(4),
                          bottomRight: !isMe
                              ? const Radius.circular(4)
                              : radius,
                        );

                        return Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end, // RIGHT SIDE
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: bubbleColor,
                                  borderRadius: bubbleRadius,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(
                                        255,
                                        25,
                                        141,
                                        195,
                                      ).withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      msg.content,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'hh:mm a',
                                          ).format(msg.created_at),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textColor.withOpacity(0.8),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )),
            ),

            // ---------------- INPUT FIELD ----------------
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 8,
                top: 4,
                bottom: 8,
              ),
              child: TextField(
                controller: msgController,
                decoration: InputDecoration(
                  hintText: "Type your message",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
