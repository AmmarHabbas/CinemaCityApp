import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../services/booking_service.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();

    return Scaffold(
      backgroundColor: const Color(0xFF050606),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050606),
        elevation: 0,
        title: const Text(
          'My Tickets',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: StreamBuilder<List<Booking>>(
        stream: bookingService.getMyBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load your bookings.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return _emptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return _bookingCard(
                context,
                bookings[index],
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF111313),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(
                Icons.confirmation_num_outlined,
                size: 34,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Tickets Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your purchased movie tickets will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOOKING CARD
  // ============================================================

  Widget _bookingCard(
    BuildContext context,
    Booking booking,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        _showBookingDetails(
          context,
          booking,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFF111313),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------
            // MOVIE + STATUS
            // ----------------------------------------------------

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F0D6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.movie_outlined,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.movieTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        booking.hallName,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _statusBadge(booking.status),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(
              color: Colors.white10,
              height: 1,
            ),

            const SizedBox(height: 16),

            // ----------------------------------------------------
            // DATE / TIME
            // ----------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    Icons.calendar_today_outlined,
                    'Date',
                    _formatDate(booking.date),
                  ),
                ),
                Expanded(
                  child: _infoItem(
                    Icons.access_time_outlined,
                    'Time',
                    booking.startTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // ----------------------------------------------------
            // SEATS / TOTAL
            // ----------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    Icons.event_seat_outlined,
                    'Seats',
                    booking.seats.join(', '),
                  ),
                ),
                Expanded(
                  child: _infoItem(
                    Icons.payments_outlined,
                    'Total',
                    '\$${booking.total.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            // ----------------------------------------------------
            // BOOKING CODE
            // ----------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.35),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_num_outlined,
                    size: 17,
                    color: Colors.white38,
                  ),
                  const SizedBox(width: 9),
                  const Text(
                    'Booking Code',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white38,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    booking.bookingCode,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View ticket',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white38,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 17,
                    color: Colors.white30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: Colors.white38,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _statusBadge(String status) {
    final normalized = status.toLowerCase();

    String text;

    if (normalized == 'confirmed') {
      text = 'Confirmed';
    } else if (normalized == 'cancelled') {
      text = 'Cancelled';
    } else if (normalized == 'pending') {
      text = 'Pending';
    } else {
      text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: normalized == 'confirmed'
            ? const Color(0xFFF3F0D6).withOpacity(.12)
            : Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: normalized == 'confirmed'
              ? const Color(0xFFF3F0D6)
              : Colors.white54,
        ),
      ),
    );
  }

  // ============================================================
  // BOOKING DETAILS
  // ============================================================

  void _showBookingDetails(
    BuildContext context,
    Booking booking,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111313),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.movieTitle,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _statusBadge(booking.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    booking.hallName,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _detailRow(
                    Icons.calendar_today_outlined,
                    'Date',
                    _formatDate(booking.date),
                  ),
                  _detailRow(
                    Icons.access_time_outlined,
                    'Start Time',
                    booking.startTime,
                  ),
                  _detailRow(
                    Icons.theaters_outlined,
                    'Hall',
                    booking.hallName,
                  ),
                  _detailRow(
                    Icons.event_seat_outlined,
                    'Seats',
                    booking.seats.join(', '),
                  ),
                  _detailRow(
                    Icons.confirmation_num_outlined,
                    'Seat Count',
                    booking.seatCount.toString(),
                  ),
                  _detailRow(
                    Icons.payments_outlined,
                    'Price Per Seat',
                    '\$${booking.pricePerSeat.toStringAsFixed(2)}',
                  ),
                  _detailRow(
                    Icons.account_balance_wallet_outlined,
                    'Total',
                    '\$${booking.total.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.35),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: Colors.white10,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BOOKING CODE',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          booking.bookingCode,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F0D6),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
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
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: Colors.white38,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white38,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} '
        '${date.year}';
  }
}
