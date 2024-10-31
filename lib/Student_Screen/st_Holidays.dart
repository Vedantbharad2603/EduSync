import 'dart:convert';
import 'package:edu_sync/Model/HolidayModel.dart';
import 'package:edu_sync/tools/apiconst.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class StHolidays extends StatefulWidget {
  const StHolidays({super.key});

  @override
  _StHolidaysState createState() => _StHolidaysState();
}

class _StHolidaysState extends State<StHolidays> {
  List<HolidayModel> holidayDataList = [];
  bool _isLoading = false;
  late Future<List<HolidayModel>> _futureHolidays = Future.value([]);
  final ScrollController _scrollController = ScrollController();
  int? highlightedIndex;

  @override
  void initState() {
    super.initState();
    _futureHolidays = getHoliday();
  }

  Future<List<HolidayModel>> getHoliday() async {
    List<HolidayModel> holidayDataList = [];
    try {
      http.Response response = await http.get(
        Uri.parse(Apiconst.getholidays),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> holidays = data['data'];

        holidayDataList = holidays.map((holiday) {
          return HolidayModel(
            id: holiday['id'],
            name: holiday['holiday_name'],
            date: holiday['holiday_date'],
            consider: holiday['is_holiday'],
          );
        }).toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToUpcomingHoliday(holidayDataList);
        });
      } else {
        throw Exception('Failed to fetch holidays');
      }
    } catch (e) {
      // Handle any errors
    }
    return holidayDataList;
  }

  void scrollToUpcomingHoliday(List<HolidayModel> holidays) {
    DateTime today = DateTime.now();
    for (int i = 0; i < holidays.length; i++) {
      DateTime holidayDate = DateFormat('yyyy-MM-dd').parse(holidays[i].date);
      if (holidayDate.isAfter(today)) {
        highlightedIndex = i;
        _scrollController.animateTo(
          i * 72.0, // Approximate height of each item
          duration: const Duration(seconds: 1), // Adjust duration as needed
          curve: Curves.easeInOut, // Smooth scrolling curve
        );
        setState(() {}); // Refresh UI to highlight the upcoming holiday
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Container(
            color: MyTheme.background,
            child: Center(
              child: CircularProgressIndicator(
                color: MyTheme.themeColor,
                backgroundColor: MyTheme.background,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: MyTheme.background2,
            appBar: AppBar(
              backgroundColor: MyTheme.themeColor2,
              shadowColor: Colors.transparent,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: MyTheme.textcolor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title:
                  Text('Holidays', style: TextStyle(color: MyTheme.textcolor)),
            ),
            body: FutureBuilder<List<HolidayModel>>(
              future: _futureHolidays,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: MyTheme.themeColor,
                          backgroundColor: MyTheme.background));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  ));
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text(
                    "No holidays found",
                    style: TextStyle(color: Colors.white),
                  ));
                } else {
                  holidayDataList = snapshot.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: holidayDataList.length,
                    itemBuilder: (context, index) {
                      var holiday = holidayDataList[index];
                      return ListTile(
                        title: Text(
                          holiday.name,
                          style: TextStyle(color: MyTheme.textcolor),
                        ),
                        subtitle: Text(holiday.date,
                            style: TextStyle(
                                color: MyTheme.textcolor.withOpacity(0.6))),
                        tileColor: index == highlightedIndex
                            ? MyTheme.themeColor
                            : Colors.transparent,
                      );
                    },
                  );
                }
              },
            ),
          );
  }
}
