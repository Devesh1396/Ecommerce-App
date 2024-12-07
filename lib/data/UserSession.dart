import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/user/states.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  String? token;
  String? username;

  factory UserSession() => _instance;

  UserSession._internal();

  void loadUserSession(UserState state) {
    if (state is UserSessionLoadedState) {
      token = state.token;
      username = state.username;
    }
  }

  void clearSession() {
    token = null;
    username = null;
  }

  Future<void> saveTokenToPrefs(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveNameToPrefs(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }

  Future<String?> getNameFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

}
