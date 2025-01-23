
import 'dart:math';

import 'package:clockwrk_login/models/attendance.dart';
import 'package:clockwrk_login/pages/widgets/common.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clockwrk_login/models/employee.dart';

import '../models/admin.dart';
import '../models/user.dart';

class DbHelper {
  final CollectionReference _adminsCollectionRef = FirebaseFirestore.instance.collection("admins");
  final CollectionReference _usersCollectionRef = FirebaseFirestore.instance.collection("users");

  /// Function to get create a new employee
  Future createEmployee(String adminId, Employee employee) async {
    DocumentReference docRef = _adminsCollectionRef
        .doc(adminId)
        .collection("employees")
        .doc();
    employee.id = docRef.id; // Assign the ID to the employee
    await docRef.set(employee.toMap());
  }

  /// Function to get all the employees
  Future<List<Employee>> getEmployees(String adminId) async {
    // Fetch all employee documents.
    QuerySnapshot employeesSnapshot = await _adminsCollectionRef
        .doc(adminId)
        .collection("employees")
        .get();

    List<Employee> employees = [];

    // Check if the event has data.
    for (var doc in employeesSnapshot.docs) {
      employees.add(Employee.fromMap(doc.data() as Map<String, dynamic>));
    }

    return employees;
  }

  /// Function to get employee by its document ID.
  Future<Employee?> getEmployeeByDocId(String adminId, String employeeId) async {
    // Get the document with the specified ID.
    DocumentSnapshot docSnapshot = await _adminsCollectionRef
        .doc(adminId)
        .collection("employees")
        .doc(employeeId)
        .get();

    if (docSnapshot.exists) {
      // Convert the document data to an Admin object.
      return Employee.fromMap(docSnapshot.data() as Map<String, dynamic>);
    }

    return null;
  }

  /// Function to get employee by its mobile number
  Future<Employee?> getEmployeeByMobileNumber(String adminId, String mobileNumber) async {
    // Query to find the employee by mobile number.
    QuerySnapshot snapshot = await _adminsCollectionRef
        .doc(adminId)
        .collection("employees")
        .where('mobileNumber', isEqualTo: mobileNumber)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Assuming there is only one employee with this mobile number.
      var doc = snapshot.docs.first;
      return Employee.fromMap(doc.data() as Map<String, dynamic>);
    }

