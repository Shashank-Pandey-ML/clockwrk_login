
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:clockwrk_login/models/employee.dart';

class DbHelper {
  final DatabaseReference _employeesDbReference = FirebaseDatabase.instance.ref(
      "employees");

  /// Function to get add a new employee to the DB
  Future addEmployee(Employee employee) async {
    DatabaseReference postEmployeesDbReference = _employeesDbReference.push();
    await postEmployeesDbReference.set(employee.toMap());
  }

  /// Function to get all the employees
  Future<List<Employee>> getEmployees() async {
    // Fetch all employee data.
    DataSnapshot employeesSnapshot = await _employeesDbReference.get();
    List<Employee> employees = [];

    // Check if the event has data.
    for (var child in employeesSnapshot.children) {
      employees.add(Employee.fromMap(child.value as Map<dynamic, dynamic>));
    }

    return employees;
  }

  /// Function to get employee by its mobile number
  Future<Employee?> getEmployeeByMobileNumber(String mobileNumber) async {
    DataSnapshot snapshot =
    await _employeesDbReference.orderByChild("mobile_number").equalTo(mobileNumber).get();

    if (snapshot.exists) return Employee.fromMap(snapshot.value as Map<String, dynamic>);

    return null;
  }

  /// Function to get employee by its email
  Future<Employee?> getEmployeeByEmail(String email) async {
    DataSnapshot snapshot =
    await _employeesDbReference.orderByChild("email").equalTo(email).get();

    if (snapshot.exists) return Employee.fromMap(snapshot.value as Map<String, dynamic>);

    return null;
  }

  /// Function to get employee by its face (model data)
  Future<Employee?> getEmployeeByModelData(List predictedModelData) async {
    List<Employee> employees = await getEmployees();

    Employee? predictedResult;

    // // Calculated using euclidean distance
    // double minDist = 999;
    // double currDist = 0.0;
    // double threshold = 0.5;
    //
    // for (Employee employee in employees) {
    //   currDist = _euclideanDistance(employee.modelData, predictedModelData);
    //   if (currDist <= threshold && currDist < minDist) {
    //     minDist = currDist;
    //     predictedResult = employee;
    //   }
    // }

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

  /// (deprecated) Function to calculate the euclidean distance between 2 vectors (model
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

}