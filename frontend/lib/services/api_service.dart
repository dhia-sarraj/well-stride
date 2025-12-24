import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/steps_model.dart';
import '../models/mood_model.dart';
import 'token_service.dart';

class ApiService {
  static const String baseUrl = 'https://wellstride.onrender.com/api';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final TokenService _tokenService = TokenService();

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Handle API errors
  String _handleError(http.Response response) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    try {
      final error = json.decode(response.body);

      if (response.statusCode == 401) {
        return error['message'] ?? 'Invalid email or password';
      } else if (response.statusCode == 404) {
        return error['message'] ?? 'Resource not found';
      } else if (response.statusCode >= 500) {
        return 'Server error. Please try again later.';
      } else if (response.statusCode == 400) {
        return error['message'] ?? 'Invalid request';
      } else if (response.statusCode == 409) {
        return error['message'] ?? 'User already exists';
      } else {
        return error['message'] ?? error['error'] ?? 'An error occurred';
      }
    } catch (e) {
      if (response.statusCode == 401) {
        return 'Invalid email or password';
      }
      return 'An error occurred. Please try again.';
    }
  }

  // ==================== AUTH ENDPOINTS ====================

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String passwordConf,
  }) async {
    try {
      print('Attempting registration for: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'passwordConf': passwordConf,
          'provider': 'Email',
        }),
      );

      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      print('Registration error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Login user and store tokens
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting login for: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['accessToken'] == null || data['refreshToken'] == null) {
          print('Warning: Tokens not found in response');
          throw Exception('Invalid response format from server');
        }

        await _tokenService.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );

        print('Tokens saved successfully');
        return data;
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      print('Login error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Refresh access token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        await _tokenService.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: refreshToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'refreshToken': refreshToken}),
        );
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _tokenService.clearTokens();
    }
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/password/forgot'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Password reset request failed: ${e.toString()}');
    }
  }

  /// Reset password with token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  /// Change password (logged in user)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/password/change'),
        headers: await _getHeaders(),
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Password change failed: ${e.toString()}');
    }
  }

  // ==================== PROFILE ENDPOINTS ====================

  /// Create user profile
  Future<Map<String, dynamic>> createProfile({
    required String username,
    String? photoUrl,
    required int age,
    required String gender,
    required double height,
    required double weight,
    int goal = 10000, // Changed from targetSteps, with default
  }) async {
    try {
      print('Creating profile for username: $username');

      final response = await http.post(
        Uri.parse('$baseUrl/profile/me'),
        headers: await _getHeaders(),
        body: json.encode({
          'username': username,
          'photoUrl': photoUrl,
          'age': age,
          'gender': gender,
          'height': height,
          'weight': weight,
          'goal': goal, // Changed from targetSteps
        }),
      );

      print('Create profile response status: ${response.statusCode}');
      print('Create profile response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      print('Profile creation error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Profile creation failed: ${e.toString()}');
    }
  }

  /// Get user profile
  Future<UserModel?> getProfile() async {
    try {
      print('Fetching user profile...');

      final response = await http.get(
        Uri.parse('$baseUrl/profile/me'),
        headers: await _getHeaders(),
      );

      print('Profile API Response Status: ${response.statusCode}');
      print('Profile API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final profile = UserModel.fromJson(data);
        print('Profile parsed successfully: ${profile.username}');
        return profile;
      } else if (response.statusCode == 404) {
        print('Profile not found (404)');
        return null;
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      print('Get profile error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? username,
    String? photoUrl,
    int? age,
    String? gender,
    double? height,
    double? weight,
    int? goal, // Changed from targetSteps
  }) async {
    try {
      final body = <String, dynamic>{};
      if (username != null) body['username'] = username;
      if (photoUrl != null) body['photoUrl'] = photoUrl;
      if (age != null) body['age'] = age;
      if (gender != null) body['gender'] = gender;
      if (height != null) body['height'] = height;
      if (weight != null) body['weight'] = weight;
      if (goal != null) body['goal'] = goal; // Changed from targetSteps

      print('Updating profile with data: $body');

      final response = await http.patch(
        Uri.parse('$baseUrl/profile/me'),
        headers: await _getHeaders(),
        body: json.encode(body),
      );

      print('Update profile response status: ${response.statusCode}');
      print('Update profile response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data); // Return the updated profile
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      print('Profile update error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  /// Profile Photo
  Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      print('Uploading profile photo...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/me/photo'),
      );
      request.headers.addAll(await _getHeaders());
      request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

      var response = await request.send();

      print('Upload photo response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var data = json.decode(await response.stream.bytesToString());
        print('Photo uploaded successfully: ${data['photoUrl']}');
        return data['photoUrl'];
      }
      throw Exception('Photo upload failed');
    } catch (e) {
      print('Photo upload error: $e');
      throw Exception('Photo upload failed');
    }
  }

  // ==================== STEPS ENDPOINTS ====================

  /// Create or update daily step summary
  Future<void> updateSteps({
    required String date,
    required int stepCount,
    required int goal,
    double? distanceMeters,
    int? activeMinutes,
    int? stairsClimbed,
    int? caloriesEstimated,
    String source = 'Googlefit',
  }) async {
    try {
      print('Updating steps for date: $date, stepCount: $stepCount, goal: $goal');

      final response = await http.post(
        Uri.parse('$baseUrl/steps'),
        headers: await _getHeaders(),
        body: json.encode({
          'date': date,
          'stepCount': stepCount,
          'goal': goal,
          'distanceMeters': distanceMeters,
          'activeMinutes': activeMinutes,
          'stairsClimbed': stairsClimbed,
          'caloriesEstimated': caloriesEstimated,
          'source': source,
        }),
      );

      print('Update steps response status: ${response.statusCode}');
      print('Update steps response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      print('Update steps error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to update steps: ${e.toString()}');
    }
  }

  /// Get today's steps
  Future<StepsModel?> getTodaySteps() async {
    try {
      print('Fetching today\'s steps...');

      final response = await http.get(
        Uri.parse('$baseUrl/steps/today'),
        headers: await _getHeaders(),
      );

      print('Steps API Response Status: ${response.statusCode}');
      print('Steps API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final steps = StepsModel.fromJson(data);
        print('Steps parsed successfully: ${steps.steps} steps');
        return steps;
      } else if (response.statusCode == 404) {
        print('No steps found for today (404)');
        return null;
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      print('Get today steps error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to get today\'s steps: ${e.toString()}');
    }
  }

  /// Get step logs for a date range
  Future<List<StepsModel>> getStepsLogs(String from, String to) async {
    try {
      print('Fetching step logs from $from to $to');

      final uri = Uri.parse('$baseUrl/steps').replace(queryParameters: {
        'from': from,
        'to': to,
      });

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      print('Get steps logs response status: ${response.statusCode}');
      print('Get steps logs response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        final stepsList = data.map((json) => StepsModel.fromJson(json)).toList();
        print('Fetched ${stepsList.length} step records');
        return stepsList;
      } else if (response.statusCode == 404) {
        print('No step logs found (404)');
        return [];
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      print('Get steps logs error: $e');
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Failed to get step logs: ${e.toString()}');
    }
  }

  // ==================== QUOTES ENDPOINTS ====================

  /// Get random quote
  Future<String> getRandomQuote() async {
    try {
      print('Fetching random quote...');

      final response = await http.get(
        Uri.parse('$baseUrl/quotes/random'),
        headers: await _getHeaders(),
      );

      print('Get quote response status: ${response.statusCode}');
      print('Get quote response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final quote = data['text'] ?? data['quote'] ?? 'Stay positive!';
        print('Quote fetched: $quote');
        return quote;
      } else {
        return 'Every step forward is progress!';
      }
    } catch (e) {
      print('Get quote error: $e');
      return 'Keep moving forward!';
    }
  }

  // ==================== MOOD ENDPOINTS ====================

  /// Create a mood record
  Future<MoodModel?> createMood({
    required String emoji,
    String? reason,
    String? note,
  }) async {
    try {
      print('Creating mood: emoji=$emoji, reason=$reason');

      final response = await http.post(
        Uri.parse('$baseUrl/moods'),
        headers: await _getHeaders(),
        body: json.encode({
          'emoji': emoji,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
          if (note != null && note.isNotEmpty) 'note': note,
        }),
      );

      print('Create mood response status: ${response.statusCode}');
      print('Create mood response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return MoodModel.fromJson(data);
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      print('Create mood error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to create mood: ${e.toString()}');
    }
  }

  /// Get mood logs for a date range
  Future<List<MoodModel>> getMoodLogs(String from, String to) async {
    try {
      print('Fetching mood logs from $from to $to');

      final uri = Uri.parse('$baseUrl/moods').replace(queryParameters: {
        'from': from,
        'to': to,
      });

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      print('Get mood logs response status: ${response.statusCode}');
      print('Get mood logs response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        final moodList = data.map((json) => MoodModel.fromJson(json)).toList();
        print('Fetched ${moodList.length} mood records');
        return moodList;
      } else if (response.statusCode == 404) {
        print('No mood logs found (404)');
        return [];
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      print('Get mood logs error: $e');
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Failed to get mood logs: ${e.toString()}');
    }
  }

  /// Get today's mood (helper method)
  Future<MoodModel?> getTodayMood() async {
    try {
      print('Fetching today\'s mood...');
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final moods = await getMoodLogs(today, today);
      final todayMood = moods.isNotEmpty ? moods.last : null;
      print('Today\'s mood: ${todayMood?.emoji ?? 'Not set'}');
      return todayMood;
    } catch (e) {
      print('Get today mood error: $e');
      return null;
    }
  }

  // ==================== USER ENDPOINTS ====================

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      print('Deleting user account...');

      final response = await http.delete(
        Uri.parse('$baseUrl/users/me'),
        headers: await _getHeaders(),
      );

      print('Delete account response status: ${response.statusCode}');
      print('Delete account response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _tokenService.clearTokens();
        print('Account deleted successfully');
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      print('Delete account error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }
}