import 'package:flutter/material.dart';
import 'package:luma/services/persistence_service.dart';
import 'package:luma/widgets/avatar_picker.dart';
import 'package:luma/widgets/themed_background.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final PersistenceService _persistenceService = PersistenceService();
  late TextEditingController _nameController;
  int _selectedAvatarId = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await _persistenceService.getUserName();
    final avatarId = await _persistenceService.getAvatarId();
    if (mounted) {
      setState(() {
        _nameController.text = name;
        _selectedAvatarId = avatarId;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await _persistenceService.saveProfile(
          _nameController.text, _selectedAvatarId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved!')),
        );
        Navigator.of(context).pop(true); // Pop and signal success
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: ThemedBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text("Choose Your Avatar",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    AvatarPicker(
                      selectedAvatarId: _selectedAvatarId,
                      onAvatarSelected: (id) =>
                          setState(() => _selectedAvatarId = id),
                    ),
                    const SizedBox(height: 32),
                    Text("Enter Your Name",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}