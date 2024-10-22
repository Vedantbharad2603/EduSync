import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class Mynavigator extends StatelessWidget {
  const Mynavigator({Key? key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final isLoggedIn = storage.read('logedin') ?? false;

    if (!isLoggedIn) {
      // If not logged in, redirect to login page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed("/login");
      });
      return Container(); // Placeholder widget
    }

    // If logged in, check user type
    final mydata = storage.read('login_data');

    if (mydata != null) {
      String userType = mydata['data']['login']['type'];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (userType == 'student') {
          Get.offAllNamed("/studentmaster");
        } else {
          Get.offAllNamed("/teachermaster");
        }
      });
      return Container(); // Placeholder widget
    } else {
      print('Error reading login data from storage');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed("/login");
      });
      return Container(); // Placeholder widget
    }
  }
}
