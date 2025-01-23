
import 'package:clockwrk_login/app_logger.dart';
import 'package:clockwrk_login/db/preferences_helper.dart';
import 'package:clockwrk_login/models/user.dart';
import 'package:clockwrk_login/pages/admin/attendance_view.dart';
import 'package:flutter/material.dart';

import '../../db/db_helper.dart';
import '../../locator.dart';
import '../../models/employee.dart';
import '../../provider_helper.dart';
import '../widgets/common.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key, required this.adminDeviceModeNotifier});

  final AdminDeviceModeModel adminDeviceModeNotifier;

  @override
  Widget build(BuildContext context) {
    if (adminDeviceModeNotifier.isAttendanceMode == true) {
      AppLogger.instance.d("Showing attendance view page");
      return AttendanceView(adminDeviceModeNotifier: adminDeviceModeNotifier);
    } else {
      AppLogger.instance.d("Showing the admin view");
      return Scaffold(
        appBar: AppBar(
          title: appNameWidget(),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          actions: <Widget>[
            PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'AttendanceView',
                  child: Text('Attendance View',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'SignOut',
                  child: Text('Sign Out',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Settings',
                  child: Text('Settings',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              position: PopupMenuPosition.under,
              onSelected: (String value) {
                if (value == "SignOut") {
                  // Handle the sign-out logic here
                  signOut();
                } else if (value == "AttendanceView") {
                  adminDeviceModeNotifier.toggleAdminDeviceMode();
                } else if (value == "Settings") {
                  // TODO: Move to settings page
                }
              },
            )
          ],
        ),
        body: FutureBuilder<AppUser?>(
          future: PreferencesHelper.getUserPreference(),
          builder: (BuildContext context, AsyncSnapshot<AppUser?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              AppLogger.instance.d("Waiting to get app user data from preference");
              return loadingWidget();
            } else if (snapshot.hasData) {
              AppUser? user = snapshot.data;
              if (user != null) {
                AppLogger.instance.d("Got '${user.id}' admin data");
                return EmployeeListView(appUser: user);
              } else {
                // Show an error message
                AppLogger.instance.e('snapshot.data does not contain User object');
                showToast('snapshot.data does not contain User object');
                return Container();
              }
            } else if (snapshot.hasError) {
              // Show an error message
              AppLogger.instance.e('Error: ${snapshot.error}');
              showToast('Error: ${snapshot.error}');
              // Return a placeholder widget while navigating
              return Container();
            } else {
              // Show an error message
              AppLogger.instance.e('Error: User data not found in user preference');
              showToast('Error: User data not found in user preference');
              return Container();
            }
          },
        )
      );
    }
  }
}

class EmployeeListView extends StatefulWidget {
  final AppUser appUser;

  const EmployeeListView({super.key, required this.appUser});

  @override
  State<StatefulWidget> createState() => EmployeeListViewState();
}

class EmployeeListViewState extends State<EmployeeListView> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  final DbHelper _dbHelper = locator<DbHelper>();

  late List<Employee> _employees;

  List<Employee> _filteredEmployees = [];
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    // Trigger the refresh when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  Future<void> _refreshEmployeesList() async {
    AppLogger.instance.d("Refreshing employees list");
    _employees = await _dbHelper.getEmployees(widget.appUser.adminId!);
    AppLogger.instance.d("Found ${_employees.length} employees");
    setState(() {
      _filteredEmployees = _employees;
    });
  }

  void _filterEmployees(String query) {
    List<Employee> filteredList = _employees
        .where((employee) => employee.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _filteredEmployees = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                  _filterEmployees(_searchText);
                },
                decoration: InputDecoration(
                  labelText: 'Search Employees',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
                child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _refreshEmployeesList,
                    child: _filteredEmployees.isEmpty
                        ? ListView( // Use ListView even for empty state
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                alignment: Alignment.center,
                                child: const Text(
                                  'There are no employees',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              ),
                            ],
                        )
                        : ListView.builder(
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: _filteredEmployees[index].photoURL != null
                                  ? NetworkImage(_filteredEmployees[index].photoURL!)
                                  : const AssetImage('assets/male-placeholder.png') as ImageProvider,
                            ),
                            title: Text(_filteredEmployees[index].name),
                            onTap: () {}, // Make ListTile clickable
                          );
                        },
                    ),
                ),
            ),
          ],
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            onPressed: () {
              // Define what happens when the button is pressed
              setState(() {
              });
            },
            backgroundColor: Colors.blue,
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}