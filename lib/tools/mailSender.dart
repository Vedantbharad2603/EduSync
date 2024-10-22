import 'package:get/get.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  Future<String> sendEmail(String type, String email, String name,
      String usernamein, String passwordin) async {
    String username = 'vedantbharad26@gmail.com'; // Your Gmail address
    String password = 'bsli ymzm wgbz xqzc'; // Your Gmail password
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'App') // Your name
      ..recipients.add(email) // Recipient's email address
      ..subject = 'Welcome to App!';
    if (type == 'student') {
      message.html = '''
      <h2><p>Dear $name,</p></h2>
      <h4><p>Welcome to our App! We're thrilled to have you join us.</p></h4>
      <h4><p>Your login credentials:</p></h4>
      <p><strong>Username:</strong> $usernamein</p>
      <p><strong>Password:</strong> $passwordin</p>
      <p>We hope you have a great learning experience with us.</p>
      <p>Best regards,<br>Your Team at App</p>
      ''';
    } else {
      message.html = '''
      <h2><p>Dear $name,</p></h2>
      <h4><p>Welcome to our App! We're excited to have you on board as a $type.</p></h4>
      <h4><p>Your login credentials:</p></h4>
      <p><strong>Username:</strong> $usernamein</p>
      <p><strong>Password:</strong> $passwordin</p>
      <p>We look forward to working with you and hope you have a rewarding experience teaching at App.</p>
      <p>Best regards,<br>Your Team at App</p>
      ''';
    }
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
      Get.snackbar('Success', 'Email sent successfully');
      return 'Email sent successfully';
    } catch (error) {
      print('Error sending email: $error');
      Get.snackbar('Error', 'Failed to send email. Please try again later.');
      return 'Failed to send email. Please try again later.';
    }
  }
}
