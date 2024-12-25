class Subscripions {
  int id;
  int sectionId;
  String section;
  String course;
  String lecturer;
  DateTime subscription_date;
  Subscripions(
      {required this.id,
      required this.sectionId,
      required this.section,
      required this.course,
      required this.lecturer,
      required this.subscription_date});
  factory Subscripions.fromJson(dynamic json) {
    return Subscripions(
      id: json['id'],
      sectionId: json['section_id'],
      section: json['section'],
      course: json['course'],
      lecturer: json['lecturer'],
      subscription_date: DateTime.parse(json['subscription_date']),
    );
  }
}
