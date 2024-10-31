// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api
import 'dart:convert';
import 'package:edu_sync/Model/HolidayModel.dart';
import 'package:edu_sync/tools/apiconst.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListofHolidays extends StatefulWidget {
  const ListofHolidays({super.key});

  @override
  _ListofHolidaysState createState() => _ListofHolidaysState();
}

class _ListofHolidaysState extends State<ListofHolidays> {
  List<HolidayModel> holidayDataList = []; // Store fetched holiday data
  bool _isLoading = false;
  // List<bool> selected = []; // Track selected holidays
  // List<bool> selected = List.generate(holidayDataList.length, (index) => false);

  late Future<List<HolidayModel>> _futureHolidays = Future.value([]);

  @override
  void initState() {
    super.initState();
    _futureHolidays = getholiday();
    // selected = List.generate(holidayDataList.length, (index) => false);
  }

  Future<void> fetchHolidays() async {
    int currentYear = DateTime.now().year;

    final response = await http.get(
      Uri.parse(
          'https://calendarific.com/api/v2/holidays?&api_key=RiOlrpYvgp0a5J5T8Z8iUza6kjGILmC7&country=IN&year=$currentYear'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> fetchedHolidays = data['response']['holidays'];
      holidayDataList = fetchedHolidays
          .map((holiday) => HolidayModel(
                name: holiday['name'],
                date: holiday['date']['iso'],
              ))
          .toList();
      addholiday(holidayDataList);
      setState(() {
        _futureHolidays = getholiday();
      });
    } else {
      throw Exception('Failed to load holidays');
    }
  }

  void addholiday(List<HolidayModel> holidayDataList) async {
    for (var holiday in holidayDataList) {
      Map<String, dynamic> body = {
        "holiday_name": holiday.name,
        "holiday_date": holiday.date,
        "is_holiday": holiday.consider,
      };
      try {
        http.Response response = await http.post(
          Uri.parse(Apiconst.addholidays),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        );

        if (response.statusCode == 200) {
          // Holiday added successfully
          // print('Holiday added: ${holiday.name}');
        } else {
          // Handle unsuccessful response
          // print('Failed to add holiday: ${holiday.name}');
        }
      } catch (e) {
        // Handle any errors
      }
    }
  }

  Future<List<HolidayModel>> getholiday() async {
    List<HolidayModel> holidayDataList = [];

    try {
      http.Response response = await http.get(
        Uri.parse(Apiconst.getholidays),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Parse the response body
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> holidays =
            data['data']; // Assuming 'holidays' is the key for the list

        // Map the list of holidays to HolidayModel objects
        // print(data['data'][1]['is_holiday']);
        holidayDataList = holidays.map((holiday) {
          return HolidayModel(
            id: holiday['id'],
            name: holiday['holiday_name'],
            date: holiday['holiday_date'],
            consider: holiday['is_holiday'],
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch holidays');
      }
    } catch (e) {
      // Handle any errors
    }
    return holidayDataList;
  }

  Future<bool> updateHolidays(
      int id, String name, String date, bool consider) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> body = {
      "id": id,
      "holiday_name": name,
      "holiday_date": date,
      "is_holiday": consider,
    };
    try {
      http.Response response = await http.put(
        Uri.parse(
            Apiconst.updateHoliday), // Use the correct endpoint for updating
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Holiday updated successfully
        return true;
      } else {
        // Handle unsuccessful response
        // print('Failed to update holiday: $name');
        return false;
      }
    } catch (e) {
      // Handle any errors
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current month
    final currentMonth = DateTime.now().month;

    // Check if the current month is January (month number is 1)
    final isJanuary = currentMonth == DateTime.january;
    return _isLoading
        ? Container(
            color: MyTheme.background,
            child: Center(
              child: CircularProgressIndicator(
                // strokeAlign: 1,
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
              actions: [
                if (isJanuary)
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: MyTheme.button1,
                    ),
                    onPressed: () {
                      fetchHolidays();
                    },
                  ),
              ],
              title: Text('Manage Holidays',
                  style: TextStyle(color: MyTheme.textcolor)),
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
                } else if (snapshot.data == null) {
                  return const Center(
                      child: Text(
                    "Could not find holidays data",
                    style: TextStyle(color: Colors.white),
                  ));
                } else {
                  List<HolidayModel> fetchedHolidays = snapshot.data!;
                  holidayDataList =
                      fetchedHolidays; // Assign fetchedHolidays to holidayDataList
                  return ListView.builder(
                    itemCount: fetchedHolidays.length,
                    itemBuilder: (context, index) {
                      var holiday = fetchedHolidays[index];
                      return ListTile(
                        title: Text(
                          holiday.name,
                          style: TextStyle(color: MyTheme.textcolor),
                        ),
                        subtitle: Text(holiday.date,
                            style: TextStyle(
                                color: MyTheme.textcolor.withOpacity(0.6))),
                        trailing: Checkbox(
                          hoverColor: MyTheme.themeColor,
                          activeColor: MyTheme.themeColor2,
                          checkColor: MyTheme.mainbackground,
                          value: holiday.consider,
                          onChanged: (bool? value) async {
                            bool success = await updateHolidays(
                              holiday.id,
                              holiday.name,
                              holiday.date,
                              !holiday.consider,
                            );
                            if (success) {
                              setState(() {
                                holiday.consider = value ?? false;
                                // getholiday();
                              });
                            } else {
                              // Show error dialog if update failed
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Error"),
                                    content: const Text(
                                        "Failed to update holidays."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          side: BorderSide(color: MyTheme.textcolor, width: 2),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          );
  }
}
