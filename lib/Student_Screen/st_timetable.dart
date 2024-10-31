import 'dart:convert';
import 'package:edu_sync/tools/apiconst.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/Model/SlotModel.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class StTimeTable extends StatefulWidget {
  const StTimeTable({Key? key}) : super(key: key);

  @override
  _StTimeTableState createState() => _StTimeTableState();
}

class _StTimeTableState extends State<StTimeTable> {
  final box = GetStorage();
  Map<String, List<SlotModel>> timetable = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
  };
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadTimetableFromStorage(); // Load data from GetStorage
  }

  Future<void> loadTimetableFromStorage() async {
    final storedTimetable = box.read('timetable');
    if (storedTimetable != null) {
      setState(() {
        timetable = Map<String, List<SlotModel>>.from(storedTimetable);
      });
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
            if (isLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cannot close this page.'),
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          "Timetable Preview",
          style: TextStyle(
            color: MyTheme.textcolor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: MyTheme.themeColor,
                                  border: Border.all(color: MyTheme.textcolor),
                                ),
                                child: Container(
                                  width: 70,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: Text('Slot',
                                      style: TextStyle(
                                          color: MyTheme.textcolor,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              ...timetable.keys.map((day) => DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: MyTheme.themeColor2,
                                      border:
                                          Border.all(color: MyTheme.textcolor),
                                    ),
                                    child: Container(
                                      width: 150,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Text(day,
                                          style: TextStyle(
                                              color: MyTheme.textcolor)),
                                    ),
                                  )),
                            ],
                          ),
                          ...List.generate(6, (slotIndex) {
                            return Row(
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: MyTheme.themeColor,
                                    border:
                                        Border.all(color: MyTheme.textcolor),
                                  ),
                                  child: Container(
                                    width: 70,
                                    height: 100,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Slot ${slotIndex + 1}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                ...timetable.keys.map((day) {
                                  SlotModel? slot;
                                  if (slotIndex < timetable[day]!.length) {
                                    slot = timetable[day]![slotIndex];
                                  } else {
                                    slot = null;
                                  }

                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: MyTheme.background,
                                      border:
                                          Border.all(color: MyTheme.textcolor),
                                    ),
                                    child: Container(
                                      width: 150,
                                      height: 100,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: MyTheme.background,
                                        border: Border.all(color: Colors.black),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.transparent,
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: slot != null
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  slot.subject,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  slot.className,
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  slot.startTime
                                                          ?.format(context) ??
                                                      '',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  slot.endTime
                                                          ?.format(context) ??
                                                      '',
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ],
                                            )
                                          : const Center(
                                              child: Text(
                                                'No Slot',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                            ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
