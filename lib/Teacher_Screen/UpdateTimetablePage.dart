import 'dart:convert';

import 'package:edu_sync/Model/SlotModel.dart';
import 'package:edu_sync/Teacher_Screen/TimetablePreviewPage.dart';
import 'package:edu_sync/tools/Components.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:edu_sync/tools/apiconst.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateTimetablePage extends StatefulWidget {
  @override
  _UpdateTimetablePageState createState() => _UpdateTimetablePageState();
}

class _UpdateTimetablePageState extends State<UpdateTimetablePage> {
  String selectedDay = 'Monday'; // Default selected day
  List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  // Map to store timetable data for each day
  Map<String, List<SlotModel>> timetable = {
    'Monday': List.generate(
      6,
      (_) =>
          SlotModel(day: 'Monday', subject: '', className: '', slotNumber: 0),
    ),
    'Tuesday': List.generate(
      6,
      (_) =>
          SlotModel(day: 'Monday', subject: '', className: '', slotNumber: 0),
    ),
    'Wednesday': List.generate(
      6,
      (_) =>
          SlotModel(day: 'Monday', subject: '', className: '', slotNumber: 0),
    ),
    'Thursday': List.generate(
      6,
      (_) =>
          SlotModel(day: 'Monday', subject: '', className: '', slotNumber: 0),
    ),
    'Friday': List.generate(
      6,
      (_) =>
          SlotModel(day: 'Monday', subject: '', className: '', slotNumber: 0),
    )
  };

  // Controllers for each subject and class name field
  final List<TextEditingController> subjectControllers =
      List.generate(6, (_) => TextEditingController());
  final List<TextEditingController> classControllers =
      List.generate(6, (_) => TextEditingController());

  // Variables to store the selected times for each slot
  List<TimeOfDay?> startTimes = List.generate(6, (_) => null);
  List<TimeOfDay?> endTimes = List.generate(6, (_) => null);

  // Assuming a way to track IDs for the slots, e.g. through a list
  List<int?> ids = [null, null, null, null, null, null]; // Add IDs here

  @override
  void initState() {
    super.initState();
    fetchTimetableData(); // Fetch timetable on init
  }

