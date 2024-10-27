// ignore_for_file: file_names, non_constant_identifier_names, use_build_context_synchronously

import 'package:edu_sync/tools/Components.dart';
import 'package:edu_sync/tools/apiconst.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Attendance extends StatefulWidget {
  const Attendance({Key? key}) : super(key: key);

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  bool _isLoading = false;
  List<Map<String, dynamic>> studentData = [];
  // List<int> shiftTypes = [1, 2];
  String searchText = '';
  String? selectedShift;

  List<Map<String, dynamic>> shifts = [];

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
          setState(() {
            shifts = shiftsData.map((shift) {
              return {
                'id': shift['id'],
                'name': shift['shift_name'].toString(),
              };
            }).toList();
            selectedShift = shifts[0]['id'].toString();
          });
        } else {
          throw Exception('Data key not found in API response');
        }
      } else {
        throw Exception('Failed to fetch shifts');
      }
    } catch (e) {
      throw Exception('Failed to fetch shifts $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  String mapIntToStatus(int num) {
    switch (num) {
      case 1:
        return "Present";
      case 2:
        return 'Absent';
      case 3:
        return 'On Leave';
      default:
        return "undefined";
    }
  }

  Future<void> updateAttendance() async {
    setState(() {
      _isLoading = true;
    });
    List<Map<String, dynamic>> formattedStudentData = [];

    for (var student in studentData) {
      formattedStudentData.add({
        'id': student['id'],
        'status': mapIntToStatus(student['status']),
      });
    }
    try {
      http.Response response = await http.put(
        Uri.parse(
            Apiconst.updateAttendance), // Use the correct endpoint for updating
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formattedStudentData),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text("Attendance Updated."),
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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Fail'),
              content: const Text("Somthing wrong while updating"),
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
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Fail'),
            content: const Text("Somthing wrong while updating"),
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
      });
    }
  }

  Future<void> addAndGetTodayattendance() async {
    setState(() {
      _isLoading = true;
    });
    try {
      DateTime now = DateTime.now();

      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      Map<String, dynamic> body = {"date": formattedDate.toString()};

      final response2 = await http.post(Uri.parse(Apiconst.addTodayAttendance),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body));
      print(response2.statusCode);
      if (response2.statusCode == 200) {
        final response = await http.get(Uri.parse(Apiconst.getTodayAttendance));
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data.containsKey('data')) {
            final List<dynamic> studData = data['data'];
            setState(() {
              studentData.clear();
              for (var student in studData) {
                int studentdatum_id = student['studentdatum_id'];
                String status = student['status'];
                studentData.add({
                  'id': student['id'],
                  'date': student['date'],
                  'status': mapStatusToInt(status),
                  'createdAt': student['createdAt'],
                  'updatedAt': student['updatedAt'],
                  'studentdatum_id': studentdatum_id,
                  'full_name': student['full_name'],
                  'shiftdatum_id': student['shiftdatum_id']
                });
              }
            });
            print(studentData.toString());
          } else {
            throw Exception('Data key not found in API response');
          }
        } else {
          throw Exception('Failed to add Todayattendance');
        }
      }
    } catch (e) {
      throw Exception('Failed to add Todayattendance: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String username_d = "";
  String password_d = "";
  @override
  void initState() {
    super.initState();
    GetStorage storage = GetStorage();
    final mydata = storage.read('login_data');

    if (mydata != null) {
      username_d = mydata['data']['login']['username'] ?? "";
      password_d = mydata['data']['login']['password'] ?? "";
    }
    fetchShifts();
    addAndGetTodayattendance();
    studentData.sort((a, b) => a['name'].compareTo(b['name']));
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredStudents = [];
    if (!_isLoading) {
      filteredStudents = studentData
          .where((student) =>
              student['shiftdatum_id'] == int.parse(selectedShift!) &&
              student['full_name']
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
          .toList();
    }

    return _isLoading
        ? Container(
            color: MyTheme.background2,
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
              title: Text(
                "Student Attendance",
                style: TextStyle(
                    color: MyTheme.textcolor,
                    fontSize: getSize(context, 2.7),
                    fontWeight: FontWeight.bold),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(2.0),
                    //   child: Text(
                    //     "Shift",
                    //     style: TextStyle(
                    //         color: MyTheme.textcolor,
                    //         fontSize: getSize(context, 2.4)),
                    //   ),
                    // ),
                    // Container(
                    //   color: MyTheme.background,
                    //   child: Padding(
                    //     padding: EdgeInsets.only(
                    //       left: getWidth(context, 0.02),
                    //       right: getWidth(context, 0.02),
                    //     ),
                    //     child:
                    //         // buildmainDropdown(),
                    //         buildmainDropdown(selectedShift, (value) {
                    //       setState(() {
                    //         selectedShift = value!;
                    //       });
                    //     }, context, shifts),
                    //     // Text("sdsd"),
                    //     // buildDropdown(
                    //     //   selectedShift,
                    //     //   (int? newValue) {
                    //     //     setState(() {
                    //     //       selectedShift = newValue!;
                    //     //     });
                    //     //   },
                    //     //   shifts,
                    //     //   context,
                    //     // ),
                    //   ),
                    // ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            _markAllStudentsPresent();
                          },
                          child: Container(
                            height: getHeight(context, 0.05),
                            width: getWidth(context, 0.3),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: MyTheme.button1.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              'Present All',
                              style: TextStyle(
                                color: MyTheme.button1,
                                fontWeight: FontWeight.w600,
                                fontSize: getSize(context, 2.2),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            addAndGetTodayattendance();
                          },
                          child: Container(
                            height: getHeight(context, 0.05),
                            width: getWidth(context, 0.11),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: MyTheme.mainbutton.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30)),
                            child: Icon(
                              Icons.download,
                              color: MyTheme.mainbutton,
                              size: getSize(context, 2.6),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _markAllStudentsAbsent();
                          },
                          child: Container(
                            height: getHeight(context, 0.05),
                            width: getWidth(context, 0.3),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: MyTheme.button2.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              'Absent All',
                              style: TextStyle(
                                color: MyTheme.button2,
                                fontWeight: FontWeight.w600,
                                fontSize: getSize(context, 2.2),
                              ),
                            ),
                          ),
                        ),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     _markAllStudentsAbsent();
                        //   },
                        //   child: Text('Absent All'),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                      style: TextStyle(color: MyTheme.textcolor),
                      decoration: InputDecoration(
                        labelText: 'Search Student',
                        labelStyle: TextStyle(color: MyTheme.textcolor),
                        suffixIcon: Icon(
                          Icons.search,
                          color: MyTheme.textcolor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      height: getHeight(context, 0.5),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          int status = filteredStudents[index]['status'];
                          return Card(
                            color: MyTheme.background,
                            child: ListTile(
                              title: Text(
                                filteredStudents[index]['full_name'],
                                style: TextStyle(color: MyTheme.textcolor),
                              ),
                              subtitle: Text(
                                _getStatusText(status),
                                style: TextStyle(
                                    color: MyTheme.textcolor.withOpacity(0.5)),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildIconButton(Icons.check,
                                      status == 1 ? Colors.green : Colors.grey,
                                      () {
                                    // _updateStatus(index, 1); // Mark as Present
                                    _updateStatus(filteredStudents[index]['id'],
                                        1); // Mark as Present
                                  }),
                                  _buildIconButton(Icons.cancel,
                                      status == 2 ? Colors.red : Colors.grey,
                                      () {
                                    // _updateStatus(index, 0); // Mark as Absent
                                    _updateStatus(filteredStudents[index]['id'],
                                        2); // Mark as Absent
                                  }),
                                  _buildIconButton(Icons.note_alt,
                                      status == 3 ? Colors.orange : Colors.grey,
                                      () {
                                    // _updateStatus(index, 3); // Mark as On Leave
                                    _updateStatus(filteredStudents[index]['id'],
                                        3); // Mark as On Leave
                                  }),
                                  _buildIconButton(
                                      Icons.unpublished_outlined,
                                      status == -1
                                          ? Colors.lightBlueAccent
                                          : Colors.grey, () {
                                    // _updateStatus(index, 0); // Mark as Absent
                                    _updateStatus(filteredStudents[index]['id'],
                                        -1); // Mark as Absent
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                updateAttendance();
              },
              backgroundColor: MyTheme.mainbutton,
              elevation: 0.0,
              child: Icon(
                Icons.upload,
                color: MyTheme.mainbuttontext,
                size: getSize(context, 3),
              ),
            ),
          );
  }
  // Future<bool> updateDetails() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   Map<String, dynamic> body = {
  //     "id": ,
  //     "status": ,
  //   };
  //   try {
  //     http.Response response = await http.put(
  //       Uri.parse(
  //           Apiconst.updateTeacher), // Use the correct endpoint for updating
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode(body),
  //     );

  //     if (response.statusCode == 200) {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: const Text('Updated successful'),
  //             content: const Text("Going back to login"),
  //             actions: [
  //               TextButton(
  //                 onPressed: () async {
  //                   final storage = GetStorage();
  //                   await storage.remove('login_data');
  //                   await storage.write('logedin', false);
  //                   Navigator.pushReplacement(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => const LoginPage(),
  //                     ),
  //                   );
  //                 },
  //                 child: const Text('OK'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //       return true;
  //     } else {
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return AlertDialog(
  //             title: const Text('Fail'),
  //             content: const Text("Somthing wrong while updating"),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const Text('OK'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //       return false;
  //     }
  //   } catch (e) {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: const Text('Fail'),
  //           content: const Text("Somthing wrong while updating"),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //     return false;
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Widget buildmainDropdown(String? selectedValue, Function(String?) onChanged,
      context, List<Map<String, dynamic>> types) {
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.all(height * 0.011),
      child: Container(
        padding: EdgeInsets.only(left: height * 0.016, right: height * 0.016),
        decoration: BoxDecoration(
          color: MyTheme.background,
          borderRadius: BorderRadius.circular(height * 0.02),
        ),
        child: DropdownButton<String>(
          dropdownColor: MyTheme.background,
          value: selectedValue,
          icon: const Icon(Icons.arrow_drop_down_rounded),
          iconSize: height * 0.04,
          isExpanded: true,
          underline: const SizedBox(),
          style: TextStyle(color: MyTheme.textcolor, fontSize: height * 0.018),
          items: [
            ...types.map((unit) {
              return DropdownMenuItem(
                value: unit["id"].toString(),
                child: Text(unit["name"].toString()),
              );
            }).toList(),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, Function() onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: color,
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case -1:
        return 'undefined';
      case 1:
        return 'Present';
      case 2:
        return 'Absent';
      case 3:
        return 'On Leave';
      default:
        return '';
    }
  }

  void _updateStatus(int id, int newStatus) {
    int index = studentData.indexWhere(
      (student) => student['id'] == id,
    );

    if (index != -1) {
      setState(() {
        studentData[index]['status'] = newStatus;
      });
    }
  }

  void _markAllStudentsPresent() {
    setState(() {
      for (var student in studentData) {
        if (student['shiftdatum_id'].toString() == selectedShift.toString()) {
          student['status'] = 1; // Mark as Present
        }
      }
    });
  }

  void _markAllStudentsAbsent() {
    setState(() {
      for (var student in studentData) {
        if (student['shiftdatum_id'].toString() == selectedShift.toString()) {
          student['status'] = 2; // Mark as Absent
        }
      }
    });
  }
}
