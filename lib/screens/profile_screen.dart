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
        title: const Text('Profile & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.errorRed),
            tooltip: 'Logout',
            onPressed: () {
              _showLogoutDialog(authProvider);
            },
          ),
        ],
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
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    subtitle: Text(
                      'Toggle dark theme',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
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
                child: Text(
                  'Tip: Tap the profile picture to change it!',
                  style: AppTheme.caption.copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _showAvatarSelection() {
    final List<String> avatars = [
      '😊', '🎓', '📚', '🌟', '🚀', 
      '🎨', '💡', '🏆', '🌈', '⚡'
    ];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose Your Avatar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: avatars.length,
                itemBuilder: (context, index) {
                  final avatar = avatars[index];
                  return GestureDetector(
                    key: ValueKey('avatar_$index'),
                    onTap: () {
                      Navigator.pop(context);
                      _updateAvatar(avatar);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentGold.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          avatar,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateAvatar(String emoji) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      
      if (userId == null) {
        _showErrorSnackbar('User not authenticated');
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Update Firestore with emoji as photoUrl
      await _firestoreService.updateUserProfile(
        photoUrl: emoji,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      _showSuccessSnackbar('Avatar updated!');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackbar('Failed to update avatar: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? 'user@email.com';
    final photoUrl = user?.photoURL;
    
    // Check if photoUrl is an emoji (single character)
    final bool isEmoji = photoUrl != null && photoUrl.length <= 2;
    
    final initials = displayName.isNotEmpty 
        ? displayName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';
    
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              _showAvatarSelection();
            },
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.accentGold,
                  child: isEmoji 
                      ? Text(
                          photoUrl,
                          style: const TextStyle(fontSize: 60),
                        )
                      : Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              _showAvatarSelection();
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Change Avatar'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accentGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          color: isDark ? AppTheme.darkCard : AppTheme.cardBackground,
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
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? AppTheme.darkSubtext : AppTheme.subtleGray,
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
