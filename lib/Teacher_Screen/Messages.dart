// ignore_for_file: file_names, non_constant_identifier_names, use_build_context_synchronously

import 'package:edu_sync/Model/MessageModel.dart';
import 'package:edu_sync/tools/Components.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final TextEditingController _messageController = TextEditingController();
  List<MessageModel> updates = [];

  final ScrollController _scrollController = ScrollController();

  bool _shouldShowDateHeader(int index) {
    if (index == 0) {
      return true; // Always show date header for the first message
    }

    DateTime currentDate = DateTime.parse(updates[index].datetime);
    DateTime previousDate = DateTime.parse(updates[index - 1].datetime);

    return currentDate.day != previousDate.day ||
        currentDate.month != previousDate.month ||
        currentDate.year != previousDate.year;
  }

  Future<void> _handleRefresh() async {
    // Simulate reloading data (replace this with your actual refresh logic)
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      updates = updates;
    });
  }

  late int senderid;
  String username_d = "";
  String password_d = "";
  @override
  void initState() {
    super.initState();
    GetStorage storage = GetStorage();
    final mydata = storage.read('login_data');

    if (mydata != null) {
      senderid = mydata['data']['userdata']['id'] ?? 0;
      username_d = mydata['data']['login']['username'] ?? "";
      password_d = mydata['data']['login']['password'] ?? "";
    }
    // studentData.sort((a, b) => a['full_name'].compareTo(b['full_name']));
  }

  void sortMessagesByTimestamp() {
    updates.sort((a, b) => a.datetime.compareTo(b.datetime));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.mainbackground,
      appBar: AppBar(
        backgroundColor: MyTheme.themeColor2,
        shadowColor: Colors.transparent,
        title: Text(
          "Updates",
          style: TextStyle(
            color: MyTheme.textcolor,
            fontSize: getSize(context, 2.7),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  updates.clear();
                  for (var doc in snapshot.data!.docs) {
                    dynamic timestampData =
                        doc['timestamp']; // Retrieve the timestamp field
                    Timestamp timestamp;
                    if (timestampData is Timestamp) {
                      timestamp = timestampData
                          as Timestamp; // If it's already a Timestamp, use it directly
                    } else if (timestampData is String) {
                      timestamp = Timestamp.fromDate(DateTime.parse(
                          timestampData)); // If it's a string, parse it to DateTime first
                    } else {
                      // Handle other cases as needed
                      continue;
                    }
                    DateTime dateTime = timestamp.toDate();
                    updates.add(MessageModel(
                      messageId: doc.id,
                      datetime: dateTime.toString(),
                      description: doc['message'],
                    ));
                  }

                  sortMessagesByTimestamp();
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: updates.length,
                    itemBuilder: (context, index) {
                      bool showDateHeader = _shouldShowDateHeader(index);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader)
                            Center(
                              child: Container(
                                height: 30,
                                width: getWidth(context, 0.50),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: MyTheme.background,
                                ),
                                child: Center(
                                  child: Text(
                                    DateFormat('MMMM d, yyyy').format(
                                      DateTime.parse(updates[index].datetime),
                                    ),
                                    style: TextStyle(
                                      color: MyTheme.textcolor.withOpacity(0.7),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ChatBubble(
                            messageId: updates[index].messageId,
                            message: updates[index].description,
                            dateTime: updates[index].datetime,
                            index: index,
                            onDelete: _deleteMessage,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: MyTheme
                            .background, // Set your desired background color
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: MyTheme.textcolor.withOpacity(0.6),
                            width: 2)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextField(
                        style:
                            TextStyle(color: MyTheme.textcolor, fontSize: 18),
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Messages',
                          hintStyle: TextStyle(
                              color: MyTheme.textcolor.withOpacity(0.6),
                              fontSize: 18),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          // border: OutlineInputBorder(
                          //     borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: MyTheme.mainbutton,
                  ),
                  child: IconButton(
                    onPressed: _addNewMessage,
                    icon: const Icon(Icons.send),
                    color: MyTheme.textcolor,
                    padding: const EdgeInsets.all(8),
                    splashRadius: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNewMessage() async {
    if (_messageController.text.isNotEmpty) {
      DateTime now = DateTime.now();
      String formattedDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS').format(now);

      try {
        await FirebaseFirestore.instance.collection('messages').add({
          'timestamp': formattedDateTime,
          'message': _messageController.text,
        });

        setState(() {
          updates.add(
            MessageModel(
              datetime: formattedDateTime,
              description: _messageController.text,
            ),
          );
          _messageController.clear();
          // Scroll to the bottom after adding a new message
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      } catch (e) {
        // Handle the error, for example, show a snackbar with the error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _deleteMessage(String messageId, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: MyTheme.background,
          title: Text(
            'Delete Message',
            style: TextStyle(color: MyTheme.textcolor),
          ),
          content: Text(
            'Are you sure you want to delete this message?',
            style: TextStyle(color: MyTheme.textcolor),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(MyTheme.button2.withOpacity(0.2)),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        15.0), // Adjust the value as needed
                  ),
                ),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('messages')
                    .doc(messageId)
                    .delete();
                setState(() {
                  updates.removeAt(index);
                });
                Navigator.of(context, rootNavigator: true).pop();
                // WidgetsBinding.instance.addPostFrameCallback((_) {
                //   Navigator.pop(context);
                // });
              },
              child: Text(
                'Delete',
                style: TextStyle(color: MyTheme.button2),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    MyTheme.mainbuttontext.withOpacity(0.2)),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        15.0), // Adjust the value as needed
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: MyTheme.mainbuttontext),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String messageId;
  final String message;
  final String dateTime;
  final int index; // Add the index parameter

  final Function(String, int) onDelete; // Update the type of onDelete

  const ChatBubble({
    Key? key,
    required this.messageId,
    required this.message,
    required this.dateTime,
    required this.index, // Include the index parameter in the constructor
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime parsedDateTime = DateTime.parse(dateTime);
    String formattedDateTime = DateFormat('hh:mm a').format(parsedDateTime);

    return GestureDetector(
      onLongPress: () => onDelete(
          messageId, index), // Pass the messageId and index to onDelete
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MyTheme.background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: MyTheme.boxshadow,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                            color: MyTheme.textcolor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDateTime,
                  style: TextStyle(
                    color: MyTheme.textcolor.withOpacity(0.7),
                    fontSize: 12,
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
