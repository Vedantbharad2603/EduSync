import 'dart:async';

import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/tools/helper.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final box = GetStorage();
  late Animation<double> scaleAnimation;
  late AnimationController scaleController;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();

    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addStatusListener(
        (status) async {
          if (status == AnimationStatus.completed) {
            Get.offAllNamed("/mynavigator");
          }
        },
      );

    scaleAnimation = Tween<double>(begin: 0.0, end: 7).animate(scaleController);

    // Fade in after 500ms to fit within the 2 seconds
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        scaleController.forward();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.mainbackground,
      body: Center(
        child: AnimatedOpacity(
          curve: Curves.fastLinearToSlowEaseIn,
          duration: const Duration(milliseconds: 500),
          opacity: _opacity,
          child: AnimatedContainer(
            curve: Curves.fastLinearToSlowEaseIn,
            duration: const Duration(milliseconds: 1000),
            height: getHeight(context, 0.25),
            width: getWidth(context, 0.5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: scaleAnimation,
                  builder: (c, child) => Transform.scale(
                    scale: scaleAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MyTheme.background,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 200, // Set the desired width
                      height: 200, // Set the desired height
                      fit: BoxFit
                          .cover, // Ensures the image fits within the circular shape
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
