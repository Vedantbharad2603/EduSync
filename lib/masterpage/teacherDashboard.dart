import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edu_sync/Model/EventModel.dart';
import 'package:edu_sync/tools/Colors.dart';
import 'package:edu_sync/tools/Components.dart';
import 'package:edu_sync/tools/apiconst.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
// import '../API/API.dart';
// import '../Model/UserDataModel.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final box = GetStorage();
  // late UserData userData;

  List<MapEntry<DateTime, int>> dateIntList = [];

  int mapStatusToInt(String status) {
    switch (status) {
      case 'Present':
        return 1;
      case 'Absent':
        return 2;
      case 'On Leave':
        return 3;
      default:
        return -1;
    }
  }

  late int studentid;
  String full_name_d = "";
  String username_d = "";
  String password_d = "";
  String holidayName = "";
  String holidayDate = "";
  bool _isLoading = false;
  List<EventModel> events = [];

  Future<void> fetchEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(Apiconst.listallEvents));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'];
          List<EventModel> fetchedEvents =
              data.map((e) => EventModel.fromJson(e)).toList();
          setState(() {
            events = fetchedEvents; // Update the events list
          });
        } else {
          throw Exception('Data key not found in API response');
        }
      } else {
        throw Exception('Failed to fetch events');
      }
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchHoliday() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(Apiconst.upcomingholiday));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('data')) {
          final holidayData = data['data'];
          holidayName = holidayData['holiday_name'];
          holidayDate = holidayData['holiday_date'];
        } else {
          throw Exception('Data key not found in API response');
        }
      } else {
        throw Exception('Failed to fetch Holiday');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void fetchAttendance(int studid) async {
    try {
      Map<String, dynamic> body = {"id": studid};
      final response = await http.post(
        Uri.parse(Apiconst.getStudAttendance),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('data')) {
          final List<dynamic> attendanceData = data['data'];
          dateIntList.clear(); // Clear the existing data
          for (var attendance in attendanceData) {
            DateTime date = DateTime.parse(attendance['date']).toLocal();
            int status = mapStatusToInt(attendance['status']);
            dateIntList.add(MapEntry(date, status));
          }
          // log(dateIntList.toString());
        } else {
          throw Exception('Data key not found in API response');
        }
      } else {
        throw Exception('Failed to fetch events');
      }
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    super.initState();
    GetStorage storage = GetStorage();
    final mydata = storage.read('login_data');
    if (mydata != null) {
      studentid = mydata['data']['userdata']['id'] ?? 0;
      full_name_d = mydata['data']['userdata']['full_name'] ?? "";
      username_d = mydata['data']['login']['username'] ?? "";
      password_d = mydata['data']['login']['password'] ?? "";
    }

    fetchEvents();
    fetchHoliday();
    fetchAttendance(studentid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     await CachedNetworkImage.evictFromCache(
      //         studentImageAPI(userData.studentDetails!.grNo));
      //     box.write('loggedin', false);
      //     box.write('userdata', null);
      //     Get.offNamed('/login');
      //   },
      //   child: Icon(Icons.exit_to_app),
      // ),
      backgroundColor: MyTheme.background,
      appBar: AppBar(
        title: Text("Dashboard",
            style: TextStyle(
                color: Colors.black, fontFamily: "mu_reg", fontSize: 23)),
        centerTitle: true,
        backgroundColor: MyTheme.background,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BlackTag(
              context,
              Dark1,
              full_name_d,
              "Teacher",
              Icon(Icons.person),
              // CachedNetworkImage(
              //   imageUrl: studentImageAPI(userData.studentDetails!.grNo),
              //   placeholder: (context, url) => Icon(
              //     Icons.person,
              //     size: 50,
              //     color: Colors.black45,
              //   ),
              //   errorWidget: (context, url, error) => Icon(
              //     Icons.person,
              //     size: 50,
              //     color: Colors.black87,
              //   ),
              //   fit: BoxFit.cover,
              // ),
              false,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: GridView.count(
                  shrinkWrap:
                      true, // Ensures the GridView takes only as much space as it needs
                  crossAxisCount: 3,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                  padding: EdgeInsets.all(10),
                  children: [
                    TapIcons(context, "Attendance", 2, "attendance.png", 45,
                        "/teacherattendance", null),
                    TapIcons(context, "Manage Holidays", 2, "holiday.png", 45,
                        "/teacherHolidays", null),
                    TapIcons(context, "Timetable", 2, "timetable.png", 45,
                        "/updateTimetable", null),
                    TapIcons(context, "Faculties", 2, "faculty.png", 45,
                        "/manageTeacher", null),
                    TapIcons(context, "Noticeboard", 2, "noticeboard.png", 45,
                        "/messages", null),
                    TapIcons(context, "Events", 2, "event.png", 80,
                        "/addEventPage", null),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            BlackTag(
              context,
              Dark1,
              "Upcoming Event",
              "Engineer's Day Celebration",
              Image.asset(
                "assets/images/arrow_right.png",
                fit: BoxFit.cover,
              ),
              true,
            ),
          ],
        ),
      ),
    );
  }
}
