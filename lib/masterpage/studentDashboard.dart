import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edu_sync/Model/EventModel.dart';
import 'package:edu_sync/Model/SlotModel.dart';
import 'package:edu_sync/tools/Colors.dart';
import 'package:edu_sync/tools/Components.dart';
import 'package:edu_sync/tools/apiconst.dart';
import 'package:edu_sync/tools/helper.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final box = GetStorage();
  late int studentid;
  String full_name_d = "";
  String username_d = "";
  String password_d = "";
  String holidayName = "";
  String holidayDate = "";
  String coursename = "";
  bool _isLoading = false;
  List<EventModel> events = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Map<String, List<SlotModel>> timetable = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': []
  };

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
            events = fetchedEvents;
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

  Future<void> fetchTimetableData() async {
    try {
      final response = await http.get(Uri.parse(Apiconst.getTimeTable));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        List<dynamic> data = responseData['data'];

        // Clear old notifications
        await flutterLocalNotificationsPlugin.cancelAll();

        setState(() {
          timetable = {
            'Monday': [],
            'Tuesday': [],
            'Wednesday': [],
            'Thursday': [],
            'Friday': []
          };

          for (var item in data) {
            String day = item['day'];
            if (timetable.containsKey(day)) {
              TimeOfDay startTime = TimeOfDay(
                hour: int.parse(item['start_time'].split(":")[0]),
                minute: int.parse(item['start_time'].split(":")[1]),
              );

              timetable[day]!.add(SlotModel(
                id: item['id'],
                day: day,
                startTime: startTime,
                endTime: TimeOfDay(
                  hour: int.parse(item['end_time'].split(":")[0]),
                  minute: int.parse(item['end_time'].split(":")[1]),
                ),
                subject: item['subject'],
                className: item['class_name'],
                slotNumber: item['slot_number'],
              ));

              // Schedule notification
              scheduleNotification(item);
            }
          }
          box.write('timetable', timetable);
        });
      } else {
        throw Exception('Failed to load timetable');
      }
    } catch (e) {
      print('Error fetching timetable: $e');
    }
  }

  Future<void> scheduleNotification(Map<String, dynamic> item) async {
    final TimeOfDay startTime = TimeOfDay(
      hour: int.parse(item['start_time'].split(":")[0]),
      minute: int.parse(item['start_time'].split(":")[1]),
    );

    final DateTime now = DateTime.now();
    DateTime notificationTime = DateTime(
        now.year, now.month, now.day, startTime.hour, startTime.minute);

    if (notificationTime.isBefore(now)) {
      notificationTime = notificationTime.add(Duration(days: 1));
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        item['id'],
        'Class Reminder',
        'Your class ${item['subject']} starts at ${item['start_time']}',
        tz.TZDateTime.from(notificationTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'Your channel description',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print(
          "Notification scheduled for ${item['subject']} at ${item['start_time']}.");
    } catch (e) {
      print(
          "Failed to schedule notification for ${item['subject']} at ${item['start_time']}. Error: $e");
    }
  }

  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
      if (status.isGranted) {
        print("Notification permission granted.");
      } else {
        print("Notification permission denied.");
      }
    } else {
      print("Notification permission already granted.");
    }

    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
      print("Requested ignore battery optimizations permission.");
    }
  }

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    GetStorage storage = GetStorage();
    final mydata = storage.read('login_data');
    if (mydata != null) {
      studentid = mydata['data']['userdata']['id'] ?? 0;
      full_name_d = mydata['data']['userdata']['full_name'] ?? "";
      username_d = mydata['data']['login']['username'] ?? "";
      password_d = mydata['data']['login']['password'] ?? "";
      coursename = mydata['data']['courseinfo']['course_name'] ?? "";
    }

    fetchEvents();
    fetchHoliday();
    fetchTimetableData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              "Student",
              Icon(Icons.person),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  final storage = GetStorage();
                  await storage.remove('login_data');
                  await storage.write('logedin', false);
                  Get.offAllNamed("/login");
                },
              ),
              true,
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
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  children: [
                    TapIcons(context, "Attendance", 2, "attendance.png", 45,
                        "/attendancepage", {'studentid': studentid}),
                    TapIcons(context, "Noticeboard", 2, "noticeboard.png", 45,
                        "/stMessages", null),
                    TapIcons(context, "Holidays", 2, "holiday.png", 45,
                        "/stHolidays", null),
                    TapIcons(context, "Timetable", 2, "timetable.png", 45,
                        "/stTimeTable", null),
                    TapIcons(context, "Events", 2, "event.png", 80,
                        "/showEvents", null),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            BlackTag(
              context,
              Dark1,
              "Upcoming Event",
              events.isNotEmpty && events[0].event_description != null
                  ? events[0].event_description
                  : "No upcoming event",
              IconButton(
                icon: Image.asset(
                  "assets/images/arrow_right.png",
                  fit: BoxFit.cover,
                ),
                onPressed: () async {
                  Get.toNamed("/showEvents");
                },
              ),
              SizedBox(),
              false,
            ),
          ],
        ),
      ),
    );
  }
}
