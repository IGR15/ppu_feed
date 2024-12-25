import 'package:flutter/material.dart';
import 'package:ppu_feed/controller/section_controller.dart';
import 'package:ppu_feed/model/section.dart';

class SectionWidget extends StatefulWidget {
  const SectionWidget(
      {super.key,
      required this.section,
      required this.courseId,
      required this.isSubscribed,
      required this.subId});
  final Section section;
  final int courseId;
  final int subId;
  final bool isSubscribed;
  @override
  State<SectionWidget> createState() => SsectionWidgetState();
}

class SsectionWidgetState extends State<SectionWidget> {
  SectionController controller = SectionController();
  bool isSubscribed = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSubscribed = widget.isSubscribed;
  }
  @override
  Widget build(BuildContext context) {
    Section sections = widget.section;
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal[300],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
            title: Text(sections.name),
            subtitle: Text("Lecturer : ${sections.lecturer}"),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        print(isSubscribed);
                        print(55);
                        controller.subscribeToSection(
                            widget.courseId, sections.id);
                        print(55);

                        setState(() {
                          isSubscribed = true;
                        });
                      },
                      icon: Icon(
                        isSubscribed ? Icons.check : Icons.add,
                        color: isSubscribed ? Colors.green[800] : Colors.white,
                      )),
                  IconButton(
                    onPressed: () async {
                      if (isSubscribed) {
                        print(1);
                        try {
                          await controller.deleteSubscription(
                              widget.courseId, sections.id, widget.subId);
                          setState(() {
                            isSubscribed = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Unsubscribed successfully!")),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }
                      }
                    },
                    icon: Icon(
                      Icons.remove,
                      color: isSubscribed ? Colors.red : Colors.white,
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
