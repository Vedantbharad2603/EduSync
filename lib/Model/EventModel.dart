// ignore_for_file: non_constant_identifier_names, file_names

class EventModel {
  final String event_description;
  final String event_date;
  final int shiftdatum_id;

  EventModel({
    required this.event_description,
    required this.event_date,
    required this.shiftdatum_id,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': event_description,
      'date': event_date,
      'shiftid': shiftdatum_id,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      event_description: json['event_description'],
      event_date: json['event_date'],
      shiftdatum_id: json['shiftdatum_id'],
    );
  }
}
