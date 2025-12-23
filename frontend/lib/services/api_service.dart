import 'dart:convert';
import 'package:http/http.dart' as http;
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

  // Handle API errors - IMPROVED
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
      // If response body is not JSON
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

        // Check if tokens exist in response
        if (data['accessToken'] == null || data['refreshToken'] == null) {
          print('Warning: Tokens not found in response');
          print('Response data keys: ${data.keys}');
          throw Exception('Invalid response format from server');
        }

        // Store tokens
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
  }) async {
    try {
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
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Profile creation failed: ${e.toString()}');
    }
  }

  /// Get user profile
  Future<UserModel?> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/me'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? photoUrl,
    int? age,
    String? gender,
    double? height,
    double? weight,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (username != null) body['username'] = username;
      if (photoUrl != null) body['photoUrl'] = photoUrl;
      if (age != null) body['age'] = age;
      if (gender != null) body['gender'] = gender;
      if (height != null) body['height'] = height;
      if (weight != null) body['weight'] = weight;

      final response = await http.patch(
        Uri.parse('$baseUrl/profile/me'),
        headers: await _getHeaders(),
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Profile update failed: ${e.toString()}');
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
    String source = 'GoogleFit',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/steps/me'),
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to update steps: ${e.toString()}');
    }
  }

  /// Get today's steps
  Future<StepsModel?> getTodaySteps() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/steps/me/today'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return StepsModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to get today\'s steps: ${e.toString()}');
    }
  }

  /// Get steps for specific date
  Future<StepsModel?> getStepsByDate(String date) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/steps/me/$date'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return StepsModel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to get steps: ${e.toString()}');
    }
  }

  /// Update step goal
  Future<void> updateStepGoal(int goal) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/steps/me/goal'),
        headers: await _getHeaders(),
        body: json.encode({'goal': goal}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to update step goal: ${e.toString()}');
    }
  }

  // ==================== QUOTES ENDPOINTS ====================

  /// Get random quote
  Future<String> getRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quotes/random'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['quote'] ?? data['text'] ?? 'Stay positive!';
      } else {
        return 'Every step forward is progress!';
      }
    } catch (e) {
      return 'Keep moving forward!';
    }
  }

  // ==================== USER ENDPOINTS ====================

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/me'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _tokenService.clearTokens();
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }
}