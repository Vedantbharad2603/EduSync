import 'package:edu_sync/Student_Screen/AttendancePage.dart';
import 'package:edu_sync/Start_Page/Mynavigator.dart';
import 'package:edu_sync/Student_Screen/st_Holidays.dart';
import 'package:edu_sync/Student_Screen/st_messages.dart';
import 'package:edu_sync/Student_Screen/st_show_events.dart';
import 'package:edu_sync/Student_Screen/st_timetable.dart';
import 'package:edu_sync/Teacher_Screen/AddEvent.dart';
import 'package:edu_sync/Teacher_Screen/Attendance.dart';
import 'package:edu_sync/Teacher_Screen/ListofHolidays.dart';
import 'package:edu_sync/Teacher_Screen/ManageTeacher.dart';
import 'package:edu_sync/Teacher_Screen/Messages.dart';
import 'package:edu_sync/Teacher_Screen/UpdateTimetablePage.dart';
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
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set portrait orientation
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Initialize GetStorage and TimeZone
  await GetStorage.init();
  tz.initializeTimeZones();

  // Initialize notification settings
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings, iOS: iosSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Request notification permissions
  await requestNotificationPermissions();

  runApp(MyApp());
}

// Request notification and ignore battery optimizations permissions
Future<void> requestNotificationPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  if (await Permission.ignoreBatteryOptimizations.isDenied) {
    await Permission.ignoreBatteryOptimizations.request();
  }
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
            name: "/teacherattendance",
            transition: Transition.fadeIn,
            page: () => const Attendance()),
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
        GetPage(
            name: "/teacherHolidays",
            transition: Transition.fadeIn,
            page: () => const ListofHolidays()),
        GetPage(
            name: "/updateTimetable",
            transition: Transition.fadeIn,
            page: () => UpdateTimetablePage()),
        GetPage(
            name: "/manageTeacher",
            transition: Transition.fadeIn,
            page: () => const ManageTeacher()),
        GetPage(
            name: "/addEventPage",
            transition: Transition.fadeIn,
            page: () => const AddEventPage()),
        GetPage(
            name: "/messages",
            transition: Transition.fadeIn,
            page: () => const Messages()),
        GetPage(
            name: "/showEvents",
            transition: Transition.fadeIn,
            page: () => const StShowEvents()),
        GetPage(
            name: "/stTimeTable",
            transition: Transition.fadeIn,
            page: () => const StTimeTable()),
        GetPage(
            name: "/stHolidays",
            transition: Transition.fadeIn,
            page: () => const StHolidays()),
      ],
      initialRoute: "/splashscreen",
    );
  }
}
