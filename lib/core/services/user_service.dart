import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class UserService {
  static const String _nameKey = 'user_name';
  static const String _handleKey = 'user_handle';
  static const String _profileImageKey = 'user_profile_image';

  final SharedPreferences _prefs;

  UserService(this._prefs);

  String getName() => _prefs.getString(_nameKey) ?? 'Shithin Cp';
  String getHandle() => _prefs.getString(_handleKey) ?? '@shithincp1484';
  String? getProfileImagePath() => _prefs.getString(_profileImageKey);

  Future<void> updateProfile({
    String? name,
    String? handle,
    String? profileImagePath,
  }) async {
    if (name != null) await _prefs.setString(_nameKey, name);
    if (handle != null) await _prefs.setString(_handleKey, handle);
    if (profileImagePath != null) {
      await _prefs.setString(_profileImageKey, profileImagePath);
    }
  }
}
