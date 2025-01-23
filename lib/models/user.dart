/* File contains the User model */

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String id;
  String ?adminId;  // For an admin user
  String ?parentAdminId;  // For an employee user
  String ?employeeId;  // For an employee user
  DateTime createdAt;

  AppUser({
    this.id = '',
    this.adminId,
    this.parentAdminId,
    this.employeeId,
    DateTime? createdAt
  }) : createdAt = createdAt ?? DateTime.now();

  static AppUser fromMap(Map<dynamic, dynamic> user) {
    return AppUser(
        id: user['id'],
        adminId: user['adminId'],
        parentAdminId: user['parentAdminId'],
        employeeId: user['employeeId'],
        createdAt: user['createdAt'] != null && user['createdAt'] is Timestamp
            ? (user['createdAt'] as Timestamp).toDate() // Convert Timestamp to DateTime
            : user['createdAt'],
    );
  }

  toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'parentAdminId': parentAdminId,
      'employeeId': employeeId,
      'createdAt': createdAt,
    };
  }
}