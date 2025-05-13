import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logging/logging.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:splitwise/currency.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeNotifier().loadThemeMode();
  await CurrencyNotifier().loadCurrency();
  runApp(const SplitWiseApp());
}

// Theme Notifier
class ThemeNotifier extends ChangeNotifier {
  static final ThemeNotifier _instance = ThemeNotifier._internal();
  factory ThemeNotifier() => _instance;
  ThemeNotifier._internal();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    if (kIsWeb) {
      html.window.localStorage['themeMode'] =
          mode == ThemeMode.dark ? 'dark' : 'light';
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
    }
  }

  Future<void> loadThemeMode() async {
    if (kIsWeb) {
      final storage = html.window.localStorage;
      if (storage.containsKey('themeMode')) {
        _themeMode =
            storage['themeMode'] == 'dark' ? ThemeMode.dark : ThemeMode.light;
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode');
      if (isDark != null) {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      }
    }
    notifyListeners();
  }
}

// Currency Notifier
class CurrencyNotifier extends ChangeNotifier {
  static final CurrencyNotifier _instance = CurrencyNotifier._internal();
  factory CurrencyNotifier() => _instance;
  CurrencyNotifier._internal();

  Currency _currency = currencies[0];
  Currency get currency => _currency;

  Future<void> setCurrency(Currency currency) async {
    _currency = currency;
    notifyListeners();

    if (kIsWeb) {
      html.window.localStorage['currency'] = currency.code;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', currency.code);
    }
  }

  Future<void> loadCurrency() async {
    if (kIsWeb) {
      final storage = html.window.localStorage;
      final currencyCode = storage['currency'] ?? 'PKR';
      _currency = currencies.firstWhere(
        (c) => c.code == currencyCode,
        orElse: () => currencies[0],
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      final currencyCode = prefs.getString('currency') ?? 'PKR';
      _currency = currencies.firstWhere(
        (c) => c.code == currencyCode,
        orElse: () => currencies[0],
      );
    }
    notifyListeners();
  }
}

class SplitWiseApp extends StatelessWidget {
  const SplitWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeNotifier(),
      builder: (context, child) {
        return MaterialApp(
          title: 'Splitwise',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF1CC29F),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1CC29F),
              primary: const Color(0xFF1CC29F),
              secondary: const Color(0xFF8A2BE2),
              background: Colors.white,
            ),
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1CC29F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1CC29F),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF1CC29F), width: 2),
              ),
            ),
          ),
          darkTheme: ThemeData(
            primaryTextTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white),
            ),
            primaryColor: const Color(0xFF1CC29F),
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF1CC29F),
              primary: const Color(0xFF1CC29F),
              secondary: const Color(0xFF8A2BE2),
              background: const Color(0xFF121212),
            ),
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1CC29F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1CC29F),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF1CC29F), width: 2),
              ),
            ),
            cardColor: const Color(0xFF1E1E1E),
            dividerColor: Colors.white24,
          ),
          themeMode: ThemeNotifier().themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}

// Database Service
class DatabaseService {
  static final _log = Logger('DatabaseService');
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final String _usersFileName = 'users.json';
  final String _groupsFileName = 'groups.json';
  final String _expensesFileName = 'expenses.json';
  final String _activitiesFileName = 'activities.json';
  final String _settlementsFileName = 'settlements.json';

