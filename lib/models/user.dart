/* File contains the User model */

import 'dart:convert';
import 'dart:ffi';

class User {
  String name;
  String mobileNo;
  String email;
  double salaryPerHour;
  String currency;
  List modelData;

  User({required this.name, required this.mobileNo, this.email="", required this.salaryPerHour,
    required this.modelData, this.currency = "Pound"});

  static User fromMap(Map<dynamic, dynamic> user) {
    return User(
      name: user['name'],
      mobileNo: user['mobile_number'],
      email: user['email'],
      salaryPerHour: user['salary_per_hour'].toDouble(),
      currency: user['currency'],
      modelData: jsonDecode(user['model_data']),
    );
  }

  toMap() {
    return {
      'name': name,
      'mobile_number': mobileNo,
      'email': email,
      'salary_per_hour': salaryPerHour,
      'currency': currency,
      'model_data': jsonEncode(modelData),
    };
  }
}