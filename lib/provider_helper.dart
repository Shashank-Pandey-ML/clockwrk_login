import 'package:flutter/material.dart';
import 'db/preferences_helper.dart';

class AdminDeviceModeModel with ChangeNotifier {
  bool _isAttendanceMode = false;

  bool get isAttendanceMode => _isAttendanceMode;

  AdminDeviceModeModel() {
    _loadPreference();
  }

  void _loadPreference() async {
    _isAttendanceMode = await PreferencesHelper.getAdminDeviceModePreference() ?? false;
    notifyListeners();
  }

  void toggleAdminDeviceMode() {
    _isAttendanceMode = !_isAttendanceMode;
    PreferencesHelper.saveAdminDeviceModePreference(isAttendanceMode: _isAttendanceMode);
    notifyListeners();
  }
}

class ThemeModel with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeModel() {
    _loadPreference();
  }

  void _loadPreference() async {
    _isDarkMode = await PreferencesHelper.getDarkModePreference() ?? false;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    PreferencesHelper.saveDarkModePreference(_isDarkMode);
    notifyListeners();
  }
}
