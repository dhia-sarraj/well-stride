import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(ThemeMode)? onThemeChanged;

  const SettingsScreen({Key? key, this.onThemeChanged}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedTheme = 'System';
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Loading profile...');
      final profile = await _apiService.getProfile();

      if (profile == null) {
        setState(() {
          _errorMessage = 'No profile found. Please complete your profile.';
          _isLoading = false;
        });
        return;
      }

      print('Profile loaded successfully: ${profile.username}');
      setState(() {
        _user = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _errorMessage = 'Failed to load profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('theme') ?? 'System';
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  Future<void> _saveNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', enabled);
  }

  void _editUserSettings() {
    if (_user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserSettingsSheet(
        user: _user!,
        onSave: (updatedUser) async {
          await _updateProfile(updatedUser);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _updateProfile(UserModel updatedUser) async {
    try {
      print('Updating profile: ${updatedUser.username}');

      // Update profile - the API now returns the updated profile directly
      final updated = await _apiService.updateProfile(
        username: updatedUser.username,
        age: updatedUser.age,
        gender: updatedUser.gender,
        height: updatedUser.height,
        weight: updatedUser.weight,
        goal: updatedUser.goal, // Changed from targetSteps
      );

      setState(() {
        _user = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Light', 'Dark', 'System'].map((theme) {
              final isSelected = _selectedTheme == theme;
              return ListTile(
                title: Text(theme),
                trailing: isSelected
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () async {
                  if (widget.onThemeChanged != null) {
                    if (theme == 'Light') widget.onThemeChanged!(ThemeMode.light);
                    if (theme == 'Dark') widget.onThemeChanged!(ThemeMode.dark);
                    if (theme == 'System') widget.onThemeChanged!(ThemeMode.system);
                  }
                  await _saveTheme(theme);
                  setState(() {
                    _selectedTheme = theme;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
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
            children: ['English', 'French'].map((lang) {
              final isSelected = _selectedLanguage == lang;
              return ListTile(
                title: Text(lang),
                trailing: isSelected
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () async {
                  await _saveLanguage(lang);
                  setState(() {
                    _selectedLanguage = lang;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC16200),
                ),
                child: Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      )
          : ListView(
        padding: EdgeInsets.all(20),
        children: [
          // User profile card
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
                    backgroundColor: Color(0xFFC16200),
                    backgroundImage: (_user?.photoUrl != null && _user!.photoUrl!.isNotEmpty)
                        ? NetworkImage(_user!.photoUrl!)
                        : null,
                    child: (_user?.photoUrl == null || _user!.photoUrl!.isEmpty)
                        ? Text(
                      _user!.username[0].toUpperCase(),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    )
                        : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user!.username,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _user!.email ?? 'No email',
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          _buildSettingsTile(
            icon: Icons.person,
            title: 'Profile Information',
            subtitle: 'Update your personal details',
            onTap: _editUserSettings,
            isDark: isDark,
          ),

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
            onChanged: (val) {
              _saveNotifications(val);
              setState(() {
                _notificationsEnabled = val;
              });
            },
            isDark: isDark,
          ),
        ],
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
        leading: Icon(icon, color: isDestructive ? Colors.red : Color(0xFFC16200)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black),
          ),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600)),
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
        secondary: Icon(icon, color: Color(0xFFC16200)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
        subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600)),
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFFC16200),
      ),
    );
  }
}

class UserSettingsSheet extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onSave;

  const UserSettingsSheet({required this.user, required this.onSave, Key? key}) : super(key: key);

  @override
  _UserSettingsSheetState createState() => _UserSettingsSheetState();
}

class _UserSettingsSheetState extends State<UserSettingsSheet> {
  late TextEditingController _usernameController;
  late int _age;
  late double _weight;
  late double _height;
  late String _sex;
  late int _goal; // Changed from _targetSteps

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _age = widget.user.age;
    _weight = widget.user.weight.toDouble();
    _height = widget.user.height.toDouble();
    _sex = widget.user.gender;
    _goal = widget.user.goal; // Changed from targetSteps
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username cannot be empty')),
      );
      return;
    }

    final updatedUser = widget.user.copyWith(
      username: _usernameController.text.trim(),
      age: _age,
      weight: _weight,
      height: _height,
      gender: _sex,
      goal: _goal, // Changed from targetSteps
    );

    widget.onSave(updatedUser);
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
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
                    onChanged: (value) => setState(() => _age = value.toInt()),
                    activeColor: Color(0xFFC16200),
                  ),
                  SizedBox(height: 16),
                  Text('Weight: ${_weight.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  Slider(
                    value: _weight,
                    min: 30,
                    max: 200,
                    divisions: 170,
                    label: '${_weight.toStringAsFixed(1)} kg',
                    onChanged: (value) => setState(() => _weight = value),
                    activeColor: Color(0xFFC16200),
                  ),
                  SizedBox(height: 16),
                  Text('Height: ${_height.toStringAsFixed(0)} cm', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                  Slider(
                    value: _height,
                    min: 120,
                    max: 220,
                    divisions: 100,
                    label: '${_height.toStringAsFixed(0)} cm',
                    onChanged: (value) => setState(() => _height = value),
                    activeColor: Color(0xFFC16200),
                  ),
                  SizedBox(height: 16),
                  Text('Daily Step Goal: $_goal', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black)), // Changed label
                  Slider(
                    value: _goal.toDouble(), // Changed
                    min: 5000,
                    max: 20000,
                    divisions: 30,
                    label: '$_goal', // Changed
                    onChanged: (value) => setState(() => _goal = (value / 500).round() * 500), // Changed
                    activeColor: Color(0xFFC16200),
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
                      child: Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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