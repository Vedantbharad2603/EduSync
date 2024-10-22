// ignore_for_file: non_constant_identifier_names

import 'package:edu_sync/Model/MessageModel.dart';
import 'package:edu_sync/tools/helper.dart';
import 'package:edu_sync/tools/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<MessageModel> updates = [];
  bool _shouldScrollToBottom = false;

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

  void scrolldown() {
    _shouldScrollToBottom = true;
  }

  Future<void> _handleRefresh() async {
    // Simulate reloading data (replace this with your actual refresh logic)
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      updates = updates;
    });
  }

  String username_d = "";
  String password_d = "";
  @override
  void initState() {
    super.initState();
    super.initState();
    GetStorage storage = GetStorage();
    final mydata = storage.read('login_data');
    if (mydata != null) {
      username_d = mydata['data']['login']['username'] ?? "";
      password_d = mydata['data']['login']['password'] ?? "";
    }
  }

  void sortMessagesByTimestamp() {
    updates.sort((a, b) =>
        DateTime.parse(a.datetime).compareTo(DateTime.parse(b.datetime)));

    scrolldown();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyTheme.mainbackground,
        appBar: AppBar(
          backgroundColor: MyTheme.mainbuttontext,
          shadowColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: MyTheme.textcolor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: Text(
            "Noticeboard",
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
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_shouldScrollToBottom) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                        _shouldScrollToBottom =
                            false; // Reset the flag after scrolling
                      }
                    });
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
                                        color:
                                            MyTheme.textcolor.withOpacity(0.7),
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
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String messageId;
  final String message;
  final String dateTime;
  final int index; // Add the index parameter

  const ChatBubble({
    Key? key,
    required this.messageId,
    required this.message,
    required this.dateTime,
    required this.index, // Include the index parameter in the constructor
    // required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime parsedDateTime = DateTime.parse(dateTime);
    String formattedDateTime = DateFormat('hh:mm a').format(parsedDateTime);

    return GestureDetector(
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
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    // IconButton(
                    //   onPressed: onDelete,
                    //   icon: Icon(
                    //     Icons.delete,
                    //     color: MyTheme.textcolor.withOpacity(0.7),
                    //   ),
                    // ),
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
