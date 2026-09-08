import 'dart:async';

class MockNotification {
  final String title;
  final String body;
  final DateTime time;

  MockNotification({
    required this.title,
    required this.body,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final List<MockNotification> _notifications = [];
  final StreamController<MockNotification> _stream =
      StreamController<MockNotification>.broadcast();

  List<MockNotification> get notifications => List.unmodifiable(_notifications);
  Stream<MockNotification> get stream => _stream.stream;

  void add(MockNotification notification) {
    _notifications.insert(0, notification);
    _stream.add(notification);
  }

  void clear() => _notifications.clear();

  void dispose() => _stream.close();
}
