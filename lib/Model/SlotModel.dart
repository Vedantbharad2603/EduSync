import 'package:flutter/material.dart';

class SlotModel {
  int? id;
  String day;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String subject;
  String className;
  int slotNumber;

  SlotModel({
    this.id,
    required this.day,
    this.startTime,
    this.endTime,
    required this.subject,
    required this.className,
    required this.slotNumber,
  });

  // Convert SlotModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'startTime': startTime != null
          ? {'hour': startTime!.hour, 'minute': startTime!.minute}
          : null,
      'endTime': endTime != null
          ? {'hour': endTime!.hour, 'minute': endTime!.minute}
          : null,
      'subject': subject,
      'className': className,
      'slotNumber': slotNumber,
    };
  }

  // Create SlotModel from JSON
  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'],
      day: json['day'] ?? '',
      startTime: json['startTime'] != null
          ? TimeOfDay(
              hour: json['startTime']['hour'],
              minute: json['startTime']['minute'],
            )
          : null,
      endTime: json['endTime'] != null
          ? TimeOfDay(
              hour: json['endTime']['hour'],
              minute: json['endTime']['minute'],
            )
          : null,
      subject: json['subject'] ?? '',
      className: json['className'] ?? '',
      slotNumber: json['slotNumber'] ?? 0,
    );
  }
}
