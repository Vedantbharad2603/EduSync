// ignore_for_file: unused_element, avoid_print, file_names, use_build_context_synchronously, unnecessary_null_comparison

import 'package:edu_sync/Model/EventModel.dart';
import 'package:edu_sync/tools/Components.dart';
import 'package:edu_sync/tools/apiconst.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddEventPage extends StatefulWidget {
  const AddEventPage({Key? key}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  late CalendarFormat _calendarFormat;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late Map<DateTime, List<EventModel>> _events;
  late String shift;
  List<Map<String, dynamic>> shifts = [];
  List<EventModel> events = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchShifts();
    fetchEvents();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {};
  }

  void populateEventsMap(List<EventModel> fetchedEvents) {
    _events = {};
    for (var event in fetchedEvents) {
      DateTime eventDate = DateTime.parse(event.event_date.substring(0, 10));
      if (_events[eventDate] == null) {
        _events[eventDate] = [];
      }
      _events[eventDate]!.add(event);
    }
  }

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
            populateEventsMap(events); // Update _events map with new data
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

  Future<void> fetchShifts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(Apiconst.listallShift));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('data')) {
          final List<dynamic> shiftsData = data['data'];
          shifts = shiftsData.map((shift) {
            return {
              'id': shift['id'],
              'shift_name': shift['shift_name'].toString(),
            };
          }).toList();
          setState(() {});
        } else {
          throw Exception('Data key not found in API response');
        }
      } else {
        throw Exception('Failed to fetch shifts');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> addEvent(String description, DateTime date, int id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> body = {
        "event_description": description,
        "event_date": date.toIso8601String(),
        "shiftdatum_id": id,
      };
      final response = await http.post(
        Uri.parse(Apiconst.addEvent),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        // Show success popup
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Event added successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to add event');
      }
    } catch (e) {
      // Show error popup
      print(e);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to add event: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
        fetchEvents();
      });
    }
  }

  String? getShiftNameById(int id, List<Map<String, dynamic>>? shifts) {
    if (shifts == null || shifts.isEmpty) return null;

    // Find the shift with the matching id
    Map<String, dynamic>? shift = shifts.firstWhere(
      (shift) => shift['id'] == id,
    );

    // Return the shift name if it exists, otherwise return null
    return shift != null ? shift['shift_name'] : null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return _isLoading
        ? Container(
            color: MyTheme.background,
            child: Center(
              child: CircularProgressIndicator(
                // strokeAlign: 1,
                color: MyTheme.button1,
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
              title: Text('Events Manage',
                  style: TextStyle(color: MyTheme.textcolor)),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: MyTheme.background,
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TableCalendar(
                          headerStyle: HeaderStyle(
                            formatButtonShowsNext: true,
                            rightChevronIcon: Icon(
                              Icons.arrow_right,
                              size: 30,
                              color: MyTheme.textcolor,
                            ),
                            leftChevronIcon: Icon(
                              Icons.arrow_left,
                              size: 30,
                              color: MyTheme.textcolor,
                            ),
                            titleTextStyle: TextStyle(color: MyTheme.textcolor),
                            formatButtonTextStyle:
                                TextStyle(color: MyTheme.textcolor),
                            formatButtonDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: MyTheme.themeColor2.withOpacity(0.8),
                              ),
                            ),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                                color: MyTheme
                                    .textcolor), // Change weekday text color
                            weekendStyle: TextStyle(
                              color: MyTheme.textcolor.withOpacity(0.3),
                            ), // Change weekend text color
                          ),
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          calendarStyle: CalendarStyle(
                            markerSize: 8,
                            markerDecoration: BoxDecoration(
                                color: MyTheme.mainbuttontext.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20)),
                            defaultTextStyle:
                                TextStyle(color: MyTheme.textcolor),
                            todayTextStyle: TextStyle(
                                color: MyTheme.background2,
                                fontWeight: FontWeight.bold),
                            weekendTextStyle: TextStyle(
                                color: MyTheme.textcolor.withOpacity(0.3),
                                fontWeight: FontWeight.bold),
                            todayDecoration: BoxDecoration(
                              color: MyTheme.textcolor,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: MyTheme.themeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          eventLoader: (day) {
                            return _events[day] ?? [];
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String eventDescription = '';
                              return AlertDialog(
                                backgroundColor: MyTheme.background2,
                                scrollable: true,
                                title: Text(
                                  'Add Event Description',
                                  style: TextStyle(color: MyTheme.textcolor),
                                ),
                                content: Column(
                                  children: [
                                    TextField(
                                      style:
                                          TextStyle(color: MyTheme.textcolor),
                                      onChanged: (value) {
                                        eventDescription = value;
                                      },
                                      decoration: InputDecoration(
                                          hintText: 'Enter event description',
                                          hintStyle: TextStyle(
                                              color: MyTheme.textcolor
                                                  .withOpacity(0.7))),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: MyTheme.button2),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      addEvent(
                                          eventDescription, _focusedDay, 1);
                                      setState(() {
                                        fetchEvents();
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Add',
                                      style: TextStyle(
                                          color: MyTheme.mainbuttontext),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          height: getHeight(context, 0.05),
                          width: getWidth(context, 0.38),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: MyTheme.mainbutton,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Add Event',
                            style: TextStyle(
                              color: MyTheme.textcolor,
                              fontWeight: FontWeight.w600,
                              fontSize: width * 0.06,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: getHeight(context, 0.02),
                    ),
                    SizedBox(
                      height: getHeight(context, 0.3),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                EventModel event = events[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: MyTheme.background,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Date: ${event.event_date.substring(0, 10)}",
                                            // .toIso8601String().substring(0, 10)
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: MyTheme.textcolor,
                                            ),
                                          ),
                                          ListTile(
                                            title: RichText(
                                              text: TextSpan(
                                                text: 'Event: ',
                                                style: TextStyle(
                                                  fontSize: getSize(context, 2),
                                                  color: MyTheme.button1,
                                                  // rgba(201, 208, 103, 1)
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        event.event_description,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: MyTheme.textcolor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }

  Widget buildmainDropdown(
    String selectedValue,
    Function(String?) onChanged,
    context,
    List<Map<String, dynamic>> shifts,
  ) {
    return Column(
      children: shifts.map((shift) {
        return RadioListTile<String>(
          title: Text(
            shift['shift_name'],
            style: TextStyle(color: MyTheme.textcolor),
          ),
          value: shift['id'].toString(), // Use unique identifier as value
          groupValue: selectedValue,
          onChanged: onChanged,
        );
      }).toList(),
    );
  }
}
