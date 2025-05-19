import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/services/databse_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logging/logging.dart';

// Auth Service
class AuthService {
  static final _log = Logger('AuthService');
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  final String _authKey = 'auth_user';

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      String? userId;
      if (kIsWeb) {
        userId = html.window.localStorage[_authKey];
      } else {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getString(_authKey);
      }
      if (userId == null) return null;
      return _db.getUserById(userId);
    } catch (e) {
      _log.severe('Error getting current user: $e');
      return null;
    }
  }

  Future<void> _setCurrentUser(String? userId) async {
    try {
      if (userId == null) return;
      if (kIsWeb) {
        html.window.localStorage[_authKey] = userId;
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_authKey, userId);
      }
    } catch (e) {
      _log.severe('Error setting current user: $e');
    }
  }

  Future<void> logout() async {
    try {
      if (kIsWeb) {
        html.window.localStorage.remove(_authKey);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_authKey);
      }
    } catch (e) {
      _log.severe('Error during logout: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  Future<Map<String, dynamic>?> signUp(
      String name, String email, String password) async {
    final existingUser = await _db.getUserByEmail(email);
    if (existingUser != null) return null;

    final user = {
      'id': const Uuid().v4(),
      'name': name,
      'email': email,
      'password': password, // In a real app, this should be hashed
      'profilePicture': null,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _db.addUser(user);
    await _setCurrentUser(user['id']);
    return user;
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final user = await _db.getUserByEmail(email);
    if (user == null || user['password'] != password) return null;

    await _setCurrentUser(user['id']);
    return user;
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser == null) return false;

      final updatedUser = {
        ...currentUser,
        ...userData,
      };

      await _db.updateUser(updatedUser);
      return true;
    } catch (e) {
      return false;
    }
  }
}
