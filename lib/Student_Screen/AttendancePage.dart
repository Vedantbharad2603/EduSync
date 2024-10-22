import 'dart:convert';
import 'dart:developer';

import 'package:edu_sync/tools/apiconst.dart';
import 'package:edu_sync/tools/helper.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AttendancePage extends StatefulWidget {
  final int studentid;
  const AttendancePage({
    super.key,
    required this.studentid,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<MapEntry<DateTime, int>> dateIntList = [];
  bool loading = true; // Added loading state

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

  void fetchAttendance(int studid) async {
    setState(() {
      loading = true; // Start loading
    });
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
        loading = false; // Stop loading
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAttendance(widget.studentid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.background,
      appBar: AppBar(
        title: Text("Your Attendance",
            style: TextStyle(
              color: MyTheme.textcolor,
              fontFamily: "mu_reg",
              fontSize: 20,
            )),
        centerTitle: true,
        backgroundColor: MyTheme.mainbuttontext,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: MyTheme.textcolor),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
              color: MyTheme.mainbutton,
            )) // Show loading indicator
          : SingleChildScrollView(
              child: showAttendance("", context, dateIntList),
            ),
    );
  }
}
