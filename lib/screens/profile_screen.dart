import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/booking_service.dart';
import '../widgets/bottom_nav.dart';

import 'auth_choice_screen.dart';
import 'coming_soon_screen.dart';
import 'home_screen.dart';
import 'my_bookings_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF050606),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 17, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Expanded(
              child: user == null
                  ? _signedOutView(context)
                  : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Failed to load profile.\n\n${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }

                        final data = snapshot.data?.data() ?? {};

                        final name =
                            (data['name'] ?? 'Cinema Member').toString();

                        final phone = (data['phoneNumber'] ??
                                user.phoneNumber ??
                                'No phone number')
                            .toString();

                        return ListView(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            5,
                            16,
                            25,
                          ),
                          children: [
                            _profileHeader(name),
                            const SizedBox(height: 17),
                            _infoCard(
                              name,
                              phone,
                            ),
                            const SizedBox(height: 12),
                            _ticketsCard(context),
                            const SizedBox(height: 22),
                            OutlinedButton.icon(
                              onPressed: () => _signOut(context),
                              icon: const Icon(
                                Icons.logout_rounded,
                                size: 17,
                              ),
                              label: const Text('Sign Out'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFE98E8E),
                                side: BorderSide(
                                  color:
                                      const Color(0xFFE98E8E).withOpacity(.25),
                                ),
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            CinemaBottomNav(
              currentIndex: 3,
              onChanged: (index) {
                _navigate(context, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _profileHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111313),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFFF3F0D6),
            child: Icon(
              Icons.person_rounded,
              color: Colors.black,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Cinema member',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _infoCard(
    String name,
    String phone,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF111313),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Column(
        children: [
          _row(
            Icons.person_outline_rounded,
            'Name',
            name,
          ),
          const Divider(
            color: Colors.white10,
            height: 25,
          ),
          _row(
            Icons.phone_outlined,
            'Phone number',
            phone,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TICKETS CARD
  // ============================================================

  Widget _ticketsCard(BuildContext context) {
    return StreamBuilder(
      stream: BookingService().getMyBookings(),
      builder: (context, snapshot) {
        int ticketCount = 0;

        if (snapshot.hasData) {
          final bookings = snapshot.data;

          if (bookings is List) {
            ticketCount = bookings!.length;
          }
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyBookingsScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFF111313),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0D6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.confirmation_num_rounded,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tickets Bought',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$ticketCount',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white30,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ROW
  // ============================================================

  Widget _row(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white38,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SIGNED OUT
  // ============================================================

  Widget _signedOutView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_outline_rounded,
              size: 60,
              color: Colors.white24,
            ),
            const SizedBox(height: 15),
            const Text(
              'Not signed in',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to view your profile and tickets.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AuthChoiceScreen(),
                  ),
                );
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF171918),
        title: const Text('Sign out?'),
        content: const Text(
          'You will return to the authentication screen.',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              await FirebaseAuth.instance.signOut();

              if (!context.mounted) {
                return;
              }

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const AuthChoiceScreen(),
                ),
                (_) => false,
              );
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Color(0xFFE98E8E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTTOM NAVIGATION
// ============================================================

void _navigate(
  BuildContext context,
  int index,
) {
  if (index == 3) {
    return;
  }

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

    case 2:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        ),
      );
      break;
  }
}