  Future<String> get _localPath async {
    if (kIsWeb) {
      return ''; // Web doesn't need a path
    }
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> _readWebFile(String fileName) async {
    final storage = html.window.localStorage;
    return storage[fileName] ?? '[]';
  }

  Future<void> _writeWebFile(String fileName, String contents) async {
    final storage = html.window.localStorage;
    storage[fileName] = contents;
  }

  Future<void> _createFileIfNotExists(String fileName) async {
    try {
      _log.info('Creating file if not exists: $fileName');
      if (kIsWeb) {
        final storage = html.window.localStorage;
        if (!storage.containsKey(fileName)) {
          _log.info('File does not exist in web storage, creating: $fileName');
          storage[fileName] = '[]';
        }
        _log.info('File exists in web storage: $fileName');
        return;
      }

      final file = await _getFile(fileName);
      if (!await file.exists()) {
        _log.info('File does not exist, creating: $fileName');
        await file.create();
        await file.writeAsString('[]');
        _log.info('File created and initialized: $fileName');
      } else {
        _log.info('File already exists: $fileName');
      }
    } catch (e) {
      _log.severe('Error creating file $fileName: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _readJsonFile(String fileName) async {
    try {
      String contents;
      if (kIsWeb) {
        contents = await _readWebFile(fileName);
      } else {
        final file = await _getFile(fileName);
        contents = await file.readAsString();
      }
      return List<Map<String, dynamic>>.from(jsonDecode(contents));
    } catch (e) {
      _log.severe('Error reading file $fileName: $e');
      return [];
    }
  }

  Future<void> _writeJsonFile(
      String fileName, List<Map<String, dynamic>> data) async {
    try {
      final contents = jsonEncode(data);
      if (kIsWeb) {
        await _writeWebFile(fileName, contents);
      } else {
        final file = await _getFile(fileName);
        await file.writeAsString(contents);
      }
    } catch (e) {
      _log.severe('Error writing file $fileName: $e');
      rethrow;
    }
  }

  Future<File> _getFile(String fileName) async {
    if (kIsWeb)
      throw UnsupportedError('Web platform does not support File operations');
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<void> initializeDatabase() async {
    try {
      _log.info('Starting database initialization...');
      await _createFileIfNotExists(_usersFileName);
      await _createFileIfNotExists(_groupsFileName);
      await _createFileIfNotExists(_expensesFileName);
      await _createFileIfNotExists(_activitiesFileName);
      await _createFileIfNotExists(_settlementsFileName);
      _log.info('Database initialization completed');
    } catch (e) {
      _log.severe('Error during database initialization: $e');
      rethrow;
    }
  }

  // User Methods
  Future<List<Map<String, dynamic>>> getUsers() async {
    return _readJsonFile(_usersFileName);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final users = await getUsers();
    try {
      return users.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final users = await getUsers();
    try {
      return users.firstWhere((user) => user['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addUser(Map<String, dynamic> user) async {
    final users = await getUsers();
    users.add(user);
    await _writeJsonFile(_usersFileName, users);
  }

  Future<void> updateUser(Map<String, dynamic> updatedUser) async {
    final users = await getUsers();
    final index = users.indexWhere((user) => user['id'] == updatedUser['id']);
    if (index != -1) {
      users[index] = updatedUser;
      await _writeJsonFile(_usersFileName, users);
    }
  }

  Future<void> addFriend(String userId, String friendId) async {
    final users = await getUsers();
    final userIndex = users.indexWhere((user) => user['id'] == userId);
    final friendIndex = users.indexWhere((user) => user['id'] == friendId);

    if (userIndex != -1 && friendIndex != -1) {
      // Initialize friends list if it doesn't exist
      users[userIndex]['friends'] ??= [];
      users[friendIndex]['friends'] ??= [];

      // Add friend to user's friends list if not already there
      if (!(users[userIndex]['friends'] as List).contains(friendId)) {
        (users[userIndex]['friends'] as List).add(friendId);
      }

      // Add user to friend's friends list if not already there
      if (!(users[friendIndex]['friends'] as List).contains(userId)) {
        (users[friendIndex]['friends'] as List).add(userId);
      }

      await _writeJsonFile(_usersFileName, users);
    }
  }

  Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    final user = await getUserById(userId);
    if (user == null || user['friends'] == null) return [];

    final friendIds = List<String>.from(user['friends']);
    final users = await getUsers();

    return users.where((u) => friendIds.contains(u['id'])).toList();
  }

  // Group Methods
  Future<List<Map<String, dynamic>>> getGroups() async {
    return _readJsonFile(_groupsFileName);
  }

  Future<List<Map<String, dynamic>>> getGroupsByUserId(String userId) async {
    final groups = await getGroups();
    return groups
        .where((group) =>
            (group['members'] as List).any((member) => member['id'] == userId))
        .toList();
  }

  Future<Map<String, dynamic>?> getGroupById(String id) async {
    final groups = await getGroups();
    try {
      return groups.firstWhere((group) => group['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addGroup(Map<String, dynamic> group) async {
    final groups = await getGroups();
    groups.add(group);
    await _writeJsonFile(_groupsFileName, groups);
  }

  Future<void> updateGroup(Map<String, dynamic> updatedGroup) async {
    final groups = await getGroups();
    final index =
        groups.indexWhere((group) => group['id'] == updatedGroup['id']);
    if (index != -1) {
      groups[index] = updatedGroup;
      await _writeJsonFile(_groupsFileName, groups);
    }
  }

  // Expense Methods
  Future<List<Map<String, dynamic>>> getExpenses() async {
    return _readJsonFile(_expensesFileName);
  }

  Future<List<Map<String, dynamic>>> getExpensesByGroupId(
      String groupId) async {
    final expenses = await getExpenses();
    return expenses.where((expense) => expense['groupId'] == groupId).toList();
  }

  Future<List<Map<String, dynamic>>> getExpensesByUserId(String userId) async {
    final expenses = await getExpenses();
    return expenses
        .where((expense) =>
            expense['paidBy'] == userId ||
            (expense['splitWith'] as List)
                .any((split) => split['userId'] == userId))
        .toList();
  }

  Future<void> addExpense(Map<String, dynamic> expense) async {
    final expenses = await getExpenses();
    expenses.add(expense);
    await _writeJsonFile(_expensesFileName, expenses);
  }

  Future<void> updateExpense(Map<String, dynamic> updatedExpense) async {
    final expenses = await getExpenses();
    final index =
        expenses.indexWhere((expense) => expense['id'] == updatedExpense['id']);
    if (index != -1) {
      expenses[index] = updatedExpense;
      await _writeJsonFile(_expensesFileName, expenses);
    }
  }

  // Activity Methods
  Future<List<Map<String, dynamic>>> getActivities() async {
    return _readJsonFile(_activitiesFileName);
  }

  Future<List<Map<String, dynamic>>> getActivitiesByUserId(
      String userId) async {
    final activities = await getActivities();
    return activities
        .where((activity) =>
            activity['userId'] == userId || activity['relatedUserId'] == userId)
        .toList()
      ..sort((a, b) => DateTime.parse(b['timestamp'])
          .compareTo(DateTime.parse(a['timestamp'])));
  }

  Future<void> addActivity(Map<String, dynamic> activity) async {
    final activities = await getActivities();
    activities.add(activity);
    await _writeJsonFile(_activitiesFileName, activities);
  }

  // Settlement Methods
  Future<List<Map<String, dynamic>>> getSettlements() async {
    return _readJsonFile(_settlementsFileName);
  }

  Future<List<Map<String, dynamic>>> getSettlementsByUserId(
      String userId) async {
    final settlements = await getSettlements();
    return settlements
        .where((settlement) =>
            settlement['payerId'] == userId || settlement['payeeId'] == userId)
        .toList();
  }

  Future<void> addSettlement(Map<String, dynamic> settlement) async {
    final settlements = await getSettlements();
    settlements.add(settlement);
    await _writeJsonFile(_settlementsFileName, settlements);
  }

  // Balance Calculation
  Future<Map<String, dynamic>> calculateBalances(String userId) async {
    final expenses = await getExpenses();
    final settlements = await getSettlements();
    final users = await getUsers();

    Map<String, double> balances = {};

    // Initialize balances for all users
    for (var user in users) {
      if (user['id'] != userId) {
        balances[user['id']] = 0;
      }
    }

    // Calculate from expenses
    for (var expense in expenses) {
      if (expense['paidBy'] == userId) {
        // Current user paid for others
        for (var split in expense['splitWith']) {
          if (split['userId'] != userId) {
            balances[split['userId']] =
                (balances[split['userId']] ?? 0) + split['amount'];
          }
        }
      } else {
        // Others paid and current user is involved
        for (var split in expense['splitWith']) {
          if (split['userId'] == userId) {
            balances[expense['paidBy']] =
                (balances[expense['paidBy']] ?? 0) - split['amount'];
          }
        }
      }
    }

    // Adjust with settlements
    for (var settlement in settlements) {
      if (settlement['payerId'] == userId) {
        // User paid someone
        balances[settlement['payeeId']] =
            (balances[settlement['payeeId']] ?? 0) - settlement['amount'];
      } else if (settlement['payeeId'] == userId) {
        // User received payment
        balances[settlement['payerId']] =
            (balances[settlement['payerId']] ?? 0) + settlement['amount'];
      }
    }

    // Prepare result
    double totalOwed = 0;
    double totalOwe = 0;
    List<Map<String, dynamic>> userBalances = [];

    for (var entry in balances.entries) {
      if (entry.value > 0) {
        totalOwed += entry.value;
        final user = await getUserById(entry.key);
        userBalances.add({
          'userId': entry.key,
          'name': user?['name'] ?? 'Unknown',
          'amount': entry.value,
          'type': 'owed'
        });
      } else if (entry.value < 0) {
        totalOwe += entry.value.abs();
        final user = await getUserById(entry.key);
        userBalances.add({
          'userId': entry.key,
          'name': user?['name'] ?? 'Unknown',
          'amount': entry.value.abs(),
          'type': 'owe'
        });
      } else {
        final user = await getUserById(entry.key);
        userBalances.add({
          'userId': entry.key,
          'name': user?['name'] ?? 'Unknown',
          'amount': 0,
          'type': 'settled'
        });
      }
    }

    return {
      'totalOwed': totalOwed,
      'totalOwe': totalOwe,
      'netBalance': totalOwed - totalOwe,
      'userBalances': userBalances,
    };
  }

  // Simplify Debts Algorithm
  Future<List<Map<String, dynamic>>> simplifyDebts(String groupId) async {
    final group = await getGroupById(groupId);
    if (group == null) return [];

    final members = List<Map<String, dynamic>>.from(group['members']);
    final expenses = await getExpensesByGroupId(groupId);
    final settlements = await getSettlements();

    // Calculate net balance for each member
    Map<String, double> balances = {};
    for (var member in members) {
      balances[member['id']] = 0;
    }

    // Process expenses
    for (var expense in expenses) {
      final paidBy = expense['paidBy'];
      balances[paidBy] = (balances[paidBy] ?? 0) + expense['amount'];

      for (var split in expense['splitWith']) {
        final userId = split['userId'];
        balances[userId] = (balances[userId] ?? 0) - split['amount'];
      }
    }

    // Process settlements
    for (var settlement in settlements) {
      if (settlement['groupId'] == groupId) {
        balances[settlement['payerId']] =
            (balances[settlement['payerId']] ?? 0) - settlement['amount'];
        balances[settlement['payeeId']] =
            (balances[settlement['payeeId']] ?? 0) + settlement['amount'];
      }
    }

    // Separate debtors and creditors
    List<Map<String, dynamic>> debtors = [];
    List<Map<String, dynamic>> creditors = [];

    for (var entry in balances.entries) {
      if (entry.value < 0) {
        debtors.add({'id': entry.key, 'amount': entry.value.abs()});
      } else if (entry.value > 0) {
        creditors.add({'id': entry.key, 'amount': entry.value});
      }
    }

    // Sort by amount (descending)
    debtors.sort((a, b) => b['amount'].compareTo(a['amount']));
    creditors.sort((a, b) => b['amount'].compareTo(a['amount']));

    // Generate simplified transactions
    List<Map<String, dynamic>> transactions = [];

    while (debtors.isNotEmpty && creditors.isNotEmpty) {
      final debtor = debtors.first;
      final creditor = creditors.first;

      final amount = min((debtor['amount'] as num).toDouble(),
          (creditor['amount'] as num).toDouble());

      if (amount > 0) {
        final debtorUser = await getUserById(debtor['id']);
        final creditorUser = await getUserById(creditor['id']);

        transactions.add({
          'from': {
            'id': debtor['id'],
            'name': debtorUser?['name'] ?? 'Unknown'
          },
          'to': {
            'id': creditor['id'],
            'name': creditorUser?['name'] ?? 'Unknown'
          },
          'amount': amount
        });

        debtor['amount'] -= amount;
        creditor['amount'] -= amount;
      }

      if (debtor['amount'] < 0.01) debtors.removeAt(0);
      if (creditor['amount'] < 0.01) creditors.removeAt(0);
    }

    return transactions;
  }

  // Delete Methods
  Future<void> removeFriend(String userId, String friendId) async {
    final users = await getUsers();
    final userIndex = users.indexWhere((user) => user['id'] == userId);
    final friendIndex = users.indexWhere((user) => user['id'] == friendId);

    if (userIndex != -1 && friendIndex != -1) {
      // Remove friend from user's friends list
      users[userIndex]['friends'] ??= [];
      users[userIndex]['friends'].remove(friendId);

      // Remove user from friend's friends list
      users[friendIndex]['friends'] ??= [];
      users[friendIndex]['friends'].remove(userId);

      await _writeJsonFile(_usersFileName, users);
    }
  }

  Future<void> deleteGroup(String groupId) async {
    // Delete group
    final groups = await getGroups();
    groups.removeWhere((group) => group['id'] == groupId);
    await _writeJsonFile(_groupsFileName, groups);

    // Delete associated expenses
    final expenses = await getExpenses();
    expenses.removeWhere((expense) => expense['groupId'] == groupId);
    await _writeJsonFile(_expensesFileName, expenses);
  }

  Future<void> deleteExpense(String expenseId) async {
    final expenses = await getExpenses();
    final expenseIndex =
        expenses.indexWhere((expense) => expense['id'] == expenseId);

    if (expenseIndex != -1) {
      final expense = expenses[expenseIndex];
      final groupId = expense['groupId'];
      final group = await getGroupById(groupId);

      if (group != null) {
        // Reverse the balances
        final members = List<Map<String, dynamic>>.from(group['members']);
        final splitWith = List<Map<String, dynamic>>.from(expense['splitWith']);
        final amount = expense['amount'];
        final paidBy = expense['paidBy'];

        for (var i = 0; i < members.length; i++) {
          final member = members[i];
          final split = splitWith.firstWhere(
            (s) => s['userId'] == member['id'],
            orElse: () => {'amount': 0.0},
          );

          if (member['id'] == paidBy) {
            // Reverse payer's balance
            member['balance'] =
                (member['balance'] ?? 0.0) - (amount - split['amount']);
          } else {
            // Reverse other members' balances
            member['balance'] = (member['balance'] ?? 0.0) + split['amount'];
          }
        }

        // Update group with reversed balances
        final updatedGroup = {
          ...group,
          'members': members,
        };
        await updateGroup(updatedGroup);
      }

      // Remove the expense
      expenses.removeAt(expenseIndex);
      await _writeJsonFile(_expensesFileName, expenses);
    }
  }

  Future<String?> saveProfileImage(String userId, dynamic imageFile) async {
    try {
      if (kIsWeb) {
        // For web, convert image to base64 and store in shared location
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        final storage = html.window.localStorage;
        const key = 'profile_images';

        // Get existing profile images map or create new one
        Map<String, dynamic> profileImages = {};
        if (storage.containsKey(key)) {
          profileImages = Map<String, dynamic>.from(jsonDecode(storage[key]!));
        }

        // Add/update this user's profile image
        profileImages[userId] = base64Image;
        storage[key] = jsonEncode(profileImages);

        return userId; // Return userId as the key
      } else {
        // For mobile, save to app directory
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'profile_image_$userId.jpg';
        final savedImage =
            await (imageFile as File).copy('${directory.path}/$fileName');
        return savedImage.path;
      }
    } catch (e) {
      _log.severe('Error saving profile image: $e');
      return null;
    }
  }

  Future<dynamic> getProfileImage(String userId, String? imagePath) async {
    try {
      if (kIsWeb) {
        final storage = html.window.localStorage;
        const key = 'profile_images';

        if (storage.containsKey(key)) {
          final profileImages =
              Map<String, dynamic>.from(jsonDecode(storage[key]!));

          if (profileImages.containsKey(userId)) {
            return profileImages[userId];
          }
        }
        return null;
      } else if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          return file;
        }
      }
      return null;
    } catch (e) {
      _log.severe('Error loading profile image: $e');
      return null;
    }
  }
}

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

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static final _log = Logger('SplashScreen');

  @override
  void initState() {
    super.initState();
    _log.info('Starting initialization...');
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _log.info('Initializing database...');
      await DatabaseService().initializeDatabase();
      _log.info('Database initialized');

      _log.info('Checking login status...');
      final isLoggedIn = await AuthService().isLoggedIn();
      _log.info('Login status checked: $isLoggedIn');

      if (mounted) {
        _log.info('Navigating to next screen...');
        if (isLoggedIn) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomePage()),
          );
        }
        _log.info('Navigation completed');
      }
    } catch (e) {
      _log.severe('Error during initialization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _log.info('Building splash screen');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 120, height: 120),
            const SizedBox(height: 24),
            const Text(
              'Splitwise',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color(0xFF1CC29F),
            ),
          ],
        ),
      ),
    );
  }
}

// Welcome Page
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      ClipPath(
                        clipper: DiagonalClipper(part: 1),
                        child: Container(
                          width: 120,
                          height: 120,
                          color: const Color(0xFF1CC29F),
                        ),
                      ),
                      ClipPath(
                        clipper: DiagonalClipper(part: 2),
                        child: Container(
                          width: 120,
                          height: 120,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      Positioned(
                        left: 30,
                        top: 40,
                        child: Text(
                          'S',
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withAlpha(230),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Splitwise',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                // Sign up button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  },
                  child: const Text('Sign up'),
                ),
                const SizedBox(height: 16),
                // Log in button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                  ),
                  child: const Text('Log in'),
                ),
                const SizedBox(height: 24),
                // Terms and privacy
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Terms'),
                    ),
                    const Text('|'),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Privacy Policy'),
                    ),
                    const Text('|'),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Contact us'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  final int part;

