import 'dart:async';
import 'package:cinema_ui_reference/screens/coming_soon_screen.dart';
import 'package:cinema_ui_reference/screens/home_screen.dart';
import 'package:cinema_ui_reference/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import '../notification_service.dart';
import '../widgets/bottom_nav.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    subscription = NotificationService.instance.stream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = NotificationService.instance.notifications;
    void _navigate(BuildContext context, int index) {
      if (index == 2) return;

      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
          break;

        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ComingSoonScreen(
                onNavChanged: (newIndex) {
                  _navigate(context, newIndex);
                },
              ),
            ),
          );
          break;

        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
            ),
          );
          break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050606),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 17, 20, 8),
              child: Row(
                children: [
                  const Text('Notifications',
                      style:
                          TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
                  const Spacer(),
                  if (items.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        NotificationService.instance.clear();
                        setState(() {});
                      },
                      child: const Text('Clear',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 11)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? _empty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _notification(items[i]),
                    ),
            ),
            CinemaBottomNav(
              currentIndex: 2,
              onChanged: (index) {
                _navigate(context, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.notifications_none_rounded,
                size: 60, color: Colors.white24),
            SizedBox(height: 18),
            Text('No notifications yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text(
              'When you buy a ticket, a mock booking notification will appear here instantly.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notification(MockNotification item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF111313),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0D6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.confirmation_num_rounded,
                color: Colors.black, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(item.body,
                    style: const TextStyle(
                        fontSize: 10, color: Colors.white60, height: 1.4)),
                const SizedBox(height: 7),
                Text(
                  _relativeTime(item.time),
                  style: const TextStyle(fontSize: 8, color: Colors.white30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 10) return 'Just now';
    if (diff.inMinutes < 1) return '${diff.inSeconds}s ago';
    return '${diff.inMinutes}m ago';
  }
}
