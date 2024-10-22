import 'package:flutter/material.dart';
import 'package:edu_sync/tools/helper.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final box = GetStorage(); // GetStorage instance

  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 1));
    Get.offAllNamed("/mynavigator");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image(
          image: const AssetImage('assets/images/mu_logo.png'),
          height: getHeight(context, 0.13),
        ),
      ),
    );
  }
}