  DiagonalClipper({required this.part});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (part == 1) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
      path.close();
    } else if (part == 2) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Sign Up Page
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService().signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (user != null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email already in use')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign up')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: Icon(Icons.visibility),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Sign up'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text('Log in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (user != null) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to log in')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Log in',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Log in'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Forgot password functionality
                    },
                    child: const Text('Forgot your password?'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Home Page with Bottom Navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late Future<Map<String, dynamic>?> _userFuture;
  late Future<Map<String, dynamic>> _balancesFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _userFuture = AuthService().getCurrentUser();
    final user = await _userFuture;
    if (user != null) {
      _balancesFuture = DatabaseService().calculateBalances(user['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load user data'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const WelcomePage()),
                        (route) => false,
                      );
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        final user = snapshot.data!;
        final List<Widget> pages = [
          FriendsTab(userId: user['id']),
          GroupsTab(userId: user['id']),
          AddExpenseTab(userId: user['id']),
          ActivityTab(userId: user['id']),
          AccountTab(user: user),
        ];

        return Scaffold(
          body: pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Friends',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Groups',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle, size: 40),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Activity',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Account',
              ),
            ],
          ),
        );
      },
    );
  }
}

// Friends Tab
class FriendsTab extends StatefulWidget {
  final String userId;

