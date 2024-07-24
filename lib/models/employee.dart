/* File contains the Employee model */

import 'dart:convert';

class Employee {
  String name;
  String mobileNo;
  String email;
  double salaryPerHour;
  String currency;
  List modelData;

  Employee({required this.name, required this.mobileNo, this.email="", required this.salaryPerHour,
    required this.modelData, this.currency = "Pound"});

  static Employee fromMap(Map<dynamic, dynamic> employee) {
    return Employee(
      name: employee['name'],
      mobileNo: employee['mobile_number'],
      email: employee['email'],
      salaryPerHour: employee['salary_per_hour'].toDouble(),
      currency: employee['currency'],
      modelData: jsonDecode(employee['model_data']),
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