// ignore_for_file: sort_child_properties_last, use_build_context_synchronously

import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_svg/svg.dart';

double getHeight(context, double i) {
  double result = MediaQuery.of(context).size.height * i;
  return result;
}

double getWidth(context, double i) {
  double result = MediaQuery.of(context).size.width * i;
  return result;
}

double getSize(context, double i) {
  double result = MediaQuery.of(context).size.width * i / 50;
  return result;
}

Widget horizontalLine() {
  return SizedBox(
    height: 1.5,
    width: double.infinity,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: MyTheme.background,
      ),
    ),
  );
}

Widget moreOptions(
    List<String> optionNames, List<void Function()> onClickEvents) {
  return PopupMenuButton<String>(
    color: MyTheme.background,
    onSelected: (value) {
      // Handle the selected option
      // You can add different cases based on the value
      // For example, you can open a dialog, navigate to another page, etc.
      for (int i = 0; i < optionNames.length; i++) {
        if (value == optionNames[i]) {
          onClickEvents[i]();
          break;
        }
      }
    },
    itemBuilder: (BuildContext context) {
      List<PopupMenuEntry<String>> items = [];
      for (String option in optionNames) {
        items.add(
          PopupMenuItem<String>(
            value: option,
            child: Text(option),
            textStyle: TextStyle(color: MyTheme.textcolor),
          ),
        );
      }
      return items;
    },
    child: Icon(
      Icons.more_vert,
      color: MyTheme.button1,
    ),
  );
}

Future<void> showFullDescriptionDialog(
    String title, String fullDescription, context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: MyTheme.background,
        title: Text(
          title,
          style: TextStyle(color: MyTheme.highlightcolor),
        ),
        content: Text(
          fullDescription,
          style: TextStyle(color: MyTheme.textcolor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text(
              "OK",
              style: TextStyle(color: MyTheme.button2),
            ),
          ),
        ],
      );
    },
  );
}

