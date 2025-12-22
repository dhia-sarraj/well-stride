import 'package:flutter/material.dart';
import '../../services/dummy_data_service.dart';
import '../../models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DummyDataService _dataService = DummyDataService();
  late UserModel _user;

  String _selectedTheme = 'System';
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _user = _dataService.getDummyUser();
  }

  void _editUserSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserSettingsSheet(user: _user),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Data'),
        content: Text('Your data will be exported and sent to ${_user.email}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Data exported to ${_user.email}')),
              );
            },
            child: Text('Export'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/welcome');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'WellStride Privacy Policy\n\n'
                'We respect your privacy and are committed to protecting your personal data.\n\n'
                '1. Data Collection: We collect health and activity data to provide you with personalized insights.\n\n'
                '2. Data Usage: Your data is used solely to improve your experience within the app.\n\n'
                '3. Data Security: We implement industry-standard security measures to protect your information.\n\n'
                '4. Data Sharing: We do not share your personal data with third parties without your consent.\n\n'
                'For more information, visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1A1A2E) : Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        backgroundColor: isDark ? Color(0xFF1A1A2E) : Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          // User Profile Section
          Card(
            elevation: 2,
            color: isDark ? Color(0xFF16213E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      _user.username[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user.username,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          _buildSectionTitle('User Settings', isDark),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Profile Information',
            subtitle: 'Update your personal details',
            onTap: _editUserSettings,
            isDark: isDark,
          ),

          SizedBox(height: 24),

          _buildSectionTitle('App Settings', isDark),

          _buildSettingsTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: _selectedTheme,
            onTap: _showThemeSelector,
            isDark: isDark,
          ),

          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _selectedLanguage,
            onTap: _showLanguageSelector,
            isDark: isDark,
          ),

          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Enable push notifications',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            isDark: isDark,
          ),

          SizedBox(height: 24),

          _buildSectionTitle('Data & Privacy', isDark),

          _buildSettingsTile(
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Download your data as JSON',
            onTap: _exportData,
            isDark: isDark,
          ),

          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: _showPrivacyPolicy,
            isDark: isDark,
          ),

          SizedBox(height: 24),

          _buildSectionTitle('Danger Zone', isDark),
          _buildSettingsTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            onTap: _deleteAccount,
            isDestructive: true,
            isDark: isDark,
          ),

          SizedBox(height: 40),

          Center(
            child: Text(
              'WellStride v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.grey.shade500,
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    required bool isDark,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 8),
      color: isDark ? Color(0xFF16213E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white54 : Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 8),
      color: isDark ? Color(0xFF16213E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildThemeOption('Light'),
              _buildThemeOption('Dark'),
              _buildThemeOption('System'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(String theme) {
    bool isSelected = _selectedTheme == theme;
    return ListTile(
      title: Text(theme),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
      onTap: () {
        setState(() {
          _selectedTheme = theme;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildLanguageOption('English'),
              _buildLanguageOption('French'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    bool isSelected = _selectedLanguage == language;
    return ListTile(
      title: Text(language),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }
}

// USER SETTINGS EDIT SHEET
class UserSettingsSheet extends StatefulWidget {
  final UserModel user;

  UserSettingsSheet({required this.user});

  @override
  _UserSettingsSheetState createState() => _UserSettingsSheetState();
}

class _UserSettingsSheetState extends State<UserSettingsSheet> {
  late TextEditingController _usernameController;
  late int _age;
  late double _weight;
  late double _height;
  late String _sex;
  late int _targetSteps;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _age = widget.user.age;
    _weight = widget.user.weight;
    _height = widget.user.height;
    _sex = widget.user.sex;
    _targetSteps = widget.user.targetSteps;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF16213E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 24),

                  TextField(
                    controller: _usernameController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600),
                      prefixIcon: Icon(Icons.person, color: isDark ? Colors.white70 : Colors.grey.shade600),
                    ),
                  ),

                  SizedBox(height: 24),

                  Text('Age: $_age', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  Slider(
                    value: _age.toDouble(),
                    min: 13,
                    max: 100,
                    divisions: 87,
                    label: '$_age',
                    onChanged: (value) {
                      setState(() {
                        _age = value.toInt();
                      });
                    },
                  ),

                  SizedBox(height: 16),

                  Text('Weight: ${_weight.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  Slider(
                    value: _weight,
                    min: 30,
                    max: 200,
                    divisions: 170,
                    label: '${_weight.toStringAsFixed(1)} kg',
                    onChanged: (value) {
                      setState(() {
                        _weight = value;
                      });
                    },
                  ),

                  SizedBox(height: 16),

                  Text('Height: ${_height.toStringAsFixed(0)} cm', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  Slider(
                    value: _height,
                    min: 120,
                    max: 220,
                    divisions: 100,
                    label: '${_height.toStringAsFixed(0)} cm',
                    onChanged: (value) {
                      setState(() {
                        _height = value;
                      });
                    },
                  ),

                  SizedBox(height: 16),

                  Text('Target Steps: $_targetSteps', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  Slider(
                    value: _targetSteps.toDouble(),
                    min: 5000,
                    max: 20000,
                    divisions: 30,
                    label: '$_targetSteps',
                    onChanged: (value) {
                      setState(() {
                        _targetSteps = (value / 500).round() * 500;
                      });
                    },
                  ),

                  SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Color(0xFFC16200),
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}