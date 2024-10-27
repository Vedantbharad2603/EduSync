import 'package:edu_sync/tools/Components.dart';
import 'package:edu_sync/tools/apiconst.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ManageTeacher extends StatefulWidget {
  const ManageTeacher({super.key});

  @override
  State<ManageTeacher> createState() => _ManageTeacherState();
}

class _ManageTeacherState extends State<ManageTeacher> {
  List<Map<String, dynamic>> teacherData = [];
  bool _isLoading = false;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchTeachers();
    teacherData.sort((a, b) => a['username'].compareTo(b['username']));
  }

  Future<void> fetchTeachers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(Apiconst.getTeacher));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // print(responseData['data'][0]['login']);
        if (responseData.containsKey('data')) {
          List<dynamic> data = responseData['data'];
          List<Map<String, dynamic>> updatedTeacherData = [];
          for (var teacher in data) {
            updatedTeacherData.add({
              'id': teacher['login']['id'],
              'username': teacher['login']['username'],
              'type': teacher['login']['type'],
              'is_active': teacher['login']['is_active'],
            });
          }
          setState(() {
            teacherData = updatedTeacherData;
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

  Future<void> changestatus(int id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> body = {"id": id};

      final response = await http.put(
        Uri.parse(Apiconst.changeLoginstatus),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text("Teacher Status updated."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        setState(() {
          fetchTeachers();
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text("Failed to change role of teacher"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> changeType(int id, String type) async {
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic> body = {"id": id, "type": type};

      final response = await http.put(
        Uri.parse(Apiconst.changeType),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text("Teacher role updated."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        setState(() {
          fetchTeachers();
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text("Failed to change role of teacher"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void deleteTeacher(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MyTheme.background,
          title: Text(
            "Confirm Deletion",
            style: TextStyle(color: MyTheme.textcolor),
          ),
          content: Text(
            "Are you sure you want to delete this teacher?",
            style: TextStyle(color: MyTheme.textcolor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.green.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  teacherData.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.red.withOpacity(0.7)),
              ),
            ),
          ],
        );
      },
    );
  }

  void toggleActiveStatus(int index) {
    setState(() {
      teacherData[index]['is_active'] = !teacherData[index]['is_active'];
    });
  }

  void changeRole(int index, String newRole) {
    setState(() {
      teacherData[index]['type'] = newRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTeachers = teacherData
        .where((teacher) => teacher['username']
            .toLowerCase()
            .contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: MyTheme.background2,
      appBar: AppBar(
        backgroundColor: MyTheme.themeColor2,
        centerTitle: true,
        title: Text(
          'Teacher Management',
          style: TextStyle(
              color: MyTheme.textcolor,
              fontSize: getSize(context, 2.8),
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: MyTheme.textcolor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                      style: TextStyle(color: MyTheme.textcolor),
                      decoration: InputDecoration(
                        labelText: 'Search Teacher',
                        labelStyle: TextStyle(color: MyTheme.textcolor),
                        suffixIcon: Icon(
                          Icons.search,
                          color: MyTheme.textcolor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SizedBox(
                      height: getHeight(context, 0.7),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredTeachers.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> teacher =
                              filteredTeachers[index];
                          return Padding(
                            padding: EdgeInsets.all(getSize(context, 0.7)),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(getSize(context, 1)),
                                color: MyTheme.background,
                                boxShadow: [
                                  BoxShadow(
                                    color: MyTheme.boxshadow,
                                    spreadRadius: getSize(context, 0.5),
                                    blurRadius: getSize(context, 0.8),
                                    offset: Offset(0, getSize(context, 0.3)),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.all(getSize(context, 1)),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: getSize(context, 1)),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                teacher['username'],
                                                style: TextStyle(
                                                  fontSize:
                                                      getSize(context, 2.7),
                                                  fontWeight: FontWeight.bold,
                                                  color: teacher['is_active']
                                                      ? MyTheme.textcolor
                                                      : MyTheme.textcolor
                                                          .withOpacity(0.3),
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    getHeight(context, 0.001),
                                              ),
                                              Text(
                                                teacher['type'],
                                                style: TextStyle(
                                                  fontSize:
                                                      getSize(context, 1.7),
                                                  fontWeight: FontWeight.bold,
                                                  color: MyTheme.textcolor
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // IconButton(
                                      //   onPressed: () => deleteTeacher(index),
                                      //   icon: Icon(Icons.delete_outline),
                                      //   color: Colors.red,
                                      // ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            changestatus(teacher['id']),
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty
                                              .resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                  MaterialState.disabled)) {
                                                return Colors
                                                    .grey; // Disabled color
                                              }
                                              return teacher['is_active']
                                                  ? MyTheme.button1
                                                      .withOpacity(0.2)
                                                  : MyTheme.button2
                                                      .withOpacity(0.2);
                                            },
                                          ),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              side: BorderSide(
                                                color: teacher['is_active']
                                                    ? MyTheme.button1
                                                    : MyTheme.button2,
                                                width: getWidth(context, 0.005),
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          teacher['is_active']
                                              ? "Activate"
                                              : "Deactivate",
                                          style: TextStyle(
                                              color: teacher['is_active']
                                                  ? MyTheme.textcolor
                                                  : MyTheme.textcolor),
                                        ),
                                      ),
                                      DropdownButton<String>(
                                        style:
                                            TextStyle(color: MyTheme.textcolor),
                                        dropdownColor: MyTheme.background,
                                        value: teacher['type'],
                                        onChanged: (newValue) => changeType(
                                            teacher['id'], newValue!),
                                        items: <String>[
                                          'admin',
                                          'teacher',
                                          'trainee'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  )
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
    );
  }

  Widget buildmainDropdown(String selectedValue, Function(String?) onChanged,
      context, List<String> types) {
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
          items: types.map((unit) {
            return DropdownMenuItem(
              value: unit,
              child: Text(unit),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
