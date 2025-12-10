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
              // TODO: Implement data export
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
              // TODO: Implement account deletion
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          // User Profile Section
          Card(
            elevation: 2,
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
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
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

          // User Settings Section
          _buildSectionTitle('User Settings'),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Profile Information',
            subtitle: 'Update your personal details',
            onTap: _editUserSettings,
          ),

          SizedBox(height: 24),

          // App Settings Section
          _buildSectionTitle('App Settings'),

          _buildSettingsTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: _selectedTheme,
            onTap: () {
              _showThemeSelector();
            },
          ),

          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _selectedLanguage,
            onTap: () {
              _showLanguageSelector();
            },
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
          ),

          SizedBox(height: 24),

          // Data & Privacy Section
          _buildSectionTitle('Data & Privacy'),

          _buildSettingsTile(
            icon: Icons.download,
            title: 'Export Data',
            subtitle: 'Download your data as JSON',
            onTap: _exportData,
          ),

          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: _showPrivacyPolicy,
          ),

          SizedBox(height: 24),

          // Danger Zone
          _buildSectionTitle('Danger Zone'),
          _buildSettingsTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            onTap: _deleteAccount,
            isDestructive: true,
          ),

          SizedBox(height: 40),

          // App Version
          Center(
            child: Text(
              'WellStride v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 8),
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
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
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
    // TODO: Save changes to database
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                    ),
                  ),
                  SizedBox(height: 24),

                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  SizedBox(height: 24),

                  Text('Age: $_age', style: TextStyle(fontSize: 16)),
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

                  Text('Weight: ${_weight.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 16)),
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

                  Text('Height: ${_height.toStringAsFixed(0)} cm', style: TextStyle(fontSize: 16)),
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

                  Text('Target Steps: $_targetSteps', style: TextStyle(fontSize: 16)),
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
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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