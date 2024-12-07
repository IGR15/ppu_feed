class Subscripions {
  int id;
  String section;
  String course;
  String lecturer;
  DateTime subscription_date;
  Subscripions({required this.id,required this.section,required this.course,required this.lecturer,required this.subscription_date});
  factory Subscripions.fromJson(dynamic json) {
    return Subscripions(
      id: int.parse( json['id']),
      section: json['section'],
      course: json['course'],
      lecturer: json['lecturer'],
      subscription_date: DateTime.parse(json['subscription_date']),
    );
  }
}
