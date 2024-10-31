class HolidayModel {
  late int id;
  final String name;
  final String date;
  bool consider;

  HolidayModel({
    this.id = 0,
    required this.name,
    required this.date,
    this.consider = true, // Default value is true
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date,
      'consider': consider,
    };
  }
}
