import 'package:edu_sync/Student_Screen/AttendancePage.dart';
import 'package:edu_sync/Start_Page/Mynavigator.dart';
import 'package:edu_sync/Student_Screen/st_messages.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/Start_Page/SplashScreen.dart';
import 'package:edu_sync/Start_Page/login.dart';
import 'package:edu_sync/Start_Page/loginOTP.dart';
import 'package:edu_sync/masterpage/studentDashboard.dart';
import 'package:edu_sync/masterpage/teacherDashboard.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
            name: "/splashscreen",
            transition: Transition.fadeIn,
            page: () => const SplashScreen()),
        GetPage(
            name: "/login",
            transition: Transition.fadeIn,
            page: () => const LoginPage()),
        GetPage(
            name: "/loginOTP",
            transition: Transition.fadeIn,
            page: () => const LoginOTP()),
        GetPage(
            name: "/studentmaster",
            transition: Transition.fadeIn,
            page: () => const StudentDashboard()),
        GetPage(
            name: "/teachermaster",
            transition: Transition.fadeIn,
            page: () => const TeacherDashboard()),
        GetPage(
            name: "/mynavigator",
            transition: Transition.fadeIn,
            page: () => const Mynavigator()),
        GetPage(
          name: "/attendancepage",
          transition: Transition.fadeIn,
          page: () {
            final args = Get.arguments as Map<String, dynamic>;
            return AttendancePage(studentid: args['studentid']);
          },
        ),
        GetPage(
            name: "/stMessages",
            transition: Transition.fadeIn,
            page: () => const MessagesScreen()),
      ],
      initialRoute: "/splashscreen",
    );
  }
}
