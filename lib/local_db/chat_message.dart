import 'package:hive/hive.dart';
import 'package:private_chat/models/chat_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<ChatMessage> loadMessages() {
  var box = Hive.box<ChatMessage>('messages');
  return box.values.toList();
}

Future<void> saveMessage(ChatMessage message, String id, String userId) async {
  var box = Hive.box<ChatMessage>('messages');
  final supabase = Supabase.instance.client;
  await supabase.from('messages').insert({
    'receiverId': id,
    'senderId': userId,
    'content': message.content,
    // 'timestamp': message.timestamp.toIso8601String(),
  });
  await box.put(message.id, message);
}

Future<void> clearMessage(String id) async {
  var box = Hive.box<ChatMessage>('messages');

  final keysToDelete = box.keys.where((key) {
    final msg = box.get(key);
    return msg?.senderId == id;
  }).toList();

  await box.deleteAll(keysToDelete);
}
