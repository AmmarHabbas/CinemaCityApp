import 'package:flutter/material.dart';

class CinemaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const CinemaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF171817).withOpacity(.96),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(.12)),
        boxShadow: const [BoxShadow(blurRadius: 25, spreadRadius: 2, color: Colors.black54)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(Icons.home_rounded, 'Home', 0),
          _item(Icons.local_movies_rounded, 'Movies', 1),
          _item(Icons.notifications_none_rounded, 'Alerts', 2),
          _item(Icons.person_outline_rounded, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, int index) {
    final selected = currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? Colors.white.withOpacity(.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(icon, size: 21, color: selected ? Colors.white : Colors.white38),
        ),
      ),
    );
  }
}