  const FriendsTab({super.key, required this.userId});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  late Future<Map<String, dynamic>> _balancesFuture;
  late Future<List<Map<String, dynamic>>> _friendsFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchError = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _balancesFuture = DatabaseService().calculateBalances(widget.userId);
    _friendsFuture = DatabaseService().getFriends(widget.userId);
  }

  Future<void> _searchAndAddFriend(String email) async {
    setState(() {
      _isSearching = true;
      _searchError = '';
    });

    try {
      final user = await DatabaseService().getUserByEmail(email);

      if (user == null) {
        setState(() {
          _searchError = 'No user found with this email';
        });
        return;
      }

      if (user['id'] == widget.userId) {
        setState(() {
          _searchError = 'You cannot add yourself as a friend';
        });
        return;
      }

      await DatabaseService().addFriend(widget.userId, user['id']);

      setState(() {
        _searchController.clear();
        _loadData();
      });
    } catch (e) {
      setState(() {
        _searchError = 'An error occurred while adding friend';
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<bool?> _removeFriend(Map<String, dynamic> friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text(
            'Are you sure you want to remove ${friend['name']} from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService().removeFriend(widget.userId, friend['id']);
      setState(() {
        _loadData();
      });
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by email',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  _searchAndAddFriend(_searchController.text.trim());
                }
              },
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _searchAndAddFriend(value.trim());
            }
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: _balancesFuture,
          builder: (context, balanceSnapshot) {
            if (balanceSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (balanceSnapshot.hasError) {
              return Center(child: Text('Error: ${balanceSnapshot.error}'));
            }

            final balances = balanceSnapshot.data!;
            final netBalance = balances['netBalance'] as double;
            final userBalances = Map<String, Map<String, dynamic>>.fromEntries(
                (balances['userBalances'] as List)
                    .map((b) => MapEntry(b['userId'], b)));

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _friendsFuture,
              builder: (context, friendsSnapshot) {
                if (friendsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final friends = friendsSnapshot.data ?? [];

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_searchError.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _searchError,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),

                    // Overall balance
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Overall, you are ${netBalance >= 0 ? 'owed' : 'owe'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatCurrency(netBalance),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: netBalance >= 0
                                  ? const Color(0xFF1CC29F)
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    if (friends.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 32),
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No friends yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Search for friends by their email address',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...friends.map((friend) {
                        final balance = userBalances[friend['id']];
                        final isOwed = balance?['type'] == 'owed';
                        final isSettled = balance?['type'] == 'settled';
                        final amount = balance?['amount'] ?? 0.0;

                        return Dismissible(
                          key: Key(friend['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) => _removeFriend(friend),
                          child: ListTile(
                            leading: _buildFriendAvatar(friend),
                            title: Text(
                              friend['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(friend['email']),
                            trailing: isSettled
                                ? const Text('settled up')
                                : Text(
                                    isOwed
                                        ? 'owes you ${formatCurrency(amount)}'
                                        : 'you owe ${formatCurrency(amount)}',
                                    style: TextStyle(
                                      color: isOwed
                                          ? const Color(0xFF1CC29F)
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            onTap: () {
                              // Navigate to friend details
                            },
                          ),
                        );
                      }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFriendAvatar(Map<String, dynamic> friend) {
    return FutureBuilder<dynamic>(
      future: DatabaseService().getProfileImage(
        friend['id'],
        friend['profilePicture'],
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (kIsWeb) {
            return CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: Image.memory(
                  base64Decode(snapshot.data as String),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            return CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: Image.file(
                  snapshot.data as File,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }
        }
        return CircleAvatar(
          backgroundColor: Colors
              .primaries[friend['name'].hashCode % Colors.primaries.length],
          child: Text(
            friend['name'].substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}

// Groups Tab
class GroupsTab extends StatefulWidget {
  final String userId;

  const GroupsTab({super.key, required this.userId});

  @override
  State<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends State<GroupsTab> {
  late Future<List<Map<String, dynamic>>> _groupsFuture;
  late Future<Map<String, dynamic>> _balancesFuture;
  late Future<List<Map<String, dynamic>>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _groupsFuture = DatabaseService().getGroupsByUserId(widget.userId);
    _balancesFuture = DatabaseService().calculateBalances(widget.userId);
    _friendsFuture = DatabaseService().getFriends(widget.userId);
  }

  void _showCreateGroupDialog() async {
    final nameController = TextEditingController();
    final friends = await DatabaseService().getFriends(widget.userId);

    if (friends.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add some friends first before creating a group'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final selectedFriends = <String>{};

    if (mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Create a new group'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group name',
                      hintText: 'e.g., Trip to Murree',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select friends to add:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...friends.map((friend) => CheckboxListTile(
                        title: Text(friend['name']),
                        subtitle: Text(friend['email']),
                        value: selectedFriends.contains(friend['id']),
                        onChanged: (bool? value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedFriends.add(friend['id']);
                            } else {
                              selectedFriends.remove(friend['id']);
                            }
                          });
                        },
                      )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a group name')),
                    );
                    return;
                  }

                  if (selectedFriends.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select at least one friend')),
                    );
                    return;
                  }

                  // Create list of all members including current user
                  final members = [
                    {
                      'id': widget.userId,
                      'balance': 0.0,
                      'role': 'admin',
                    },
                    ...selectedFriends.map((friendId) => {
                          'id': friendId,
                          'balance': 0.0,
                          'role': 'member',
                        }),
                  ];

                  final newGroup = {
                    'id': const Uuid().v4(),
                    'name': name,
                    'icon': null,
                    'createdAt': DateTime.now().toIso8601String(),
                    'createdBy': widget.userId,
                    'members': members,
                    'isSettled': false,
                  };

                  await DatabaseService().addGroup(newGroup);

                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    // Use the parent widget's setState to refresh the groups list
                    setState(() {
                      _loadData();
                    });
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<bool?> _deleteGroup(Map<String, dynamic> group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text(
            'Are you sure you want to delete "${group['name']}"? This will delete all associated expenses and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService().deleteGroup(group['id']);
      setState(() {
        _loadData();
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Search functionality
              },
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                _showCreateGroupDialog();
              },
              child: const Text(
                'Create group',
                style: TextStyle(
                  color: Color(0xFF1CC29F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: _balancesFuture,
          builder: (context, balanceSnapshot) {
            if (balanceSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (balanceSnapshot.hasError) {
              return Center(child: Text('Error: ${balanceSnapshot.error}'));
            }

            final balances = balanceSnapshot.data!;
            final netBalance = balances['netBalance'] as double;

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _groupsFuture,
              builder: (context, groupsSnapshot) {
                if (groupsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (groupsSnapshot.hasError) {
                  return Center(child: Text('Error: ${groupsSnapshot.error}'));
                }

                final groups = groupsSnapshot.data!;
                final settledGroups =
                    groups.where((g) => g['isSettled'] == true).toList();
                final activeGroups =
                    groups.where((g) => g['isSettled'] != true).toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Overall balance
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Overall, you are ${netBalance >= 0 ? 'owed' : 'owe'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatCurrency(netBalance),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: netBalance >= 0
                                  ? const Color(0xFF1CC29F)
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    if (groups.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 32),
                            Icon(
                              Icons.group_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No groups yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create a group with your friends to get started',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showCreateGroupDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Create a group'),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Active groups
                      ...activeGroups.map((group) {
                        final groupBalance =
                            _calculateGroupBalance(group, widget.userId);
                        final isOwed = groupBalance > 0;

                        return Dismissible(
                          key: Key(group['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) => _deleteGroup(group),
                          child: ListTile(
                            leading: group['icon'] != null
                                ? Image.asset(group['icon'],
                                    width: 40, height: 40)
                                : Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.primaries[
                                          group['name'].hashCode %
                                              Colors.primaries.length],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        group['name']
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                            title: Text(
                              group['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${(group['members'] as List).length} members',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            trailing: groupBalance == 0
                                ? const Text('settled up')
                                : Text(
                                    isOwed
                                        ? 'you are owed\n${formatCurrency(groupBalance)}'
                                        : 'you owe\n${formatCurrency(groupBalance)}',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: isOwed
                                          ? const Color(0xFF1CC29F)
                                          : Colors.orange,
                                    ),
                                  ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GroupDetailPage(
                                    groupId: group['id'],
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),

                      if (settledGroups.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Settled groups',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...settledGroups.map((group) => ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    group['name'].substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                group['name'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              subtitle: Text(
                                '${(group['members'] as List).length} members • Settled',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GroupDetailPage(
                                      groupId: group['id'],
                                      userId: widget.userId,
                                    ),
                                  ),
                                );
                              },
                            )),
                      ],
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  double _calculateGroupBalance(Map<String, dynamic> group, String userId) {
    final members = List<Map<String, dynamic>>.from(group['members']);
    final userMember = members.firstWhere((m) => m['id'] == userId,
        orElse: () => {'balance': 0.0});
    return userMember['balance'] ?? 0.0;
  }
}

// Group Detail Page
class GroupDetailPage extends StatefulWidget {
  final String groupId;
  final String userId;

  const GroupDetailPage({
    super.key,
    required this.groupId,
    required this.userId,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  late Future<Map<String, dynamic>?> _groupFuture;
  late Future<List<Map<String, dynamic>>> _expensesFuture;
  late Future<List<Map<String, dynamic>>> _simplifiedDebtsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _groupFuture = DatabaseService().getGroupById(widget.groupId);
    _expensesFuture = DatabaseService().getExpensesByGroupId(widget.groupId);
    _simplifiedDebtsFuture = DatabaseService().simplifyDebts(widget.groupId);
  }

  Future<bool?> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
            'Are you sure you want to delete this group? This will delete all associated expenses and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService().deleteGroup(widget.groupId);
      if (mounted) {
        Navigator.of(context).pop();
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>?>(
          future: _groupFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Text('Group');
            }
            return Text(snapshot.data!['name']);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                await _deleteGroup();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete group', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _groupFuture,
        builder: (context, groupSnapshot) {
          if (groupSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (groupSnapshot.hasError || groupSnapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load group data'),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final group = groupSnapshot.data!;
          final members = List<Map<String, dynamic>>.from(group['members']);

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _expensesFuture,
            builder: (context, expensesSnapshot) {
              if (expensesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final expenses = expensesSnapshot.data ?? [];

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _simplifiedDebtsFuture,
                builder: (context, debtsSnapshot) {
                  final simplifiedDebts = debtsSnapshot.data ?? [];

                  return DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'EXPENSES'),
                            Tab(text: 'BALANCES'),
                          ],
                          labelColor: Color(0xFF1CC29F),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Color(0xFF1CC29F),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Expenses tab
                              expenses.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.receipt_long,
                                            size: 64,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'No expenses yet',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Add your first expense to get started',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          AddExpensePage(
                                                        groupId: widget.groupId,
                                                        userId: widget.userId,
                                                      ),
                                                    ),
                                                  )
                                                  .then((_) => setState(
                                                      () => _loadData()));
                                            },
                                            icon: const Icon(Icons.add),
                                            label: const Text('Add an expense'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: expenses.length,
                                      itemBuilder: (context, index) {
                                        final expense = expenses[index];
                                        return ExpenseListItem(
                                          expense: expense,
                                          userId: widget.userId,
                                          onDelete: () =>
                                              setState(() => _loadData()),
                                        );
                                      },
                                    ),

                              // Balances tab
                              ListView(
                                padding: const EdgeInsets.all(16),
                                children: [
                                  // Simplified debts
                                  if (simplifiedDebts.isNotEmpty) ...[
                                    const Text(
                                      'SIMPLIFIED BALANCES',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...simplifiedDebts.map((debt) {
                                      final isUserInvolved =
                                          debt['from']['id'] == widget.userId ||
                                              debt['to']['id'] == widget.userId;

                                      return ListTile(
                                        title: Row(
                                          children: [
                                            Text(
                                              debt['from']['name'],
                                              style: TextStyle(
                                                fontWeight: isUserInvolved
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            const Icon(Icons.arrow_right_alt),
                                            Text(
                                              debt['to']['name'],
                                              style: TextStyle(
                                                fontWeight: isUserInvolved
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Text(
                                          'PKR ${debt['amount'].toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: isUserInvolved
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            // color: isUserInvolved
                                            //     ? Colors.black
                                            //     : Colors.grey,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],

                                  const SizedBox(height: 16),

                                  // Individual balances
                                  const Text(
                                    'INDIVIDUAL BALANCES',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...members.map((member) {
                                    final balance = member['balance'] ?? 0.0;
                                    final isCurrentUser =
                                        member['id'] == widget.userId;

                                    if (isCurrentUser)
                                      return const SizedBox.shrink();

                                    return FutureBuilder<Map<String, dynamic>?>(
                                      future: DatabaseService()
                                          .getUserById(member['id']),
                                      builder: (context, userSnapshot) {
                                        final userName =
                                            userSnapshot.data?['name'] ??
                                                'Unknown';

                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.primaries[
                                                userName.hashCode %
                                                    Colors.primaries.length],
                                            child: Text(
                                              userName
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          title: Text(userName),
                                          trailing: Text(
                                            balance == 0
                                                ? 'settled up'
                                                : balance > 0
                                                    ? 'owes you PKR ${balance.abs().toStringAsFixed(2)}'
                                                    : 'you owe PKR ${balance.abs().toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: balance == 0
                                                  ? Colors.grey
                                                  : balance > 0
                                                      ? const Color(0xFF1CC29F)
                                                      : Colors.orange,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => AddExpensePage(
                    groupId: widget.groupId,
                    userId: widget.userId,
                  ),
                ),
              )
              .then((_) => setState(() => _loadData()));
        },
        backgroundColor: const Color(0xFF1CC29F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Expense List Item
class ExpenseListItem extends StatelessWidget {
  final Map<String, dynamic> expense;
  final String userId;
  final Function()? onDelete;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.userId,
    this.onDelete,
  });

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text(
            'Are you sure you want to delete this expense? This will update all balances and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await _confirmDelete(context);
    if (confirmed == true) {
      await DatabaseService().deleteExpense(expense['id']);
      onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUserPayer = expense['paidBy'] == userId;
    final date = DateTime.parse(expense['date']);
    final formattedDate = DateFormat('MMM d, yyyy').format(date);

    return FutureBuilder<Map<String, dynamic>?>(
      future: DatabaseService().getUserById(expense['paidBy']),
      builder: (context, snapshot) {
        final payerName = snapshot.data?['name'] ?? 'Unknown';

        return Dismissible(
          key: Key(expense['id']),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (_) async {
            final confirmed = await _confirmDelete(context);
            if (confirmed == true) {
              await DatabaseService().deleteExpense(expense['id']);
              onDelete?.call();
              return true;
            }
            return false;
          },
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(expense['category']),
                color: _getCategoryColor(expense['category']),
              ),
            ),
            title: Text(
              expense['description'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '$formattedDate • ${isUserPayer ? 'You paid' : '$payerName paid'} PKR ${expense['amount'].toStringAsFixed(2)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTrailingWidget(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _handleDelete(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete expense',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              // Show expense details
            },
          ),
        );
      },
    );
  }

  Widget _buildTrailingWidget() {
    final splitWith = List<Map<String, dynamic>>.from(expense['splitWith']);
    final userSplit = splitWith.firstWhere(
      (split) => split['userId'] == userId,
      orElse: () => {'amount': 0.0},
    );

    final isUserPayer = expense['paidBy'] == userId;
    final userAmount = userSplit['amount'] ?? 0.0;

    if (isUserPayer) {
      final totalLent = expense['amount'] - userAmount;
      if (totalLent <= 0) return const Text('you paid');

      return Text(
        'you lent\n${formatCurrency(totalLent)}',
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Color(0xFF1CC29F),
        ),
      );
    } else {
      return Text(
        'you borrowed\nPKR ${userAmount.toStringAsFixed(2)}',
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.orange,
        ),
      );
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'accommodation':
        return Icons.hotel;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'utilities':
        return Icons.lightbulb;
      case 'other':
        return Icons.category;
      default:
        return Icons.receipt;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'accommodation':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'shopping':
        return Colors.teal;
      case 'utilities':
        return Colors.amber;
      case 'other':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

// Add Expense Tab
class AddExpenseTab extends StatelessWidget {
  final String userId;

  const AddExpenseTab({super.key, required this.userId});

  void _showExpenseTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add an expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF1CC29F)),
              title: const Text('With a friend'),
              subtitle: const Text('Split expenses with one person'),
              onTap: () {
                Navigator.pop(context);
                _showFriendSelectionDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.group, color: Color(0xFF1CC29F)),
              title: const Text('In a group'),
              subtitle: const Text('Split expenses with multiple people'),
              onTap: () {
                Navigator.pop(context);
                _showGroupSelectionDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFriendSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select friend'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseService().getFriends(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final friends = snapshot.data ?? [];

            if (friends.isEmpty) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No friends yet'),
                  SizedBox(height: 8),
                  Text(
                    'Add friends first to split expenses',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.primaries[
                          friend['name'].hashCode % Colors.primaries.length],
                      child: Text(
                        friend['name'].toString().substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(friend['name'].toString()),
                    subtitle: Text(friend['email'].toString()),
                    onTap: () {
                      Navigator.pop(context);
                      // Create a temporary group for this friend
                      final tempGroup = {
                        'id': const Uuid().v4(),
                        'name': 'Individual expense',
                        'members': [
                          {'id': userId, 'balance': 0.0},
                          {'id': friend['id'].toString(), 'balance': 0.0},
                        ],
                      };
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddExpensePage(
                            groupId: tempGroup['id'].toString(),
                            userId: userId,
                            isTemporaryGroup: true,
                            tempGroup: tempGroup,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showGroupSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select group'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseService().getGroupsByUserId(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final groups = snapshot.data ?? [];

            if (groups.isEmpty) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No groups yet'),
                  SizedBox(height: 8),
                  Text(
                    'Create a group first to split expenses',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.primaries[
                            group['name'].toString().hashCode %
                                Colors.primaries.length],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          group['name']
                              .toString()
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(group['name'].toString()),
                    subtitle:
                        Text('${(group['members'] as List).length} members'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddExpensePage(
                            groupId: group['id'].toString(),
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add expenses'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Add a new expense',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Split expenses with friends or groups',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showExpenseTypeDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add an expense'),
            ),
          ],
        ),
      ),
    );
  }
}

// Add Expense Page
class AddExpensePage extends StatefulWidget {
  final String groupId;
  final String userId;
  final bool isTemporaryGroup;
  final Map<String, dynamic>? tempGroup;

  const AddExpensePage({
    super.key,
    required this.groupId,
    required this.userId,
    this.isTemporaryGroup = false,
    this.tempGroup,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'other';
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _members = [];
  final Map<String, double> _splitAmounts = {};
  String _splitMethod = 'equal';

  @override
  void initState() {
    super.initState();
    _loadGroupMembers();
  }

  Future<void> _loadGroupMembers() async {
    if (widget.isTemporaryGroup && widget.tempGroup != null) {
      setState(() {
        _members =
            List<Map<String, dynamic>>.from(widget.tempGroup!['members']);

        // Initialize split amounts
        const equalAmount = 0.0; // Will be calculated when amount is entered
        for (var member in _members) {
          _splitAmounts[member['id']] = equalAmount;
        }
      });
    } else {
      final group = await DatabaseService().getGroupById(widget.groupId);
      if (group != null) {
        setState(() {
          _members = List<Map<String, dynamic>>.from(group['members']);

          // Initialize split amounts
          const equalAmount = 0.0; // Will be calculated when amount is entered
          for (var member in _members) {
            _splitAmounts[member['id']] = equalAmount;
          }
        });
      }
    }
  }

  void _updateSplitAmounts() {
    if (_amountController.text.isEmpty) return;

    final totalAmount = double.tryParse(_amountController.text) ?? 0;

    if (_splitMethod == 'equal') {
      final perPersonAmount = totalAmount / _members.length;
      for (var member in _members) {
        _splitAmounts[member['id']] = perPersonAmount;
      }
    }
    // Other split methods would be implemented here

    setState(() {});
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // Prepare split data
    final splitWith = _members.map((member) {
      return {
        'userId': member['id'],
        'amount': _splitAmounts[member['id']] ?? 0.0,
      };
    }).toList();

    // Create expense object
    final expense = {
      'id': const Uuid().v4(),
      'groupId': widget.groupId,
      'description': description,
      'amount': amount,
      'category': _selectedCategory,
      'date': _selectedDate.toIso8601String(),
      'paidBy': widget.userId,
      'splitWith': splitWith,
      'receiptUrl': null, // Would store image URL in a real app
      'notes': '',
      'createdAt': DateTime.now().toIso8601String(),
      'isIndividualExpense': widget.isTemporaryGroup,
    };

    // Save to database
    await DatabaseService().addExpense(expense);

    // Create activity record
    final activity = {
      'id': const Uuid().v4(),
      'type': 'expense_added',
      'userId': widget.userId,
      'groupId': widget.groupId,
      'expenseId': expense['id'],
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await DatabaseService().addActivity(activity);

    // Update balances
    if (!widget.isTemporaryGroup) {
      // Update group balances only for real groups
      final group = await DatabaseService().getGroupById(widget.groupId);
      if (group != null) {
        final members = List<Map<String, dynamic>>.from(group['members']);

        for (var i = 0; i < members.length; i++) {
          final member = members[i];
          final split = splitWith.firstWhere(
            (s) => s['userId'] == member['id'],
            orElse: () => {'amount': 0.0},
          );

          if (member['id'] == widget.userId) {
            // Current user paid
            member['balance'] =
                (member['balance'] ?? 0.0) + (amount - split['amount']);
          } else {
            // Other members
            member['balance'] = (member['balance'] ?? 0.0) - split['amount'];
          }
        }

        final updatedGroup = {
          ...group,
          'members': members,
        };

        await DatabaseService().updateGroup(updatedGroup);
      }
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add an expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Dinner, Groceries, Rent',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'PKR ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
              onChanged: (_) => _updateSplitAmounts(),
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
              ),
              items: [
                DropdownMenuItem(
                  value: 'food',
                  child: Row(
                    children: [
                      Icon(Icons.restaurant, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      const Text('Food & Drink'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'transport',
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Text('Transportation'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'accommodation',
                  child: Row(
                    children: [
                      Icon(Icons.hotel, color: Colors.purple.shade700),
                      const SizedBox(width: 8),
                      const Text('Accommodation'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'entertainment',
                  child: Row(
                    children: [
                      Icon(Icons.movie, color: Colors.pink.shade700),
                      const SizedBox(width: 8),
                      const Text('Entertainment'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'shopping',
                  child: Row(
                    children: [
                      Icon(Icons.shopping_bag, color: Colors.teal.shade700),
                      const SizedBox(width: 8),
                      const Text('Shopping'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'utilities',
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      const Text('Utilities'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Row(
                    children: [
                      Icon(Icons.category, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      const Text('Other'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Date
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );

                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            const Divider(),

            // Split method
            const Text(
              'SPLIT DETAILS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _splitMethod,
              decoration: const InputDecoration(
                labelText: 'Split method',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'equal',
                  child: Text('Split equally'),
                ),
                DropdownMenuItem(
                  value: 'exact',
                  child: Text('Split by exact amounts'),
                ),
                DropdownMenuItem(
                  value: 'percent',
                  child: Text('Split by percentages'),
                ),
                DropdownMenuItem(
                  value: 'shares',
                  child: Text('Split by shares'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _splitMethod = value;
                    _updateSplitAmounts();
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Members list
            ..._members.map((member) {
              return FutureBuilder<Map<String, dynamic>?>(
                future: DatabaseService().getUserById(member['id']),
                builder: (context, snapshot) {
                  final userName = snapshot.data?['name'] ?? 'Unknown';
                  final isCurrentUser = member['id'] == widget.userId;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.primaries[
                          userName.hashCode % Colors.primaries.length],
                      child: Text(
                        userName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      isCurrentUser ? 'You' : userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      'PKR ${(_splitAmounts[member['id']] ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _saveExpense,
              child: const Text('Save expense'),
            ),
          ],
        ),
      ),
    );
  }
}

// Activity Tab
class ActivityTab extends StatefulWidget {
  final String userId;

  const ActivityTab({super.key, required this.userId});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  late Future<List<Map<String, dynamic>>> _activitiesFuture;
  late Future<Map<String, dynamic>> _balancesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _activitiesFuture = DatabaseService().getActivitiesByUserId(widget.userId);
    _balancesFuture = DatabaseService().calculateBalances(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity'),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pie_chart),
                    const SizedBox(width: 8),
                    Text(
                      'Overview',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history),
                    const SizedBox(width: 8),
                    Text(
                      'Activity',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadData();
                });
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EXPENSE OVERVIEW',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _balancesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return const SizedBox(
                            height: 200,
                            child: Center(
                                child: Text('Failed to load balance data')),
                          );
                        }

                        return ExpenseOverviewChart(balances: snapshot.data!);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Activity Tab
            RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadData();
                });
              },
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _activitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final activities = snapshot.data ?? [];

                  if (activities.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recent activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add some expenses to see activity here',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return ActivityListItem(
                        activity: activity,
                        userId: widget.userId,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Expense Overview Chart
class ExpenseOverviewChart extends StatelessWidget {
  final Map<String, dynamic> balances;

  const ExpenseOverviewChart({
    super.key,
    required this.balances,
  });

  @override
  Widget build(BuildContext context) {
    final userBalances =
        List<Map<String, dynamic>>.from(balances['userBalances']);
    final owedBalances =
        userBalances.where((b) => b['type'] == 'owed').toList();
    final oweBalances = userBalances.where((b) => b['type'] == 'owe').toList();

    // Sort balances by amount
    owedBalances
        .sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));
    oweBalances
        .sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));

    // Take top 5 for each category
    final topOwed = owedBalances.take(5).toList();
    final topOwe = oweBalances.take(5).toList();

    // Calculate total amounts
    final totalOwed =
        owedBalances.fold<double>(0, (sum, b) => sum + (b['amount'] as num));
    final totalOwe =
        oweBalances.fold<double>(0, (sum, b) => sum + (b['amount'] as num));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1CC29F).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_upward,
                              color: Color(0xFF1CC29F),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'you are owed',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PKR ${totalOwed.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1CC29F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_downward,
                              color: Colors.orange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'you owe',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PKR ${totalOwe.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Charts
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // You are owed
            if (topOwed.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top owed by',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: topOwed.isEmpty
                              ? 10
                              : (topOwed.first['amount'] * 1.2),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  // Format large numbers with K suffix
                                  String formattedValue;
                                  if (value >= 1000) {
                                    formattedValue =
                                        '${(value / 1000).toStringAsFixed(0)}K';
                                  } else {
                                    formattedValue = value.toInt().toString();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      'PKR $formattedValue',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 60,
                                interval: (topOwed.first['amount'] / 4)
                                    .roundToDouble(),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= topOwed.length)
                                    return const Text('');
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      topOwed[value.toInt()]['name']
                                          .toString()
                                          .split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: topOwed.first['amount'] / 5,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          barGroups: List.generate(
                            topOwed.length,
                            (index) => BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: topOwed[index]['amount'],
                                  color: const Color(0xFF1CC29F),
                                  width: 16,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                    bottom: Radius.circular(0),
                                  ),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: topOwed.first['amount'] * 1.2,
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (topOwed.isNotEmpty && topOwe.isNotEmpty)
              const SizedBox(width: 24),
            // You owe
            if (topOwe.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top you owe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: topOwe.isEmpty
                              ? 10
                              : (topOwe.first['amount'] * 1.2),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  // Format large numbers with K suffix
                                  String formattedValue;
                                  if (value >= 1000) {
                                    formattedValue =
                                        '${(value / 1000).toStringAsFixed(0)}K';
                                  } else {
                                    formattedValue = value.toInt().toString();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      'PKR $formattedValue',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 60,
                                interval: (topOwe.first['amount'] / 4)
                                    .roundToDouble(),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= topOwe.length)
                                    return const Text('');
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      topOwe[value.toInt()]['name']
                                          .toString()
                                          .split(' ')[0],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: topOwe.first['amount'] / 5,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          barGroups: List.generate(
                            topOwe.length,
                            (index) => BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: topOwe[index]['amount'],
                                  color: Colors.orange,
                                  width: 16,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                    bottom: Radius.circular(0),
                                  ),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: topOwe.first['amount'] * 1.2,
                                    color: Colors.grey.shade100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// Activity List Item
class ActivityListItem extends StatelessWidget {
  final Map<String, dynamic> activity;
  final String userId;

  const ActivityListItem({
    super.key,
    required this.activity,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = DateTime.parse(activity['timestamp']);
    final formattedDate =
        DateFormat('MMM d, yyyy \'at\' h:mm a').format(timestamp);

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Loading...'),
          );
        }

        final userData = userSnapshot.data;

        return FutureBuilder<Map<String, dynamic>?>(
          future: _getRelatedData(),
          builder: (context, relatedSnapshot) {
            final relatedData = relatedSnapshot.data;

            return ListTile(
              leading: _buildLeadingIcon(),
              title: _buildTitle(context, userData, relatedData),
              subtitle: Text(formattedDate),
              onTap: () {
                // Show activity details
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    if (activity['userId'] != null) {
      return DatabaseService().getUserById(activity['userId']);
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getRelatedData() async {
    if (activity['type'] == 'expense_added' ||
        activity['type'] == 'expense_updated') {
      if (activity['groupId'] != null) {
        return DatabaseService().getGroupById(activity['groupId']);
      }
    } else if (activity['type'] == 'payment_recorded' ||
        activity['type'] == 'payment_received') {
      if (activity['relatedUserId'] != null) {
        return DatabaseService().getUserById(activity['relatedUserId']);
      }
    }
    return null;
  }

  Widget _buildLeadingIcon() {
    switch (activity['type']) {
      case 'expense_added':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.receipt, color: Colors.green),
        );
      case 'payment_recorded':
      case 'payment_received':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.payments, color: Colors.blue),
        );
      default:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.info, color: Colors.grey),
        );
    }
  }

  Widget _buildTitle(BuildContext context, Map<String, dynamic>? userData,
      Map<String, dynamic>? relatedData) {
    final isCurrentUser = activity['userId'] == userId;
    final userName = userData?['name'] ?? 'Unknown';
    final colorStyle = Theme.of(context).textTheme.bodyMedium;

    switch (activity['type']) {
      case 'expense_added':
        final groupName = relatedData?['name'] ?? 'a group';
        return RichText(
          text: TextSpan(
            style: colorStyle,
            children: [
              TextSpan(
                text: isCurrentUser ? 'You' : userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' added '),
              TextSpan(
                text: activity['description'] ?? 'an expense',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' in '),
              TextSpan(
                text: groupName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        );
      case 'payment_recorded':
        final relatedUserName = relatedData?['name'] ?? 'someone';
        return RichText(
          text: TextSpan(
            style: colorStyle,
            children: [
              TextSpan(
                text: isCurrentUser ? 'You' : userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' recorded a payment from '),
              TextSpan(
                text: relatedUserName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        );
      case 'payment_received':
        final relatedUserName = relatedData?['name'] ?? 'someone';
        return RichText(
          text: TextSpan(
            style: colorStyle,
            children: [
              TextSpan(
                text: isCurrentUser ? 'You' : userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' paid '),
              TextSpan(
                text: relatedUserName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        );
      default:
        return Text(
          isCurrentUser
              ? 'You performed an action'
              : '$userName performed an action',
        );
    }
  }
}

// Account Tab
class AccountTab extends StatefulWidget {
  final Map<String, dynamic> user;

  const AccountTab({super.key, required this.user});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  bool _notificationsEnabled = true;
  dynamic _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _showCurrencyPicker() async {
    final Currency? result = await showDialog<Currency>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: ListenableBuilder(
            listenable: CurrencyNotifier(),
            builder: (context, _) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currencies.length,
                  itemBuilder: (BuildContext context, int index) {
                    final currency = currencies[index];
                    return ListTile(
                      leading: Text(currency.symbol),
                      title: Text(currency.name),
                      subtitle: Text(currency.code),
                      selected:
                          currency.code == CurrencyNotifier().currency.code,
                      onTap: () {
                        Navigator.of(context).pop(currency);
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null) {
      await CurrencyNotifier().setCurrency(result);
    }
  }

  Future<void> _loadProfileImage() async {
    final image = await DatabaseService().getProfileImage(
      widget.user['id'],
      widget.user['profilePicture'],
    );
    if (mounted) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Widget _buildProfileImage() {
    if (_profileImage == null) {
      return Text(
        widget.user['name'].substring(0, 1).toUpperCase(),
        style: const TextStyle(color: Colors.white),
      );
    }

    if (kIsWeb) {
      return ClipOval(
        child: Image.memory(
          base64Decode(_profileImage),
          fit: BoxFit.cover,
          width: 40,
          height: 40,
        ),
      );
    }

    return ClipOval(
      child: Image.file(
        _profileImage,
        fit: BoxFit.cover,
        width: 40,
        height: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListenableBuilder(
        listenable: ThemeNotifier(),
        builder: (context, child) {
          final isDark = ThemeNotifier().themeMode == ThemeMode.dark;
          return ListView(
            children: [
              // Profile Section
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade700,
                  child: _buildProfileImage(),
                ),
                title: Text(
                  widget.user['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(widget.user['email']),
                trailing: const Icon(Icons.camera_alt),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(user: widget.user),
                    ),
                  );
                },
              ),
              const Divider(),

              // Settings Section
              ExpansionTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                children: [
                  // Currency
                  ListenableBuilder(
                    listenable: CurrencyNotifier(),
                    builder: (context, _) {
                      final currency = CurrencyNotifier().currency;
                      return ListTile(
                        leading: const Icon(Icons.currency_exchange),
                        title: const Text('Currency'),
                        subtitle: Text('${currency.code} - ${currency.name}'),
                        trailing: Text(
                          currency.symbol,
                          style: const TextStyle(fontSize: 18),
                        ),
                        onTap: _showCurrencyPicker,
                      );
                    },
                  ),
                  // Theme
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    subtitle: Text(
                        isDark ? 'Dark theme enabled' : 'Light theme enabled'),
                    value: isDark,
                    onChanged: (value) {
                      ThemeNotifier().setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ],
              ),

              // Preferences Section
              ExpansionTile(
                leading: const Icon(Icons.tune),
                title: const Text('Preferences'),
                children: [
                  // Notifications
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    subtitle: const Text('Enable push notifications'),
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  // Default Split
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Default Split'),
                    subtitle: const Text('Equal split'),
                    onTap: () {
                      // Default split settings
                    },
                  ),
                  // Categories
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Categories'),
                    subtitle: const Text('Manage expense categories'),
                    onTap: () {
                      // Categories settings
                    },
                  ),
                ],
              ),

              // Security Section
              ExpansionTile(
                leading: const Icon(Icons.security),
                title: const Text('Security'),
                children: [
                  // Change Password
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    onTap: () {
                      // Change password
                    },
                  ),
                  // Reset Password
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Reset Password'),
                    onTap: () {
                      // Reset password
                    },
                  ),
                  // Privacy Settings
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Settings'),
                    onTap: () {
                      // Privacy settings
                    },
                  ),
                  // Login Activity
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Login Activity'),
                    onTap: () {
                      // Login activity
                    },
                  ),
                ],
              ),

              // Help & Support Section
              ExpansionTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                children: [
                  // Contact Us
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Contact Us'),
                    subtitle: const Text('ask@billsplitter.com'),
                    onTap: () {
                      // Launch email client
                    },
                  ),
                  // FAQs
                  ListTile(
                    leading: const Icon(Icons.question_answer),
                    title: const Text('FAQs'),
                    onTap: () {
                      // Show FAQs
                    },
                  ),
                  // Terms & Conditions
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Terms & Conditions'),
                    onTap: () {
                      // Show terms
                    },
                  ),
                  // Privacy Policy
                  ListTile(
                    leading: const Icon(Icons.policy),
                    title: const Text('Privacy Policy'),
                    onTap: () {
                      // Show privacy policy
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Log Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await AuthService().logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const WelcomePage()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Log out'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

// Edit Profile Page
class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  dynamic _newProfileImage;
  Uint8List? _webImage;
  dynamic _currentProfileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name']);
    _emailController = TextEditingController(text: widget.user['email']);
    _loadCurrentProfileImage();
  }

  Future<void> _loadCurrentProfileImage() async {
    final image = await DatabaseService().getProfileImage(
      widget.user['id'],
      widget.user['profilePicture'],
    );
    if (mounted) {
      setState(() {
        _currentProfileImage = image;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Handle web platform
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
            _newProfileImage = pickedFile;
          });
        } else {
          // Handle mobile platform
          setState(() {
            _newProfileImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  Widget _buildProfileImage() {
    if (_webImage != null) {
      return Image.memory(_webImage!, fit: BoxFit.cover);
    }

    if (_newProfileImage != null && !kIsWeb) {
      return Image.file(_newProfileImage!, fit: BoxFit.cover);
    }

    if (_currentProfileImage != null) {
      if (kIsWeb && _currentProfileImage is String) {
        return Image.memory(base64Decode(_currentProfileImage),
            fit: BoxFit.cover);
      }
      if (!kIsWeb && _currentProfileImage is File) {
        return Image.file(_currentProfileImage, fit: BoxFit.cover);
      }
    }

    return Text(
      widget.user['name'].substring(0, 1).toUpperCase(),
      style: const TextStyle(fontSize: 40, color: Colors.white),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? profilePicturePath = widget.user['profilePicture'];

      if (_newProfileImage != null) {
        profilePicturePath = await DatabaseService().saveProfileImage(
          widget.user['id'],
          _newProfileImage!,
        );
      }

      final updatedUser = {
        ...widget.user,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'profilePicture': profilePicturePath,
      };

      final success = await AuthService().updateProfile(updatedUser);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred while saving profile')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.red.shade700,
                    child: ClipOval(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: _buildProfileImage(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to format currency
String formatCurrency(double amount) {
  final currency = CurrencyNotifier().currency;
  return '${currency.symbol} ${amount.abs().toStringAsFixed(2)}';
}
