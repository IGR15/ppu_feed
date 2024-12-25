import 'package:flutter/material.dart';
import 'package:ppu_feed/controller/subscriptions_controller.dart';
import 'package:ppu_feed/views/posts_screen.dart';
import 'package:ppu_feed/views/courses_screen.dart';
import 'package:ppu_feed/model/subscripions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SubscriptionsController controller = SubscriptionsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌟 My Subscriptions 🌟"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Subscripions>>(
        future: controller.fetchSubscriptions(),
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
                        builder: (context) => PostsScreen(
                            courseId: subscription.id,
                            sectionId: subscription.sectionId),
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
        child: const Icon(Icons.search),
        backgroundColor: Colors.teal,
        tooltip: "Explore Courses",
      ),
    );
  }
}
