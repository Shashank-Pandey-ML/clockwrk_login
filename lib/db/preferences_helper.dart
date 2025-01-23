import 'dart:convert';

import 'package:clockwrk_login/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static Future<bool> saveAdminDeviceModePreference({required bool isAttendanceMode}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('isAttendanceMode', isAttendanceMode);
  }

  static Future<bool?> getAdminDeviceModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAttendanceMode');
  }

  static Future<void> deleteAdminDeviceModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isAttendanceMode');
  }

  static Future<bool> saveUserPreference(AppUser user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('user', _customJsonEncode(user.toMap()));
  }

  static Future<AppUser?> getUserPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJsonString = prefs.getString('user');
    if (userJsonString != null){
      return AppUser.fromMap(_customJsonDecode(userJsonString));
    }
    return null;
  }

  static Future<void> deleteUserPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
  }

  static Future<bool> saveDarkModePreference(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('isDarkMode', isDarkMode);
  }

  static Future<bool?> getDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode');
  }

  static Future<void> deleteDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isDarkMode');
  }

  static String _customJsonEncode(Map<String, dynamic> mapObj) {
    // Create a new map to hold the converted values
    final Map<String, dynamic> convertedMap = {};

    // Iterate through each key-value pair in the original map
    mapObj.forEach((key, value) {
      // Check if the value is a DateTime object
      if (value is DateTime) {
        // Convert DateTime to a string using toIso8601String
        convertedMap[key] = value.toIso8601String();
      } else {
        // Otherwise, keep the original value
        convertedMap[key] = value;
      }
    });

    return jsonEncode(convertedMap);
  }

  static Map<String, dynamic> _customJsonDecode(String jsonString) {
    // Decode the JSON string into a map
    Map<String, dynamic> jsonMap = {};

    // Iterate through each key-value pair in the original map
    jsonDecode(jsonString).forEach((key, value) {
      // Check if the value is a DateTime object
      if (value is String) {
        // Attempt to parse the string as a DateTime
        try {
          DateTime dateTime = DateTime.parse(value);
          jsonMap[key] = dateTime; // Store as DateTime if successful
        } catch (e) {
          jsonMap[key] = value; // Keep original value if parsing fails
        }
      } else {
        // Otherwise, keep the original value
        jsonMap[key] = value;
      }
    });

    return jsonMap;
  }

  static Future<void> resetUserPreference() async {
    await deleteAdminDeviceModePreference();
    await deleteUserPreference();
    // await deleteDarkModePreference();
  }
}