/* File contains the User model */

import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  String id;
  String employeeId;
  DateTime checkedInAt;
  DateTime? checkedOutAt;

  Attendance({
    this.id = '',
    required this.employeeId,
    DateTime? checkedInAt,
    DateTime? checkedOutAt,
  }) : checkedInAt = checkedInAt ?? DateTime.now();

  static Attendance fromMap(Map<dynamic, dynamic> user) {
    return Attendance(
      id: user['id'],
      employeeId: user['employeeId'],
      checkedInAt: user['checkedInAt'] != null && user['checkedInAt'] is Timestamp
          ? (user['checkedInAt'] as Timestamp).toDate() // Convert Timestamp to DateTime
          : user['checkedInAt'],
      checkedOutAt: user['checkedOutAt'] != null && user['checkedOutAt'] is Timestamp
          ? (user['checkedOutAt'] as Timestamp).toDate() // Convert Timestamp to DateTime
          : user['checkedOutAt'],
    );
  }

  toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'checkedInAt': checkedInAt,
      'checkedOutAt': checkedOutAt,
    };
  }
}