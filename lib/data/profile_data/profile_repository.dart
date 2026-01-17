import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_profile.dart';







class ProfileRepository {
  // v2 per non rompere eventuali salvataggi vecchi
  static const String _kProfileJsonKey = 'mw_user_profile_v2';

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfileJsonKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      return UserProfile.fromJson(map.cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(profile.toJson());
    await prefs.setString(_kProfileJsonKey, raw);
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kProfileJsonKey);
  }
}