  // Method to fetch timetable data
  Future<void> fetchTimetableData() async {
    try {
      final response = await http.get(Uri.parse(Apiconst.getTimeTable));
      if (response.statusCode == 200) {
        // Decode the entire response body
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extract the 'data' list
        List<dynamic> data = responseData['data'];

        setState(() {
          // Clear the existing timetable to avoid duplicates
          timetable = {
            'Monday': [],
            'Tuesday': [],
            'Wednesday': [],
            'Thursday': [],
            'Friday': []
          };

          // Populate the timetable map
          for (var item in data) {
            String day = item['day'];
            if (timetable.containsKey(day)) {
              timetable[day]!.add(SlotModel(
                id: item['id'],
                day: day,
                startTime: TimeOfDay(
                  hour: int.parse(item['start_time'].split(":")[0]),
                  minute: int.parse(item['start_time'].split(":")[1]),
                ),
                endTime: TimeOfDay(
                  hour: int.parse(item['end_time'].split(":")[0]),
                  minute: int.parse(item['end_time'].split(":")[1]),
                ),
                subject: item['subject'],
                className: item['class_name'],
                slotNumber: item['slot_number'],
              ));
            }
          }
          loadDayData(selectedDay);
        });
      } else {
        throw Exception('Failed to load timetable');
      }
    } catch (e) {
      print('Error fetching timetable: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.mainbackground,
      appBar: AppBar(
        backgroundColor: MyTheme.mainbuttontext,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: MyTheme.textcolor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
          "Update Timetable",
          style: TextStyle(
            color: MyTheme.textcolor,
            fontSize: getSize(context, 2.7),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: MyTheme.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: MyTheme.themeColor, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDay,
                      onChanged: (String? newValue) {
                        setState(() {
                          saveDayData(
                              selectedDay, ids); // Save current day's data
                          selectedDay = newValue!;
                          loadDayData(selectedDay); // Load new day's data
                        });
                      },
                      items: days.map((String day) {
                        return DropdownMenuItem<String>(
                          value: day,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child:
                                Text(day, style: const TextStyle(fontSize: 18)),
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down,
                          color: MyTheme.themeColor), // Custom icon
                      style: TextStyle(
                          color: MyTheme.textcolor, fontSize: 16), // Font style
                      dropdownColor:
                          MyTheme.background, // Dropdown background color
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(6, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Slot ${index + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: MyTheme.background,
                                    border: Border.all(
                                        color: MyTheme.themeColor, width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      'Start: ${startTimes[index] != null ? startTimes[index]!.format(context) : 'Select Time'}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: MyTheme.textcolor),
                                    ),
                                    trailing: Icon(
                                      Icons.access_time,
                                      color: MyTheme.themeColor2,
                                    ),
                                    onTap: () =>
                                        selectTime(context, index, true),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: MyTheme.background,
                                    border: Border.all(
                                        color: MyTheme.themeColor, width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      'End: ${endTimes[index] != null ? endTimes[index]!.format(context) : 'Select Time'}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: MyTheme.textcolor),
                                    ),
                                    trailing: Icon(
                                      Icons.access_time,
                                      color: MyTheme.themeColor2,
                                    ),
                                    onTap: () =>
                                        selectTime(context, index, false),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          // Subject Field
                          TextFormField(
                            controller: subjectControllers[index],
                            decoration: InputDecoration(
                              hintText: 'Subject',
                              filled: true,
                              fillColor: MyTheme.background,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: MyTheme.themeColor2,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: MyTheme.themeColor2,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: MyTheme.themeColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: classControllers[index],
                            decoration: InputDecoration(
                              hintText: 'Classroom',
                              filled: true,
                              fillColor: MyTheme.background,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: MyTheme.themeColor2,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: MyTheme.themeColor2,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: MyTheme.themeColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            // Save Button (sticky at bottom)
            Padding(
                padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    saveDayData(selectedDay, ids); // Save current day's data
                    // print(timetable);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            TimetablePreviewPage(timetable: timetable),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    backgroundColor: MyTheme.themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Save Timetable',
                    style: TextStyle(
                      fontSize: 18,
                      color: MyTheme.textcolor,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // Time selection method
  Future<void> selectTime(
      BuildContext context, int index, bool isStartTime) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor: MyTheme.themeColor,
            colorScheme: ColorScheme.light(
              onBackground: MyTheme.background2,
              primary: MyTheme.themeColor,
              onPrimary: Colors.white,
              onSurface: MyTheme.textcolor,
            ),
            dialogBackgroundColor:
                Colors.white, // Background color of the date picker
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          if (endTimes[index] != null && !isBefore(picked, endTimes[index]!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Start time should be before end time')),
            );
          } else if (index > 0 &&
              !isSameOrAfter(picked, endTimes[index - 1]!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Start time must be after previous slot end time')),
            );
          } else {
            startTimes[index] = picked;
          }
        } else {
          if (startTimes[index] == null ||
              !isSameOrAfter(picked, startTimes[index]!)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('End time should be after start time')),
            );
          } else {
            endTimes[index] = picked;
          }
        }
      });
    }
  }

  // bool isBefore(TimeOfDay first, TimeOfDay second) {
  //   return first.hour < second.hour ||
  //       (first.hour == second.hour && first.minute < second.minute);
  // }

  // // Helper function to compare if first time is after second time
  // bool isAfter(TimeOfDay first, TimeOfDay second) {
  //   return first.hour > second.hour ||
  //       (first.hour == second.hour && first.minute > second.minute);
  // }
  bool isBefore(TimeOfDay first, TimeOfDay second) {
    return first.hour < second.hour ||
        (first.hour == second.hour && first.minute < second.minute);
  }

// Helper function to compare if the first time is the same as or after the second time
  bool isSameOrAfter(TimeOfDay first, TimeOfDay second) {
    return first.hour > second.hour ||
        (first.hour == second.hour && first.minute >= second.minute);
  }

  // Load data for a specific day
  void loadDayData(String day) {
    List<SlotModel> slots = timetable[day]!;
    for (int i = 0; i < slots.length; i++) {
      subjectControllers[i].text = slots[i].subject;
      classControllers[i].text = slots[i].className;
      startTimes[i] = slots[i].startTime;
      endTimes[i] = slots[i].endTime;
      ids[i] = slots[i].id; // Assuming ids are set in SlotModel
    }
  }

  // Save the current day's data to the timetable
  void saveDayData(String day, List<int?> ids) {
    List<SlotModel> slots = timetable[day]!;
    for (int i = 0; i < slots.length; i++) {
      slots[i].subject = subjectControllers[i].text;
      slots[i].className = classControllers[i].text;
      slots[i].startTime = startTimes[i];
      slots[i].endTime = endTimes[i];
      slots[i].id = ids[i]; // Update the ID in SlotModel
    }
  }
}
