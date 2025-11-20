import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static const String url = 'https://jsonplaceholder.typicode.com/users';
  final supabase = Supabase.instance.client;

  // 🔒 In-memory cache
  static final Map<int, UserDetails> _userDetailsCache = {};

  Future<List<Users>> fetchUsers() async {
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

  Future<UserDetails> fetchUser(String id) async {
    if (_userDetailsCache.containsKey(id)) {
      return _userDetailsCache[id]!;
    }
    print('id di ${id.runtimeType}');
    try {
      final data = await supabase
          .from('app_users')
          .select('*, address!left(city, street, zipcode, suite)')
          .eq('userId', id)
          .maybeSingle();

      print('Raw user data: $data');
      if (data == null) {
        throw Exception('User not found');
      }

      final userDetails = UserDetails.fromJson(Map<String, dynamic>.from(data));

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

  Future<void> applyPendingProfile(String userId) async {
    final supabase = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getString('pending_profile');
    if (pending == null) return;

    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(pending) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to parse pending profile: $e');
      return;
    }

    try {
      await supabase
          .from('app_users')
          .upsert({
            'userId': userId,
            'name': payload['name'] ?? '',
            'email': payload['email'] ?? '',
            'username': payload['username'] ?? '',
            'phone': payload['phone'] ?? '',
            'website': payload['website'] ?? '',
          }, onConflict: 'userId')
          .select()
          .maybeSingle();

      // clear pending profile after successful upsert
      prefs.remove('pending_profile');
    } catch (e) {
      debugPrint('Failed to upsert pending profile after login: $e');
    }
  }
}
