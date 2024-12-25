import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ppu_feed/controller/section_controller.dart';
import 'package:ppu_feed/model/section.dart';
import 'package:ppu_feed/model/subscripions.dart';
import 'package:ppu_feed/views/widget/section_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CourseFeedScreen extends StatefulWidget {
  final int courseId;
  const CourseFeedScreen({super.key, required this.courseId});

  @override
  _CourseFeedScreenState createState() => _CourseFeedScreenState();
}

class _CourseFeedScreenState extends State<CourseFeedScreen> {
  List<Subscripions> subarry = [];
  List<Section> section = [];
  List<int> _subscribedSections = [];

  bool isLoading = false;
  SectionController controller = SectionController();

  @override
  void initState() {
    super.initState();
    isLoading = true;

    getsubscribedSections();
  }

  void getsubscribedSections() async {
    subarry = await controller.fetchSubscribedSections();
    section = await controller.fetchSections(widget.courseId);
    print(section);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Feed"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Expanded(
              child: ListView.builder(
                itemCount: section.length,
                itemBuilder: (context, index) {
                  print(index);
                  Section sections = section[index];
                  int subId = 0;
                  bool isSubscribed = false;

                  subarry.forEach(
                    (element) {
                      _subscribedSections.add(element.id);
                      if (element.sectionId == sections.id) {
                        subId = element.id;
                        isSubscribed = true;
                      }
                    },
                  );


                  return SectionWidget(
                      section: sections,
                      courseId: widget.courseId,
                      isSubscribed: isSubscribed,
                      subId: subId);
                },
              ),
            ),
    );
  }
}
