// lib/screens/user/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:app/providers/auth_provider.dart';
import 'package:app/config/theme.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _teamController = TextEditingController();
  final _organizationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;

    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      // These fields don't exist in the new User model, so we'll leave them empty for now
      // In a real app, you'd need to add these fields to your User model and API
      _teamController.text = '';
      _organizationController.text = '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _teamController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Save',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.currentUser;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No user data available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Header Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Profile Picture
                            GestureDetector(
                              onTap: _isEditing ? _selectProfileImage : null,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    backgroundImage: _selectedImage != null
                                        ? FileImage(_selectedImage!)
                                        : null, // No profileImage field in new User model
                                    child: _selectedImage == null
                                        ? Text(
                                      user.fullName.isNotEmpty
                                          ? user.fullName.substring(0, 1).toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                        : null,
                                  ),
                                  if (_isEditing)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.surface,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: AppColors.background,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Name fields
                            if (_isEditing) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _firstNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'First Name',
                                        prefixIcon: Icon(Icons.person),
                                      ),
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return 'First name cannot be empty';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _lastNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Last Name',
                                        prefixIcon: Icon(Icons.person_outline),
                                      ),
                                      validator: (value) {
                                        if (value?.isEmpty ?? true) {
                                          return 'Last name cannot be empty';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Text(
                                user.fullName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                ),
                                child: Text(
                                  user.role.toUpperCase(),
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Organization Details Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Organization Details',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Team
                            if (_isEditing)
                              TextFormField(
                                controller: _teamController,
                                decoration: const InputDecoration(
                                  labelText: 'Team',
                                  prefixIcon: Icon(Icons.group),
                                  hintText: 'Enter your team name',
                                ),
                              )
                            else
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.group,
                                  color: AppColors.primary,
                                ),
                                title: const Text('Team'),
                                subtitle: Text(
                                  _teamController.text.isNotEmpty ? _teamController.text : 'Not specified',
                                  style: TextStyle(
                                    color: _teamController.text.isNotEmpty
                                        ? AppColors.textPrimary
                                        : AppColors.textTertiary,
                                  ),
                                ),
                              ),

                            if (_isEditing) const SizedBox(height: 16),

                            // Organization
                            if (_isEditing)
                              TextFormField(
                                controller: _organizationController,
                                decoration: const InputDecoration(
                                  labelText: 'Organization',
                                  prefixIcon: Icon(Icons.business),
                                  hintText: 'Enter your organization name',
                                ),
                              )
                            else
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.business,
                                  color: AppColors.primary,
                                ),
                                title: const Text('Organization'),
                                subtitle: Text(
                                  _organizationController.text.isNotEmpty ? _organizationController.text : 'Not specified',
                                  style: TextStyle(
                                    color: _organizationController.text.isNotEmpty
                                        ? AppColors.textPrimary
                                        : AppColors.textTertiary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Account Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Information',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.email,
                                color: AppColors.primary,
                              ),
                              title: const Text('Email'),
                              subtitle: Text(user.email),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.badge,
                                color: AppColors.primary,
                              ),
                              title: const Text('User ID'),
                              subtitle: Text(user.id),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                              ),
                              title: const Text('Member Since'),
                              subtitle: Text(_formatDate(user.createdAt)),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.update,
                                color: AppColors.primary,
                              ),
                              title: const Text('Last Updated'),
                              subtitle: Text(_formatDate(user.updatedAt)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Settings Card
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.notifications, color: AppColors.primary),
                            title: const Text('Notifications'),
                            subtitle: const Text('Manage notification preferences'),
                            trailing: Switch(
                              value: true,
                              onChanged: (value) {
                                // TODO: Implement notification settings
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Notification settings updated'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.security, color: AppColors.primary),
                            title: const Text('Privacy & Security'),
                            subtitle: const Text('Manage your privacy settings'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // TODO: Navigate to privacy settings
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Privacy settings coming soon!'),
                                  backgroundColor: AppColors.info,
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.help, color: AppColors.primary),
                            title: const Text('Help & Support'),
                            subtitle: const Text('Get help and contact support'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              _showHelpDialog();
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.info, color: AppColors.primary),
                            title: const Text('About'),
                            subtitle: const Text('App version and information'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              _showAboutDialog();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showLogoutDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.textPrimary,
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.textPrimary),
                          ),
                        )
                            : const Text('Logout'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectProfileImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: AppColors.primary),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.error),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Prepare update data - adjust field names to match your API
    Map<String, dynamic> updateData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      // Note: These fields don't exist in the current User model
      // You'll need to add them to your backend and User model if needed
      'team': _teamController.text.trim(),
      'organization': _organizationController.text.trim(),
    };

    // TODO: Upload image if selected
    if (_selectedImage != null) {
      // uploadData['profileImage'] = await uploadImageToServer(_selectedImage!);
    }

    final success = await auth.updateProfile(updateData);

    if (success) {
      setState(() {
        _isEditing = false;
        _selectedImage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_work,
                color: AppColors.background,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('About SynergySphere'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version: 1.0.0'),
            const SizedBox(height: 8),
            const Text('Advanced Team Collaboration Platform'),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Text('• Project & Task Management'),
            const Text('• Team Collaboration'),
            const Text('• Real-time Updates'),
            const Text('• File Attachments'),
            const Text('• Progress Tracking'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help with SynergySphere?'),
            SizedBox(height: 16),
            Text('📧 Email: support@synergysphere.com'),
            Text('📱 Phone: +1 (555) 123-4567'),
            Text('🌐 Website: www.synergysphere.com'),
            SizedBox(height: 16),
            Text('Our support team is available 24/7 to assist you.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}