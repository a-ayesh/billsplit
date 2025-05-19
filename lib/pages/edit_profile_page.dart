// Edit Profile Page
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splitwise/main.dart';
import 'package:splitwise/services/auth_services.dart';
import 'package:splitwise/services/databse_service.dart';

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