    return null;
  }

  /// Function to get employee by its email
  Future<Employee?> getEmployeeByEmail(String adminId, String email) async {
    // Query to find the employee by email.
    QuerySnapshot snapshot = await _adminsCollectionRef
        .doc(adminId)
        .collection("employees")
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Assuming there is only one employee with this email.
      var doc = snapshot.docs.first;
      return Employee.fromMap(doc.data() as Map<String, dynamic>);
    }

    return null;
  }

  /// Function to get employee by its userId
  Future<Employee?> getEmployeeByUserId(String adminId, String userId) async {
    // Query to find the employee by email.
    QuerySnapshot snapshot = await _adminsCollectionRef
        .doc(adminId)
        .collection("employees")
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Assuming there is only one employee with this email.
      var doc = snapshot.docs.first;
      return Employee.fromMap(doc.data() as Map<String, dynamic>);
    }

    return null;
  }

  /// Function to get employee by its face (model data)
  Future<Employee?> getEmployeeByModelData(String adminId, List predictedModelData) async {
    List<Employee> employees = await getEmployees(adminId);

    Employee? predictedResult;

    // Calculated using cosine similarity
    double maxDist = -1.0;
    double currDist = 0.0;
    double threshold = 0.6;

    for (Employee employee in employees) {
      currDist = _cosineSimilarity(employee.modelData, predictedModelData);
      if (currDist >= threshold && currDist > maxDist) {
        maxDist = currDist;
        predictedResult = employee;
      }
    }

    return predictedResult;
  }

  /// (Deprecated) Function to calculate the euclidean distance between 2 vectors (model
  /// data of 2 faces)
  double _euclideanDistance(List? e1, List? e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");
    if (e1.length != e2.length) throw Exception("Lists must be of the same length");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  /// Function to calculate the cosine similarity distance between 2 vectors
  /// (model data of 2 faces). To find whether they are the same people of not.
  double _cosineSimilarity(List? e1, List? e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");
    if (e1.length != e2.length) throw Exception("Lists must be of the same length");

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < e1.length; i++) {
      dotProduct += e1[i] * e2[i];
      norm1 += pow(e1[i], 2);
      norm2 += pow(e2[i], 2);
    }

    if (norm1 == 0.0 || norm2 == 0.0) throw Exception("One of the vectors is zero vector");

    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }

  Future<void> checkInEmployee(String adminId, String employeeId) async {
    // Query for the most recent attendance record where checkedOutAt is null
    QuerySnapshot querySnapshot = await _adminsCollectionRef
        .doc(adminId)
        .collection('employees')
        .doc(employeeId)
        .collection('attendance')
        .where('checkedOutAt', isEqualTo: null)
        .orderBy('checkedInAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      Attendance attendance = Attendance.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
      showToast("Already checked-in at ${attendance.checkedInAt}", timeInSec: 5);
    } else {
      DocumentReference docRef = _adminsCollectionRef
          .doc(adminId)
          .collection("employees")
          .doc(employeeId)
          .collection("attendance")
          .doc();

      Attendance attendance = Attendance(employeeId: employeeId);
      attendance.id = docRef.id; // Assign the ID to the employee
      await docRef.set(attendance.toMap());
      showToast("Check-in successful");
    }
  }

  Future<void> checkOutEmployee(String adminId, String employeeId) async {
    // Query for the most recent attendance record where checkedOutAt is null
    QuerySnapshot querySnapshot = await _adminsCollectionRef
        .doc(adminId)
        .collection('employees')
        .doc(employeeId)
        .collection('attendance')
        .where('checkedOutAt', isEqualTo: null)
        .orderBy('checkedInAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      // Update the attendance record with the current date and time as the check-out time
      await doc.reference.update({
        'checkedOutAt': DateTime.now(),
      });
      showToast("Check-out successful");
    } else {
      showToast("No check-in record found for check-out", timeInSec: 5);
    }
  }

  /// Function to get create a new admin
  Future<Admin> createAdmin(Admin admin) async {
    DocumentReference docRef = _adminsCollectionRef.doc();
    admin.id = docRef.id; // Assign the ID to the employee
    await docRef.set(admin.toMap());
    return admin;
  }

  /// Function to get all the admins
  Future<List<Admin>> getAdmins() async {
    // Fetch all admin documents.
    QuerySnapshot usersSnapshot = await _adminsCollectionRef.get();

    List<Admin> admins = [];

    // Check if the event has data.
    for (var doc in usersSnapshot.docs) {
      admins.add(Admin.fromMap(doc.data() as Map<String, dynamic>));
    }

    return admins;
  }

  /// Function to get admin by its document ID.
  Future<Admin?> getAdminByDocId(String docId) async {
    // Get the document with the specified ID.
    DocumentSnapshot docSnapshot = await _adminsCollectionRef.doc(docId).get();

    if (docSnapshot.exists) {
      // Convert the document data to an Admin object.
      return Admin.fromMap(docSnapshot.data() as Map<String, dynamic>);
    }

    return null;
  }

  /// Function to get admin by its mobile number
  Future<Admin?> getAdminByMobileNumber(String mobileNumber) async {
    // Query to find the admin by mobile number.
    QuerySnapshot snapshot = await _adminsCollectionRef
        .where('mobileNumber', isEqualTo: mobileNumber)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Assuming there is only one admin with this mobile number.
      var doc = snapshot.docs.first;
      return Admin.fromMap(doc.data() as Map<String, dynamic>);
    }

    return null;
  }

  /// Function to get admin by its email
  Future<Admin?> getAdminByEmail(String email) async {
    // Query to find the admin by email.
    QuerySnapshot snapshot = await _adminsCollectionRef
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Assuming there is only one admin with this email.
      var doc = snapshot.docs.first;
      return Admin.fromMap(doc.data() as Map<String, dynamic>);
    }

    return null;
  }

  /// Function to get admin by its userId
  Future<Admin?> getAdminByUserId(String userId) async {
    // Query to find the admin by email.
    QuerySnapshot snapshot = await _adminsCollectionRef
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Assuming there is only one admin with this email.
      var doc = snapshot.docs.first;
      return Admin.fromMap(doc.data() as Map<String, dynamic>);
    }

    return null;
  }

  /// Function to get filtered results for admin
  Future<List<Admin>> getFilteredAdmin(Map<String, dynamic> filters) async {
    Query query = _adminsCollectionRef;

    // Apply filters to the query
    filters.forEach((field, value) {
      query = query.where(field, isEqualTo: value);
    });

    // Fetch the query snapshot
    QuerySnapshot querySnapshot = await query.get();

    // Assuming there is only one admin with this email.
    List<Admin> admins = [];

    // Check if the event has data.
    for (var doc in querySnapshot.docs) {
      admins.add(Admin.fromMap(doc.data() as Map<String, dynamic>));
    }

    return admins;
  }

  /// Function to get user by its document ID.
  Future<AppUser?> getUserByDocId(String docId) async {
    // Get the document with the specified ID.
    DocumentSnapshot docSnapshot = await _usersCollectionRef.doc(docId).get();

    if (docSnapshot.exists) {
      // Convert the document data to an Admin object.
      return AppUser.fromMap(docSnapshot.data() as Map<String, dynamic>);
    }

    return null;
  }

  Future<void> setUserByDocId(String docId, AppUser user) async {
    user.id = docId;
    await _usersCollectionRef.doc(docId).set(user.toMap());
  }
}