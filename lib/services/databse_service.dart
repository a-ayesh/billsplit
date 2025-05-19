// Database Service
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as html;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

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

extension on html.SingletonFlutterWindow {
   get localStorage => null;
}
