import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/models/user_model.dart';
import 'package:zorvyn/services/api_service.dart';
import 'package:zorvyn/services/local_storage_service.dart';
import 'package:zorvyn/services/push_notification_service.dart';

class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.token, this.isLoading = false, this.error});

  AuthState copyWith({User? user, String? token, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => token != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;

  AuthNotifier(this._api) : super(const AuthState());

  /// Request notification permission and register device token with backend
  Future<void> _registerPush() async {
    await PushNotificationService.requestPermission();
    await PushNotificationService.registerDeviceToken(_api);
    PushNotificationService.listenTokenRefresh(_api);
  }

  Future<void> checkAuth() async {
    final token = LocalStorageService.getToken();
    if (token == null) return;

    state = state.copyWith(token: token, isLoading: true);
    try {
      final res = await _api.get('/auth/me');
      final user = User.fromJson(res['user'] ?? res);
      state = AuthState(user: user, token: token);
      _registerPush();
    } on UnauthorizedException {
      await LocalStorageService.clearToken();
      state = const AuthState();
    } catch (e) {
      state = AuthState(token: token);
    }
  }

  Future<String?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = res['token']?.toString() ?? '';
      final user = User.fromJson(res['user'] ?? {});
      await LocalStorageService.setToken(token);
      state = AuthState(user: user, token: token);
      _registerPush();
      return null;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return e.message;
    } catch (_) {
      const msg = 'Something went wrong. Please try again.';
      state = state.copyWith(isLoading: false, error: msg);
      return msg;
    }
  }

  Future<String?> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      final token = res['token']?.toString() ?? '';
      final user = User.fromJson(res['user'] ?? {});
      await LocalStorageService.setToken(token);
      state = AuthState(user: user, token: token);
      _registerPush();
      return null;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return e.message;
    } catch (_) {
      const msg = 'Registration failed. Please try again.';
      state = state.copyWith(isLoading: false, error: msg);
      return msg;
    }
  }

  Future<String?> forgotPassword(String email) async {
    try {
      final res = await _api.post('/auth/forgot-password', data: {'email': email});
      return res['resetToken']?.toString();
    } on AppException catch (e) {
      return 'ERROR:${e.message}';
    } catch (_) {
      return 'ERROR:Something went wrong.';
    }
  }

  Future<String?> resetPassword(String token, String newPassword) async {
    try {
      await _api.post('/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong.';
    }
  }

  Future<String?> changePassword(String currentPassword, String newPassword) async {
    try {
      await _api.post('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong.';
    }
  }

  Future<String?> updateProfile(String name, String email) async {
    try {
      final res = await _api.put('/auth/profile', data: {
        'name': name,
        'email': email,
      });
      final user = User.fromJson(res['user'] ?? res);
      state = state.copyWith(user: user);
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong.';
    }
  }

  Future<String?> refreshToken() async {
    try {
      final res = await _api.post('/auth/refresh-token');
      final newToken = res['token']?.toString();
      if (newToken != null) {
        await LocalStorageService.setToken(newToken);
        state = state.copyWith(token: newToken);
      }
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Token refresh failed.';
    }
  }

  Future<String?> deleteAccount() async {
    try {
      await _api.delete('/auth/account');
      await logout();
      return null;
    } on AppException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong.';
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Best-effort — clear local state regardless
    }
    await LocalStorageService.clearAll();
    state = const AuthState();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});
