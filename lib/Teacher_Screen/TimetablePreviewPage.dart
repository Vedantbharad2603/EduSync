import 'dart:convert';
import 'package:edu_sync/tools/apiconst.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/Model/SlotModel.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:http/http.dart' as http;

class TimetablePreviewPage extends StatefulWidget {
  final Map<String, List<SlotModel>> timetable;

  const TimetablePreviewPage({Key? key, required this.timetable})
      : super(key: key);

  @override
  _TimetablePreviewPageState createState() => _TimetablePreviewPageState();
}

class _TimetablePreviewPageState extends State<TimetablePreviewPage> {
  bool isLoading = false;

  Future<void> saveTimetable() async {
    setState(() {
      isLoading = true; // Start loading
    });

    final url =
        Uri.parse(Apiconst.updateTimeTable); // Replace with your API URL
    bool allSuccessful = true; // Track overall success

    // Loop over each day and slot, and send each slot as an API request
    for (var dayEntry in widget.timetable.entries) {
      for (var slot in dayEntry.value) {
        final body = {
          "id": slot.id,
          "day": slot.day,
          "start_time":
              "${slot.startTime?.hour.toString().padLeft(2, '0')}:${slot.startTime?.minute.toString().padLeft(2, '0')}:00",
          "end_time":
              "${slot.endTime?.hour.toString().padLeft(2, '0')}:${slot.endTime?.minute.toString().padLeft(2, '0')}:00",
          "subject": slot.subject,
          "class_name": slot.className,
          "slot_number": slot.slotNumber,
        };

        try {
          final response = await http.put(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          );

          if (response.statusCode != 200) {
            allSuccessful = false;
            print("Failed to update slot: ${slot.slotNumber}");
            print("Error: ${response.body}");
          }
        } catch (e) {
          allSuccessful = false;
          print("Error updating slot: ${slot.slotNumber}, $e");
        }
      }
    }

    setState(() {
      isLoading = false; // Stop loading after process completes
    });

    // Show appropriate SnackBar based on the result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(allSuccessful
            ? 'Timetable saved successfully'
            : 'Some slots failed to update. Please try again.'),
      ),
    );
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
                  content: Text('Cannot close this page while updating data.'),
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
                              ...widget.timetable.keys
                                  .map((day) => DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: MyTheme.themeColor2,
                                          border: Border.all(
                                              color: MyTheme.textcolor),
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
                                ...widget.timetable.keys.map((day) {
                                  SlotModel? slot;
                                  if (slotIndex <
                                      widget.timetable[day]!.length) {
                                    slot = widget.timetable[day]![slotIndex];
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyTheme.background,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        shadowColor: Colors.transparent,
                      ),
                      child: Text('Edit Again',
                          style: TextStyle(color: MyTheme.textcolor)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Saving timetable...'),
                        ));

                        await saveTimetable();

                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Timetable saved successfully'),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyTheme.background,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        shadowColor: Colors.transparent,
                      ),
                      child: Text('Save',
                          style: TextStyle(color: MyTheme.textcolor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isLoading) // Display loading indicator when isLoading is true
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: MyTheme.themeColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
