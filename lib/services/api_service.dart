import '../models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static const String url = 'https://jsonplaceholder.typicode.com/users';
  final supabase = Supabase.instance.client;

  // 🔒 In-memory cache
  static final Map<int, UserDetails> _userDetailsCache = {};

  Future<List<Users>> fetchUsers(String? excludeUserId) async {
    try {
      final supa = supabase;

      // Build query
      final query = supa.from('app_users').select('*');

      // If an exclude id was provided, filter it out
      if (excludeUserId != null && excludeUserId.isNotEmpty) {
        // note: column name in your DB is "userId" (camelCase) so we use quotes in SQL policies,
        // but here the supabase client accepts the literal column name:
        query.neq('userId', excludeUserId);
      }

      final data = await query;

      if (data == null) return [];

      final users = (data as List<dynamic>)
          .map<Users>((item) => Users.fromJson(Map<String, dynamic>.from(item)))
          .toList();

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
