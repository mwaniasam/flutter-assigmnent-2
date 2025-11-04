import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookswap_app/config/app_theme.dart';
import 'package:bookswap_app/providers/auth_provider.dart';
import 'package:bookswap_app/providers/theme_provider.dart';
import 'package:bookswap_app/services/firestore_service.dart';
import 'package:bookswap_app/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _notificationReminders = true;
  bool _emailUpdates = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: StreamBuilder<UserModel?>(
        stream: _firestoreService.getCurrentUserStream(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          
          return ListView(
            children: [
              _buildProfileHeader(user),
              
              const SizedBox(height: 24),
              
              _buildSettingsSection(
                title: 'Appearance',
                children: [
                  ListTile(
                    title: const Text('Dark Mode', style: AppTheme.bodyText),
                    subtitle: const Text('Toggle dark theme', style: AppTheme.caption),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      activeTrackColor: AppTheme.accentGold,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSettingsSection(
                title: 'Notifications',
                children: [
                  _buildSwitchTile(
                    title: 'Notification reminders',
                    value: _notificationReminders,
                    onChanged: (value) {
                      setState(() {
                        _notificationReminders = value;
                      });
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Email Updates',
                    value: _emailUpdates,
                    onChanged: (value) {
                      setState(() {
                        _emailUpdates = value;
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _buildSettingsSection(
                title: 'App Information',
                children: [
                  _buildInfoTile(
                    title: 'About',
                    onTap: () {
                      _showAboutDialog();
                    },
                  ),
                  _buildInfoTile(
                    title: 'Privacy Policy',
                    onTap: () {
                      // Would navigate to privacy policy
                    },
                  ),
                  _buildInfoTile(
                    title: 'Terms of Service',
                    onTap: () {
                      // Would navigate to terms
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton(
                  onPressed: () {
                    _showLogoutDialog(authProvider);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Log Out'),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? 'user@email.com';
    final initials = displayName.isNotEmpty 
        ? displayName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';
    
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.accentGold,
                backgroundImage: user?.photoURL != null 
                    ? NetworkImage(user!.photoURL!) 
                    : null,
                child: user?.photoURL == null 
                    ? Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryNavy,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.accentGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 20,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: AppTheme.heading2.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: AppTheme.heading2.copyWith(fontSize: 16),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          color: AppTheme.cardBackground,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: AppTheme.bodyText),
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppTheme.accentGold,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: AppTheme.bodyText),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.subtleGray,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About BookSwap'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text(
              'BookSwap helps students exchange books with each other, making education more affordable and sustainable.',
              style: AppTheme.bodyText,
            ),
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

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
