/* File contains the Employee model */

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  String id;
  String name;
  String mobileNo;
  String email;
  double ?salaryPerHour;
  String currency;
  List ?modelData;
  String adminId;
  String? photoURL;
  DateTime createdAt;
  String? userId;

  Employee({
    this.id = '',
    required this.name,
    required this.mobileNo,
    this.email="",
    required this.adminId,
    this.salaryPerHour,
    this.modelData,
    this.currency = "Rupees",
    this.photoURL,
    this.userId,
    DateTime? createdAt
  }) : createdAt = createdAt ?? DateTime.now();

  static Employee fromMap(Map<dynamic, dynamic> employee) {
    return Employee(
      id: employee['id'],
      name: employee['name'],
      mobileNo: employee['mobileNo'],
      email: employee['email'],
      adminId: employee['adminId'],
      salaryPerHour: employee['salaryPerHour']?.toDouble(),
      currency: employee['currency'],
      modelData: jsonDecode(employee['modelData']),
      photoURL: employee['photoURL'],
      userId: employee['userId'],
      createdAt: employee['createdAt'] != null && employee['createdAt'] is Timestamp
          ? (employee['createdAt'] as Timestamp).toDate() // Convert Timestamp to DateTime
          : employee['createdAt'],
    );
  }

  toMap() {
    return {
      'id': id,
      'name': name,
      'mobileNo': mobileNo,
      'email': email,
      'adminId': adminId,
      'salaryPerHour': salaryPerHour,
      'currency': currency,
      'modelData': jsonEncode(modelData),
      'photoURL': photoURL,
      'userId': userId,
      'createdAt': createdAt,
    };
  }
}