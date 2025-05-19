import 'package:flutter/material.dart';
import 'package:irawan_driweather/screens/notification_screen.dart';

class NotificationPopupStateful extends StatefulWidget {
  const NotificationPopupStateful({Key? key}) : super(key: key);

  @override
  State<NotificationPopupStateful> createState() =>
      _NotificationPopupStatefulState();
}

class _NotificationPopupStatefulState extends State<NotificationPopupStateful> {
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() {
    final now = DateTime.now();
    _notifications = [
      NotificationItem(
        type: NotificationType.sun,
        title:
            'A sunny day in your location, consider wearing your UV protection',
        timestamp: now.subtract(const Duration(minutes: 10)),
      ),
      NotificationItem(
        type: NotificationType.sun,
        title:
            'A cloudy day will occur all day long, don\'t worry about the heat of the sun',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      NotificationItem(
        type: NotificationType.rain,
        title:
            'Potential for rain today is 64%, don\'t forget to bring your umbrella',
        timestamp: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  void _toggleExpanded(int index) {
    setState(() {
      final List<NotificationItem> updatedNotifications =
          List.from(_notifications);
      final currentItem = updatedNotifications[index];
      updatedNotifications[index] = NotificationItem(
        type: currentItem.type,
        title: currentItem.title,
        timestamp: currentItem.timestamp,
        expanded: !currentItem.expanded,
      );
      _notifications = updatedNotifications;
    });
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.sun:
        return Icons.wb_sunny_outlined;
      case NotificationType.rain:
        return Icons.water_drop_outlined;
      case NotificationType.temperature:
        return Icons.thermostat_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your notification',
                    style: TextStyle(
                      color: Color(0xFF464A63),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                'Now',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shrinkWrap: true,
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final timeAgo = index == 0
                      ? '10 minutes ago'
                      : index == 1
                          ? '1 day ago'
                          : '2 days ago';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == 1)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0, top: 16, bottom: 8),
                          child: Text(
                            'Earlier',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _toggleExpanded(index),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? Colors.amber.shade100
                                        : index == 1
                                            ? Colors.grey.shade100
                                            : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getIconForType(notification.type),
                                    color: index == 0
                                        ? Colors.amber.shade800
                                        : index == 1
                                            ? Colors.grey.shade600
                                            : Colors.blue.shade800,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        timeAgo,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification.title,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines:
                                            notification.expanded ? null : 2,
                                        overflow: notification.expanded
                                            ? null
                                            : TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  notification.expanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class NotificationManager {
  static void showNotificationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: NotificationPopupStateful(),
        );
      },
    );
  }
}
