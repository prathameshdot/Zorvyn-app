import 'package:shared_preferences/shared_preferences.dart';
import 'package:zorvyn/config/constants.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;
  static const _notificationPromptKey = 'notification_prompted';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getToken() => _prefs.getString(AppConstants.tokenKey);

  static Future<void> setToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  static Future<void> clearToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }

  static bool getDarkMode() => _prefs.getBool('dark_mode') ?? false;

  static Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('dark_mode', value);
  }

  static bool getOnboardingDone() => _prefs.getBool('onboarding_done') ?? false;

  static Future<void> setOnboardingDone() async {
    await _prefs.setBool('onboarding_done', true);
  }

  static bool getNotificationPrompted() =>
      _prefs.getBool(_notificationPromptKey) ?? false;

  static Future<void> setNotificationPrompted() async {
    await _prefs.setBool(_notificationPromptKey, true);
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
