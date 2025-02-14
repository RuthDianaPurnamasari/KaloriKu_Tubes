import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String loginStatusKey = 'loginStatusKey';
  static const String loginTimeKey = 'loginTimeKey';
  static const String usernameKey = 'username';
  static const String tokenKey = 'token';

  /// Memeriksa apakah pengguna sedang login.
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(loginStatusKey) ?? false;
    String? loginTimeString = prefs.getString(loginTimeKey);

    if (isLoggedIn && loginTimeString != null) {
      try {
        DateTime loginTime = DateTime.parse(loginTimeString);
        final Duration timeDifference = DateTime.now().difference(loginTime);

        // Durasi maksimum untuk validasi login
        const Duration maxDuration = Duration(hours: 4);
        if (timeDifference > maxDuration) {
          await logout();
          return false;
        }
        return true;
      } catch (e) {
        debugPrint('Error parsing DateTime: $e');
        await logout();
        return false;
      }
    }
    return false;
  }

  /// Login pengguna dan menyimpan status login.
  static Future<void> login(String username, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginStatusKey, true);
    await prefs.setString(loginTimeKey, DateTime.now().toString());
    await prefs.setString(usernameKey, username);
    await prefs.setString('token', token);
  }

  /// Mengambil token pengguna yang sedang login.
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  /// Logout pengguna dan menghapus data terkait login.
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(loginStatusKey);
    prefs.remove(loginTimeKey);
    prefs.remove(usernameKey);
    prefs.remove('token');
  }
}