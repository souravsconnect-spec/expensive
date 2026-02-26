import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String _keyToken = "auth_token";
  static const String _keyNickname = "user_nickname";
  static const String _keyBudgetLimit = "budget_limit";
  static const String _keyUserId = "user_id";
  static const String _keyWelcomeSeen = "welcome_seen";

  Future<void> saveAuthData(
    String token,
    String nickname,
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyNickname, nickname);
    await prefs.setString(_keyUserId, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<void> saveNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNickname, nickname);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<String?> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNickname);
  }

  Future<void> saveBudgetLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getUserId() ?? "default";
    await prefs.setDouble("${_keyBudgetLimit}_$userId", limit);
  }

  Future<double> getBudgetLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getUserId() ?? "default";
    return prefs.getDouble("${_keyBudgetLimit}_$userId") ?? 1000.0;
  }

  static const String _keyDataRestored = "is_data_restored";

  Future<void> setDataRestored(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getUserId() ?? "default";
    await prefs.setBool("${_keyDataRestored}_$userId", value);
  }

  Future<bool> isDataRestored() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getUserId() ?? "default";
    return prefs.getBool("${_keyDataRestored}_$userId") ?? false;
  }

  Future<void> setWelcomeSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWelcomeSeen, value);
  }

  Future<bool> isWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyWelcomeSeen) ?? false;
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