Future giveuserinfo(String username, String pass, context) {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      // Replace 'YourUsername' with the actual username
      return Container(
        height: 100,
        color: MyTheme.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                username,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.textcolor),
              ),
              Text(
                pass,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.textcolor),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showGiveWorkPopup(BuildContext context) async {
  TextEditingController textEditingController = TextEditingController();

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: MyTheme.background2,
        title: Text('Give Work', style: TextStyle(color: MyTheme.textcolor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Enter work details:',
                style: TextStyle(color: MyTheme.textcolor)),
            const SizedBox(height: 10),
            TextField(
              style: TextStyle(color: MyTheme.textcolor),
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: 'Work details...',
                hintStyle: TextStyle(color: MyTheme.textcolor),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all(MyTheme.button2.withOpacity(0.2)),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15.0), // Adjust the value as needed
                ),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: MyTheme.button2,
              ),
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(MyTheme.mainbutton),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15.0), // Adjust the value as needed
                ),
              ),
            ),
            onPressed: () {
              // ignore: unused_local_variable
              String workDetails = textEditingController.text;
              // Handle the work details
              // ...
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text(
              'Give',
              style: TextStyle(
                color: MyTheme.mainbuttontext,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget buildMyTextField(String label, TextEditingController controller,
    double width, String inputType, int maxLen, context) {
  TextInputType keyboardType;
  if (inputType == "Number") {
    keyboardType = TextInputType.number;
  } else {
    keyboardType = TextInputType.text;
  }

  return Padding(
    padding: EdgeInsets.only(
        left: getWidth(context, 0.03), right: getWidth(context, 0.03), top: 15),
    child: Container(
      decoration: BoxDecoration(
        color: MyTheme.background,
        borderRadius: BorderRadius.circular(getSize(context, 1.5)),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                  left: getWidth(context, 0.02), top: getWidth(context, 0.02)),
              child: SizedBox(
                width: getWidth(context, 0.8),
                child: Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: MyTheme.textcolor,
                      fontSize: getSize(context, 2.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(getSize(context, 1.2)),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLength: maxLen,
              style: TextStyle(
                color: MyTheme.textcolor,
                fontSize: getSize(context, 2),
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: MyTheme.background2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(getSize(context, 2)),
                ),
                contentPadding: EdgeInsets.all(getSize(context, 1.5)),
                counterStyle: TextStyle(
                  color: MyTheme.textcolor,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildDropdown(
    int selectedValue, Function(int?) onChanged, List<int> values, context) {
  return Padding(
    padding: EdgeInsets.all(getHeight(context, 0.001)),
    child: Container(
      padding: EdgeInsets.only(
          left: getWidth(context, 0.01), right: getWidth(context, 0.01)),
      decoration: BoxDecoration(
        color: MyTheme.background,
        borderRadius: BorderRadius.circular(getHeight(context, 0.001)),
      ),
      child: DropdownButton<int>(
        dropdownColor: MyTheme.background,
        value: selectedValue,
        icon: const Icon(Icons.arrow_drop_down_rounded),
        iconSize: 40,
        isExpanded: true,
        underline: const SizedBox(),
        style: TextStyle(color: MyTheme.textcolor, fontSize: 20),
        items: values.map((unit) {
          return DropdownMenuItem<int>(
            value: unit,
            child: Text(unit.toString()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

Widget showAttendance(
    String boxtitle, context, List<MapEntry<DateTime, int>> dateIntList) {
  return Padding(
    padding: EdgeInsets.all(getSize(context, 1)),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(getSize(context, 1)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: getHeight(context, 0.02),
          ),
          // Row(
          //   children: [
          //     Icon(Icons.arrow_right_outlined,
          //         size: getSize(context, 4), color: MyTheme.textcolor),
          //     Text(
          //       boxtitle,
          //       style: TextStyle(
          //           fontWeight: FontWeight.bold,
          //           fontSize: getSize(context, 2.7),
          //           color: MyTheme.textcolor),
          //     ),
          //   ],
          // ),
          Center(
            child: HeatMapCalendar(
              monthFontSize: getSize(context, 3.7),
              weekTextColor: MyTheme.textcolor,
              textColor: MyTheme.background,
              // iconColor: MyTheme.button1,
              colorTipSize: 0,
              defaultColor: Colors.grey,
              flexible: false,
              // monarrowSize: getSize(context, 4),
              size: getSize(context, 4.8),
              // monColor: MyTheme.textcolor,
              colorMode: ColorMode.color,
              datasets: Map.fromEntries(dateIntList),
              colorsets: const {
                -1: Colors.grey,
                1: Colors.green,
                2: Colors.red,
                3: Colors.orange,
              },
              onClick: (value) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(content: Text(value.toString())));
              },
            ),
          ),
          SizedBox(
            height: getHeight(context, 0.01),
          ),
          SizedBox(
            height: getHeight(context, 0.002),
            child: Container(
              color: Colors.grey,
            ),
          ),
          SizedBox(
            height: getHeight(context, 0.01),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Container(
                    height: getHeight(context, 0.029),
                    width: getHeight(context, 0.029),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.circular(getSize(context, 0.6))),
                  ),
                  SizedBox(
                    width: getWidth(context, 0.02),
                  ),
                  Text(
                    "Absent",
                    style: TextStyle(
                        fontSize: getSize(context, 1.8),
                        color: MyTheme.textcolor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    height: getHeight(context, 0.029),
                    width: getHeight(context, 0.029),
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius:
                            BorderRadius.circular(getSize(context, 0.6))),
                  ),
                  SizedBox(
                    width: getWidth(context, 0.02),
                  ),
                  Text(
                    "Present",
                    style: TextStyle(
                        fontSize: getSize(context, 1.8),
                        color: MyTheme.textcolor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    height: getHeight(context, 0.029),
                    width: getHeight(context, 0.029),
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius:
                            BorderRadius.circular(getSize(context, 0.6))),
                  ),
                  SizedBox(
                    width: getWidth(context, 0.02),
                  ),
                  Text(
                    "On Leave",
                    style: TextStyle(
                        fontSize: getSize(context, 1.8),
                        color: MyTheme.textcolor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            height: getWidth(context, 0.025),
          ),
        ],
      ),
    ),
  );
}

class LogoTransparent extends StatelessWidget {
  const LogoTransparent({super.key});

  @override
  Widget build(BuildContext context) {
    // AssetImage assetImage = AssetImage('assets/logo_transparent.png');
    // Image image = Image(image: assetImage);
    return Container(
      child: SvgPicture.asset(
        'assets/logo.png',
        semanticsLabel: 'My SVG Image',
        height: getHeight(context, 0.005),
        width: getWidth(context, 0.005),
      ),
    );
  }
}
