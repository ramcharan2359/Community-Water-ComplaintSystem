import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import 'complaint_details_screen.dart';

/// Screen listing system and grievance update notifications
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<MockDataService>(context);
    final notifications = dataService.notifications;
    final unreadCount = dataService.unreadNotificationsCount;
    final dateFormat = DateFormat('dd MMM, hh:mm a');

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                dataService.markAllNotificationsAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read.'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.done_all_rounded, color: Colors.white, size: 18),
              label: const Text(
                'Mark Read',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications available',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = notifications[index];

                IconData icon;
                Color iconColor;
                Color iconBg;

                if (notif.type == 'maintenance') {
                  icon = Icons.warning_amber_rounded;
                  iconColor = AppTheme.statusPending;
                  iconBg = AppTheme.statusPendingBg;
                } else if (notif.type == 'announcement') {
                  icon = Icons.campaign_rounded;
                  iconColor = AppTheme.primaryBlue;
                  iconBg = AppTheme.primaryLight;
                } else {
                  icon = Icons.water_drop_rounded;
                  iconColor = AppTheme.secondaryAqua;
                  iconBg = const Color(0xFFE0F7FA);
                }

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      dataService.markNotificationAsRead(notif.id);
                      if (notif.relatedComplaintId != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ComplaintDetailsScreen(
                              complaintId: notif.relatedComplaintId!,
                            ),
                          ),
                        );
                      }
                    },
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: notif.isRead ? Colors.white : const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: notif.isRead ? AppTheme.cardBorder : AppTheme.primaryBlue.withAlpha(80),
                          width: notif.isRead ? 1 : 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: iconColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ),
                                    if (!notif.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryBlue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.message,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF475569),
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateFormat.format(notif.timestamp),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    if (notif.relatedComplaintId != null)
                                      const Row(
                                        children: [
                                          Text(
                                            'View Details',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryBlue,
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 14,
                                            color: AppTheme.primaryBlue,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
