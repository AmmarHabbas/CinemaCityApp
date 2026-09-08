import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../models/showtime.dart';
import '../models/hall.dart';

import '../services/hall_service.dart';
import '../services/seat_service.dart';
import '../services/booking_service.dart';
import '../services/customer_service.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Movie movie;
  final Showtime showtime;

  const SeatSelectionScreen({
    super.key,
    required this.movie,
    required this.showtime,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final HallService _hallService = HallService();
  final SeatService _seatService = SeatService();
  final BookingService _bookingService = BookingService();
  final CustomerService _customerService = CustomerService();

  Hall? _hall;

  final Set<String> _selectedSeats = {};

  bool _loadingHall = true;
  bool _booking = false;

  String? _error;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadHall();
  }

  // ============================================================
  // LOAD HALL
  // ============================================================

  Future<void> _loadHall() async {
    try {
      final hall = await _hallService.getHall(widget.showtime.hallId);

      if (!mounted) return;

      if (hall == null) {
        setState(() {
          _loadingHall = false;
          _error = 'Hall no longer exists.';
        });

        return;
      }

      setState(() {
        _hall = hall;
        _loadingHall = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingHall = false;
        _error = 'Failed to load hall.\n$e';
      });
    }
  }

  // ============================================================
  // TOGGLE SEAT
  // ============================================================

  void _toggleSeat(
    String seatId,
    Set<String> bookedSeats,
  ) {
    if (bookedSeats.contains(seatId)) {
      return;
    }

    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else {
        _selectedSeats.add(seatId);
      }
    });
  }

  // ============================================================
  // BOOK
  // ============================================================

  Future<void> _bookTickets() async {
    if (_selectedSeats.isEmpty) {
      _showMessage(
        'Please select at least one seat.',
      );

      return;
    }

    setState(() {
      _booking = true;
    });

    try {
      final customer = await _customerService.getCurrentCustomer();

      final booking = await _bookingService.createBooking(
        showtime: widget.showtime,
        seats: _selectedSeats.toList(),
        customerName: customer['name']!,
        customerPhone: customer['phone']!,
      );

      if (!mounted) return;

      await _showBookingSuccess(booking.bookingCode);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _booking = false;
        });
      }
    }
  }

  // ============================================================
  // SUCCESS
  // ============================================================

  Future<void> _showBookingSuccess(
    String bookingCode,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171918),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Booking Confirmed 🎟️',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 65,
                color: Color(0xFFF3F0D6),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your tickets have been booked successfully.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Booking Code',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                bookingCode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: Color(0xFFF3F0D6),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_loadingHall) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: StreamBuilder<Set<String>>(
                stream: _seatService.watchBookedSeats(
                  widget.showtime.id,
                ),
                builder: (context, snapshot) {
                  final bookedSeats = snapshot.data ?? <String>{};

                  // Remove seats that became booked while
                  // customer was selecting them.
                  _selectedSeats.removeWhere(
                    bookedSeats.contains,
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      10,
                      16,
                      20,
                    ),
                    child: Column(
                      children: [
                        _showInfo(),
                        const SizedBox(height: 18),
                        _screen(),
                        const SizedBox(height: 25),
                        _seatMap(bookedSeats),
                        const SizedBox(height: 18),
                        _legend(),
                        const SizedBox(height: 25),
                        _bookingSummary(),
                        const SizedBox(height: 18),
                        _buyButton(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        4,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _booking ? null : () => Navigator.pop(context),
            icon: const Icon(
              Icons.chevron_left_rounded,
            ),
          ),
          Expanded(
            child: Text(
              widget.movie.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ============================================================
  // SHOW INFO
  // ============================================================

  Widget _showInfo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _infoChip(
                Icons.calendar_today_outlined,
                _formatDate(widget.showtime.date),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoChip(
                Icons.access_time_outlined,
                _formatTime(
                  widget.showtime.startTime,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _infoChip(
                Icons.theaters_outlined,
                widget.showtime.hallName,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _infoChip(
                Icons.payments_outlined,
                '\$${widget.showtime.price.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111313),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white54,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCREEN
  // ============================================================

  Widget _screen() {
    return Column(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 19,
          color: Colors.white70,
        ),
        const SizedBox(height: 3),
        Text(
          _hall?.name ?? widget.showtime.hallName,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(80),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8D9188),
                Color(0xFF181B1A),
                Colors.black,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(.08),
                blurRadius: 20,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 150,
              height: 2,
              color: Colors.white24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'SCREEN',
          style: TextStyle(
            fontSize: 7,
            letterSpacing: 2,
            color: Colors.white30,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEAT MAP
  // ============================================================

  Widget _seatMap(
    Set<String> bookedSeats,
  ) {
    final seats = _hall?.seats ?? [];

    if (seats.isEmpty) {
      return const Text(
        'This hall has no seats configured.',
      );
    }

    final rows = <String, List<HallSeat>>{};

    for (final seat in seats) {
      rows
          .putIfAbsent(
            seat.row,
            () => [],
          )
          .add(seat);
    }

    final sortedRows = rows.keys.toList()..sort();

    return Column(
      children: sortedRows.map((row) {
        final rowSeats = rows[row]!;

        rowSeats.sort(
          (a, b) => a.number.compareTo(b.number),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: rowSeats.map((seat) {
                final booked = bookedSeats.contains(seat.id);

                final selected = _selectedSeats.contains(
                  seat.id,
                );

                return GestureDetector(
                  onTap: booked || _booking
                      ? null
                      : () => _toggleSeat(
                            seat.id,
                            bookedSeats,
                          ),
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 180,
                    ),
                    width: 35,
                    height: 32,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    decoration: BoxDecoration(
                      color: booked
                          ? const Color(0xFF1D201F)
                          : selected
                              ? const Color(
                                  0xFFF3F0D6,
                                )
                              : const Color(
                                  0xFF2D312F,
                                ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(7),
                        topRight: Radius.circular(7),
                        bottomLeft: Radius.circular(3),
                        bottomRight: Radius.circular(3),
                      ),
                      border: Border.all(
                        color: selected
                            ? const Color(
                                0xFFF3F0D6,
                              )
                            : Colors.white12,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.airline_seat_recline_normal_rounded,
                          size: 13,
                          color: selected
                              ? Colors.black
                              : booked
                                  ? Colors.white10
                                  : Colors.white38,
                        ),
                        Text(
                          seat.id,
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: selected ? Colors.black : Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // LEGEND
  // ============================================================

  Widget _legend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(
          const Color(0xFF2D312F),
          'Available',
        ),
        const SizedBox(width: 18),
        _legendItem(
          const Color(0xFFF3F0D6),
          'Selected',
        ),
        const SizedBox(width: 18),
        _legendItem(
          const Color(0xFF1D201F),
          'Sold',
        ),
      ],
    );
  }

  Widget _legendItem(
    Color color,
    String text,
  ) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _bookingSummary() {
    final seats = _selectedSeats.toList()..sort();

    final total = seats.length * widget.showtime.price;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF111313),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Seats',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            seats.isEmpty ? 'No seats selected' : seats.join(', '),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFF3F0D6),
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUY BUTTON
  // ============================================================

  Widget _buyButton() {
    final total = _selectedSeats.length * widget.showtime.price;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0D6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: _booking ? null : _bookTickets,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: _booking
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Buy Tickets',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
            Container(
              height: 46,
              margin: const EdgeInsets.only(right: 5),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Center(
                child: Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE
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

    return '${date.day} ${months[date.month - 1]}';
  }

  // ============================================================
  // TIME
  // ============================================================

  String _formatTime(String time) {
    final parts = time.split(':');

    if (parts.length != 2) {
      return time;
    }

    final hour = int.tryParse(parts[0]) ?? 0;

    final minute = int.tryParse(parts[1]) ?? 0;

    final period = hour >= 12 ? 'PM' : 'AM';

    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}
