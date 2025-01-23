/* File contains the Attendance model */

class Attendance {
  String id;
  final String employeeId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  DateTime createdAt;

  Attendance({
    this.id = '',
    required this.employeeId,
    required this.checkInTime,
    this.checkOutTime,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static Attendance fromMap(Map<dynamic, dynamic> employee) {
    return Attendance(
        id: employee['id'],
        employeeId: employee['employeeId'],
        checkInTime: employee['checkInTime'],
        checkOutTime: employee['checkOutTime'],
        createdAt: employee['created_at']
    );
  }

  toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'created_at': createdAt,
    };
  }
}