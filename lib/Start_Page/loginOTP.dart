// ignore_for_file: prefer_final_fields, use_build_context_synchronously, file_names

import 'package:edu_sync/tools/OTPSender.dart';
import 'package:edu_sync/tools/apiconst.dart';
import 'package:edu_sync/tools/helper.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'dart:math';

class LoginOTP extends StatefulWidget {
  const LoginOTP({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginOTPState createState() => _LoginOTPState();
}

class _LoginOTPState extends State<LoginOTP> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  late Map<String, dynamic> data;
  late String myOTP;
  String generateOTP() {
    Random random = Random();
    int otp = random.nextInt(10000);
    return otp.toString().padLeft(4, '0');
  }

  Future<void> checkOTP(String otpin) async {
    if (otpin == myOTP) {
      final storage = GetStorage();
      await storage.write('login_data', data);
      await storage.write('logedin', true);
      final mydata = storage.read('login_data');
      if (mydata != null) {
        String userType = mydata['data']['login']['type'];
        if (userType == 'student') {
          Get.offAllNamed("/studentmaster");
        } else {
          Get.offAllNamed("/teachermaster");
        }
      } else {
        // log('Error reading login data from storage'.toString());
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Wrong OTP'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _login(String email) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, String> body = {
      'email': email,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(Apiconst.findemail),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        data = json.decode(response.body);
        if (data['message'] == 'Error' && data['data'] == 'no login found') {
          // Show a popup for incorrect password
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Email not found'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          myOTP = generateOTP();
          OTPSender emailService = OTPSender();
          String mailStatus = await emailService.sendOTP(email, myOTP);
          if (mailStatus == "Email sent successfully") {
            setState(() {
              _otpSent = true;
            });
          }
          String dialogMessage = mailStatus == 'Email sent successfully'
              ? 'Email sent successfully'
              : 'Failed to send email. Please try again later.';
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Status'),
                content: Text(dialogMessage),
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
      } else {
        // Handle unsuccessful login response
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Status'),
              content: const Text("Login failed"),
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
    } catch (socketException) {
      // Handle SocketException
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No Internet Connection'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.mainbackground,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                color: MyTheme.mainbackground,
                child: Column(
                  children: <Widget>[
                    // Stack(
                    //   children: <Widget>[

                    //   ],
                    // ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: getWidth(context, 0.045),
                          right: getWidth(context, 0.045),
                          top: getHeight(context, 0.01)),
                      child: Container(
                        decoration: BoxDecoration(
                            color: MyTheme.background,
                            borderRadius:
                                BorderRadius.circular(getSize(context, 2))),
                        child: Padding(
                          padding: EdgeInsets.all(getSize(context, 3)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: getWidth(context, 0.8),
                                child: Expanded(
                                  child: Text(
                                    "Login using OTP",
                                    style: TextStyle(
                                      color: MyTheme.textcolor,
                                      fontSize: getSize(context, 2.8),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: getHeight(context, 0.02)),
                              TextField(
                                controller: _emailController,
                                style: TextStyle(color: MyTheme.textcolor),
                                decoration: InputDecoration(
                                  labelText: 'Email ID',
                                  labelStyle: TextStyle(
                                      color:
                                          MyTheme.textcolor.withOpacity(0.6)),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            MyTheme.textcolor.withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(
                                      getSize(context, 1.8),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            MyTheme.textcolor.withOpacity(0.8)),
                                    borderRadius: BorderRadius.circular(
                                      getSize(context, 1.8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: getHeight(context, 0.025)),
                              Visibility(
                                visible: !_otpSent,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () {
                                      String emailid =
                                          _emailController.text.trim();
                                      if (emailid.isNotEmpty) {
                                        _login(emailid);
                                      } else {
                                        // Show snackbar for entering email
                                        const snackBar = SnackBar(
                                          content:
                                              Text('Please enter your email.'),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      }
                                    },
                                    child: Container(
                                      height: getHeight(context, 0.06),
                                      width: getWidth(context, 0.5),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: MyTheme.mainbutton,
                                        borderRadius: BorderRadius.circular(
                                            getSize(context, 2.5)),
                                      ),
                                      child: Text(
                                        'Send OTP',
                                        style: TextStyle(
                                          color: MyTheme.mainbuttontext,
                                          fontWeight: FontWeight.w600,
                                          fontSize: getSize(context, 2.8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _otpSent,
                                child: Column(
                                  children: [
                                    SizedBox(height: getHeight(context, 0.025)),
                                    TextField(
                                      controller: _otpController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]')),
                                        LengthLimitingTextInputFormatter(4),
                                      ],
                                      style:
                                          TextStyle(color: MyTheme.textcolor),
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: MyTheme.textcolor
                                                  .withOpacity(0.2)),
                                          borderRadius: BorderRadius.circular(
                                            getSize(context, 1.8),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: MyTheme.textcolor
                                                  .withOpacity(0.8)),
                                          borderRadius: BorderRadius.circular(
                                            getSize(context, 1.8),
                                          ),
                                        ),
                                        labelText: 'Enter OTP',
                                        labelStyle: TextStyle(
                                            color: MyTheme.textcolor
                                                .withOpacity(0.6)),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              getSize(context, 1.8)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: getHeight(context, 0.025)),
                                    InkWell(
                                      onTap: () {
                                        String otpin = _otpController.text;
                                        checkOTP(otpin);
                                        // _login(username, password);
                                      },
                                      child: Container(
                                        height: getHeight(context, 0.06),
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: MyTheme.mainbutton,
                                          borderRadius: BorderRadius.circular(
                                              getSize(context, 2.5)),
                                        ),
                                        child: Text(
                                          'Continue',
                                          style: TextStyle(
                                            color: MyTheme.mainbuttontext,
                                            fontWeight: FontWeight.w600,
                                            fontSize: getSize(context, 2.8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: getHeight(context, 0.02)),
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {
                                    Get.offAllNamed("/login");
                                  },
                                  child: Text(
                                    'Back to Login',
                                    style: TextStyle(
                                        color: MyTheme.mainbuttontext,
                                        fontSize: getSize(context, 1.9)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
