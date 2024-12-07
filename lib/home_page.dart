import 'package:flutter/material.dart';
import 'package:ppu_feed/course_feed.dart';
import 'package:ppu_feed/feeds_screen.dart';
import 'package:ppu_feed/modules/subscripions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Subscripions>> fetchSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Authentication token not found. Please log in.");
    }

    var res = await http.get(
      Uri.parse("http://feeds.ppu.edu/api/v1/subscriptions"),
      headers: {'Authorization': token},
    );

    if (res.statusCode == 200) {
      var jsonArr = jsonDecode(res.body)['subscriptions'] as List;
      return jsonArr.map((e) => Subscripions.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch subscriptions: ${res.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌟 My Subscriptions 🌟"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Subscripions>>(
        future: fetchSubscriptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final subscriptions = snapshot.data!;
            if (subscriptions.isEmpty) {
              return const Center(child: Text("No active subscriptions."));
            }
            return ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];
                return ListTile(
                  title: Text(subscription.course),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Section: ${subscription.section}"),
                      Text("Lecturer: ${subscription.lecturer}"),
                      Text(
                        "Subscribed on: ${subscription.subscription_date.toLocal().toString().split(' ')[0]}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseFeedScreen(courseId: subscription.id),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text("No data available."));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FeedsScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
        tooltip: "Explore Courses",
      ),
    );
  }
}
