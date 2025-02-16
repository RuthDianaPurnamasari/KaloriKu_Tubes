// import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
// import 'dart:convert';

class AuthManager {
  static const String loginStatusKey = 'loginStatusKey';
  static const String loginTimeKey = 'loginTimeKey';
  static const String usernameKey = 'username';
  static const String tokenKey = 'token';

  /// Memeriksa apakah pengguna sedang login.
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(loginStatusKey) ?? false;

    if (!isLoggedIn) return false;
    if (!await isTokenValid()) {
      await logout();
      return false;
    }

    return true;
  }

  /// Memeriksa apakah token masih valid.
  static Future<bool> isTokenValid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(tokenKey);
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }

  /// Login pengguna dan menyimpan status login.
  static Future<void> login(String username, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginStatusKey, true);
    await prefs.setString(loginTimeKey, DateTime.now().toString());
    await prefs.setString(usernameKey, username);
    await prefs.setString(tokenKey, token);
  }

  /// Mengambil token pengguna yang sedang login.
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  /// Mengambil username pengguna yang sedang login.
  static Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey);
  }

  /// Logout pengguna dan menghapus data terkait login.
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginStatusKey);
    await prefs.remove(loginTimeKey);
    await prefs.remove(usernameKey);
    await prefs.remove(tokenKey);
  }

  /// Menghapus semua data di SharedPreferences.
  static Future<void> clearAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}