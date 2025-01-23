/* File contains the Admin model */

import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  String id;
  String name;
  String mobileNo;
  String email;
  String? photoURL;
  String userId;
  DateTime createdAt;

  Admin({
    this.id = '',
    required this.name,
    required this.mobileNo,
    required this.email,
    this.photoURL,
    required this.userId,
    DateTime? createdAt
  }) : createdAt = createdAt ?? DateTime.now();

  static Admin fromMap(Map<dynamic, dynamic> admin) {
    return Admin(
      id: admin['id'],
      name: admin['name'],
      mobileNo: admin['mobileNo'],
      email: admin['email'],
      photoURL: admin['photoURL'],
      userId: admin['userId'],
      createdAt: admin['createdAt'] != null && admin['createdAt'] is Timestamp
          ? (admin['createdAt'] as Timestamp).toDate() // Convert Timestamp to DateTime
          : admin['createdAt'],
    );
  }

  toMap() {
    return {
      'id': id,
      'name': name,
      'mobileNo': mobileNo,
      'email': email,
      'photoURL': photoURL,
      'userId': userId,
      'createdAt': createdAt,
    };
  }
}