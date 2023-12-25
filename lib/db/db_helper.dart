
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:clockwrk_login/models/user.dart';

class DbHelper {
  final DatabaseReference _usersDbReference = FirebaseDatabase.instance.ref(
      "users");

  Future addUser(User user) async {
    DatabaseReference postUsersDbReference = _usersDbReference.push();
    await postUsersDbReference.set(user.toMap());
  }

  Future<List<User>> getUsers() async {
    // Fetch all user data.
    DataSnapshot usersSnapshot = await _usersDbReference.get();
    List<User> users = [];

    // Check if the event has data.
    for (var child in usersSnapshot.children) {
      users.add(User.fromMap(child.value as Map<dynamic, dynamic>));
    }

    return users;
  }

  Future<User?> getUserByMobileNumber(String mobileNumber) async {
    DataSnapshot snapshot =
    await _usersDbReference.orderByChild("mobile_number").equalTo(mobileNumber).get();

    if (snapshot.exists) return User.fromMap(snapshot.value as Map<String, dynamic>);

    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    DataSnapshot snapshot =
    await _usersDbReference.orderByChild("email").equalTo(email).get();

    if (snapshot.exists) return User.fromMap(snapshot.value as Map<String, dynamic>);

    return null;
  }

  Future<User?> getUserByModelData(List predictedModelData) async {
    List<User> users = await getUsers();

    double minDist = 999;
    double currDist = 0.0;
    double threshold = 0.5;

    User? predictedResult;

    for (User user in users) {
      currDist = _euclideanDistance(user.modelData, predictedModelData);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predictedResult = user;
      }
    }
    return predictedResult;
  }

  double _euclideanDistance(List? e1, List? e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

}