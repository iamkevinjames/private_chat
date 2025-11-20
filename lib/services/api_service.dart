import '../models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static const String url = 'https://jsonplaceholder.typicode.com/users';
  final supabase = Supabase.instance.client;

  // 🔒 In-memory cache
  static final Map<int, UserDetails> _userDetailsCache = {};

  Future<List<Users>> fetchUsers(String userId) async {
    try {
      final data = await supabase.from('app_users').select('*');
      final users = data.map<Users>((item) => Users.fromJson(item)).toList();
      return users;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Messages>> fetchMessages(
    senderId,
    receiverId,
    loadMessage,
  ) async {
    try {
      final data = await supabase
          .from('messages')
          .select('*')
          .or(
            'and(senderId.eq.$senderId,receiverId.eq.$receiverId),and(senderId.eq.$receiverId,receiverId.eq.$senderId)',
          )
          .order('created_at', ascending: true);

      final messageDetails = data
          .map<Messages>((item) => Messages.fromJson(item))
          .toList();
      loadMessage(messageDetails);
      return messageDetails;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<UserDetails> fetchUser(int id) async {
    // ✅ Return from cache if available
    if (_userDetailsCache.containsKey(id)) {
      return _userDetailsCache[id]!;
    }

    // 🟡 Otherwise, fetch from API
    try {
      final data = await supabase
          .from('app_users')
          .select('*, address!inner(city, street, zipcode,suite)')
          .eq('id', id)
          .maybeSingle();

      if (data == null) {
        throw Exception('User not found');
      }

      final userDetails = UserDetails.fromJson(Map<String, dynamic>.from(data));

      // ✅ Save to cache
      _userDetailsCache[id] = userDetails;

      return userDetails;
    } catch (e) {
      throw Exception('Failed to load user details: $e');
    }
  }

  Future<void> signOutUser() async {
    try {
      await supabase.auth.signOut();
      _userDetailsCache.clear();
    } catch (e) {
      throw Exception('Failed to load user details: $e');
    }
  }
}
