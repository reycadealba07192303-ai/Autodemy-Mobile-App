import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/app_data.dart';

class NotificationsScreen extends StatelessWidget {
  final String userRole; // 'STUDENT', 'TEACHER', 'ADMIN'
  
  const NotificationsScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    List<AppMessage> notifications;
    Color themeColor;
    
    if (userRole == 'TEACHER') {
      notifications = AppData.teacherNotifs;
      themeColor = AppTheme.primary;
    } else if (userRole == 'STUDENT') {
      notifications = AppData.studentNotifs;
      themeColor = Colors.orange;
    } else {
      // Admin notifications or system logs
      notifications = AppData.activeAnnouncements;
      themeColor = Colors.blueGrey;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return _buildNotificationCard(notif, themeColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppMessage notif, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active_rounded, color: accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notif.sender,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      _formatTime(notif.time),
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notif.body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.month}/${time.day}';
  }
}
