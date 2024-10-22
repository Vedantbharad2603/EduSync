// ignore_for_file: unused_local_variable, file_names

import 'package:get/get.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class OTPSender {
  Future<String> sendOTP(String email, String otp) async {
    String username = 'vedantbharad26@gmail.com'; // Your Gmail address
    String password = 'bsli ymzm wgbz xqzc'; // Your Gmail password
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'LORETO') // Your name
      ..recipients.add(email) // Recipient's email address
      ..subject = 'Your OTP for Login';
    message.html = '''
      <h4><p>Welcome back to LORETO!</p></h4>
      <h4><p>Your OTP is <span style="background-color: #ffff00; color: #000000; padding: 2px 4px; border-radius: 4px;">$otp</span></p></h4>
    ''';

    try {
      final sendReport = await send(message, smtpServer);
      // print('Message sent: ' + sendReport.toString());
      Get.snackbar('Success', 'Email sent successfully');
      return 'Email sent successfully';
    } catch (error) {
      Get.snackbar('Error', 'Failed to send email. Please try again later.');
      return 'Failed to send email. Please try again later.';
    }
  }
}
