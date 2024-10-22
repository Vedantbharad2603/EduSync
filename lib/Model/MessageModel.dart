// ignore_for_file: file_names

class MessageModel {
  final String messageId;
  final String datetime;
  final String description;

  MessageModel({
    this.messageId = '',
    required this.datetime,
    required this.description,
  });
}
