import 'package:edu_sync/tools/Colors.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'Style.dart';

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

Widget BlackTag(context, Color? color, String? Line1, String? Line2,
    Widget? imageWidget, Widget? logout, bool isReverse) {
  return Container(
    alignment: Alignment.centerRight,
    child: Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // Conditional alignment
      children: isReverse
          ? [
              Container(
                height: 65,
                width: 50,
                decoration: BoxDecoration(
                  color: color ?? Colors.black,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(500),
                  ),
                ),
                child: logout,
              ),
              Container(
                height: 65,
                width: 300,
                decoration: BoxDecoration(
                  color: color ?? Colors.black,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(500),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        height: 55,
                        width: 55,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(500))),
                        child: imageWidget,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: getWidth(context, 0.5),
                            child: Text(
                              Line1 ?? "Loading...",
                              overflow: TextOverflow.ellipsis,
                              style: tagStyle(Colors.white, 18, true),
                            ),
                          ),
                          Text(
                            Line2 ?? "Loading...",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: tagStyle(Light2, 15, false),
                          ),
                          // Text(
                          //   ,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: tagStyle(Light2, 15, false),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]
          : [
              Container(
                height: 65,
                width: 300,
                decoration: BoxDecoration(
                  color: color ?? Colors.black,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(500),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: Text(
                              Line1 ?? "Loading...",
                              overflow: TextOverflow.ellipsis,
                              style: tagStyle(Colors.white, 18, true),
                            ),
                          ),
                          Text(
                            Line2 ?? "Loading...",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: tagStyle(Light2, 15, false),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        height: 55,
                        width: 55,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(500))),
                        child: imageWidget,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 65,
                width: 50,
                decoration: BoxDecoration(
                  color: color ?? Colors.black,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(500),
                  ),
                ),
                child: logout,
              ),
            ],
    ),
  );
}

Widget TapIcons(
  context,
  String name,
  double nameSize,
  String iconFilename,
  double iconSize,
  String route,
  routeArg,
) {
  return InkWell(
    onTap: () => Get.toNamed(route, arguments: routeArg),
    child: Container(
      child: Column(
        children: [
          Container(
            height: 75,
            width: 75,
            decoration: BoxDecoration(
              color: MyTheme.background2,
              borderRadius: BorderRadius.circular(15), // rounded corners
            ),
            child: Center(
              child: Container(
                height: iconSize,
                width: iconSize,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/MainIcons/$iconFilename"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
              height: getHeight(context, 0.05),
              width: getWidth(context, 0.25),
              child: Center(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: 'mu_reg',
                      color: muColor,
                      height: 1,
                      fontSize: getSize(context, nameSize)),
                  // softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ))
        ],
      ),
    ),
  );
}

RadialIndicator(BuildContext context, double input) {
  return Stack(
    alignment: Alignment.center,
    children: [
      TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: input),
        duration: const Duration(seconds: 1),
        curve: Easing.linear,
        builder: (context, value, child) {
          return Center(
            child: Text(
              '${value.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize:
                    value < 100 ? getSize(context, 3.5) : getSize(context, 3),
                fontFamily: "mu_bold",
                color: muColor,
              ),
            ),
          );
        },
      ),
      TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: input / 100),
        duration: const Duration(seconds: 1),
        curve: Easing.linear,
        builder: (context, value, child) {
          return SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: value,
              backgroundColor: muGrey2,
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(muColor),
            ),
          );
        },
      ),
    ],
  );
}

Heading1(context, String str, double size, double leftPad) {
  return Padding(
    padding: EdgeInsets.only(top: 8.0, bottom: 4, left: leftPad),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Container(
            height: getSize(context, size * 1.5),
            width: getSize(context, size * 0.35),
            decoration: BoxDecoration(
                color: muColor, borderRadius: BorderRadius.circular(500)),
          ),
        ),
        Text(
          str,
          style: TextStyle(
            fontFamily: "mu_bold",
            fontSize: getSize(context, size),
            letterSpacing: 0.1,
          ),
        ),
      ],
    ),
  );
}

AttendanceCard(context, String subName, String facName, String startTime,
    String endTime, String status, String lecType) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
          color: muGrey,
          borderRadius: BorderRadius.circular(getSize(context, 1.5)),
          border: Border.all(color: Colors.black.withOpacity(0.1))),
      child: Card(
        color: Colors.transparent,
        elevation: null,
        shadowColor: Colors.transparent,
        child: ListTile(
          title: Text(
            "$subName  ( $lecType )",
            style: TextStyle(
              letterSpacing: 0,
              fontSize: getSize(context, 2.4),
              fontFamily: 'mu_bold',
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.access_time_outlined,
                      color: Colors.black.withOpacity(0.25),
                      size: getSize(context, 3),
                    ),
                  ),
                  Text(
                      "$startTime ${int.parse(startTime.substring(0, 1)) < 12 ? "AM" : "PM"} "
                      "to "
                      "$endTime ${int.parse(endTime.substring(0, 1)) < 12 ? "AM" : "PM"} ",
                      style: TextStyle(
                        fontSize: getSize(context, 1.8),
                        fontFamily: 'mu_reg',
                      )),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.person_outlined,
                      color: Colors.black.withOpacity(0.25),
                      size: getSize(context, 3),
                    ),
                  ),
                  Text(facName,
                      style: TextStyle(
                        fontSize: getSize(context, 1.8),
                        fontFamily: 'mu_reg',
                      )),
                ],
              ),
            ],
          ),
          trailing: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(500),
              color: status == 'Present' ? Colors.green : Colors.redAccent,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Text(
                status,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getSize(context, 2),
                  fontFamily: 'mu_reg',
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
