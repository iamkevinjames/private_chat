import 'package:hive/hive.dart';
import 'package:private_chat/models/chat_message.dart';
import 'package:private_chat/models/user.dart';
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

RealtimeChannel listenToMessages({
  required String roomId,
  required String currentUserId,
  required String otherUserId,
  required Function(Messages) onMessageReceived,
}) {
  final supabase = Supabase.instance.client;

  final channel = supabase.channel('messages-room-$roomId');

  channel.onPostgresChanges(
    event: PostgresChangeEvent.insert,
    schema: 'public',
    table: 'messages',
    callback: (payload) {
      final newMessage = Messages.fromJson(
        Map<String, dynamic>.from(payload.newRecord),
      );
      onMessageReceived(newMessage);
    },
  );

  channel.subscribe();
  return channel; // <-- return the channel reference
}

Future<String> getOrCreateRoom(String user1, String user2) async {
  final supabase = Supabase.instance.client;

  final existing = await supabase
      .from('chat_rooms')
      .select()
      .or(
        'and(user1_id.eq.$user1,user2_id.eq.$user2),' +
            'and(user1_id.eq.$user2,user2_id.eq.$user1)',
      )
      .maybeSingle();

  print("Existing room: $existing");

  if (existing != null) {
    return existing['room_id'];
  }

  final created = await supabase
      .from('chat_rooms')
      .insert({'user1_id': user1, 'user2_id': user2})
      .select()
      .single();

  print("Created new room: $created");

  return created['room_id'];
}
