import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/complaint_card.dart';
import '../widgets/announcement_card.dart';
import 'my_complaints_screen.dart';
import 'report_complaint_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'complaint_details_screen.dart';

/// Main navigation shell for Resident users containing bottom navigation bar
class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<MockDataService>(context);
    final unreadCount = dataService.unreadNotificationsCount;

    final List<Widget> pages = [
      _ResidentDashboardView(
        onNavigateToReport: () => _onTabTapped(2),
        onNavigateToMyComplaints: () => _onTabTapped(1),
      ),
      MyComplaintsScreen(
        onNavigateToReport: () => _onTabTapped(2),
      ),
      ReportComplaintScreen(
        onComplaintSubmitted: () => _onTabTapped(1),
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.water_drop_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text('AquaCare'),
          ],
        ),
        actions: [
          // Notifications Bell with Unread Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.statusError,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment_rounded),
            label: 'My Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            activeIcon: Icon(Icons.add_circle_rounded),
            label: 'Report Issue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// The inner dashboard view for the 'Home' tab
class _ResidentDashboardView extends StatelessWidget {
  final VoidCallback onNavigateToReport;
  final VoidCallback onNavigateToMyComplaints;

  const _ResidentDashboardView({
    required this.onNavigateToReport,
    required this.onNavigateToMyComplaints,
  });

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<MockDataService>(context);
    final user = dataService.currentUser;
    final userComplaints = dataService.userComplaints;
    final announcements = dataService.announcements;

    // Recent 3 complaints
    final recentComplaints = userComplaints.take(3).toList();

    return RefreshIndicator(
      onRefresh: () async {
        // Quick visual refresh feedback
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Greeting Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withAlpha(50),
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'R',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user.name} 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.community,
                              style: TextStyle(
                                color: Colors.white.withAlpha(220),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.water_drop_outlined, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Civic Water Helpline: 1800-419-AQUA (Toll Free)',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Statistics Row: Total, Pending, Resolved
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Lodged',
                    count: dataService.userTotalComplaints,
                    icon: Icons.assignment_rounded,
                    color: AppTheme.primaryBlue,
                    backgroundColor: AppTheme.primaryLight,
                    onTap: onNavigateToMyComplaints,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Pending',
                    count: dataService.userPendingComplaints,
                    icon: Icons.hourglass_top_rounded,
                    color: AppTheme.statusPending,
                    backgroundColor: AppTheme.statusPendingBg,
                    onTap: onNavigateToMyComplaints,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Resolved',
                    count: dataService.userResolvedComplaints,
                    icon: Icons.check_circle_rounded,
                    color: AppTheme.statusResolved,
                    backgroundColor: AppTheme.statusResolvedBg,
                    onTap: onNavigateToMyComplaints,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Quick Action Banner: Report Water Issue
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryBlue.withAlpha(60), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_alert_rounded, color: AppTheme.primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Facing a Water Problem?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Report leaks, muddy water, or pipeline breaks instantly.',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onNavigateToReport,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      backgroundColor: AppTheme.primaryBlue,
                    ),
                    child: const Text('Report', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Water Supply Announcements Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.campaign_outlined, size: 20, color: AppTheme.primaryBlue),
                    SizedBox(width: 6),
                    Text(
                      'Water Supply Announcements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${announcements.length} Updates',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (announcements.isEmpty)
              const Text('No recent supply advisories', style: TextStyle(color: AppTheme.textMuted))
            else
              ...announcements.take(2).map((announcement) {
                return AnnouncementCard(announcement: announcement);
              }),
            const SizedBox(height: 18),

            // Recent Complaints Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history_rounded, size: 20, color: AppTheme.primaryBlue),
                    SizedBox(width: 6),
                    Text(
                      'Recent Grievances',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onNavigateToMyComplaints,
                  child: const Text(
                    'View All',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            if (recentComplaints.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.statusResolved, size: 36),
                    SizedBox(height: 8),
                    Text(
                      'No active complaints reported by your account.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              )
            else
              ...recentComplaints.map((complaint) {
                return ComplaintCard(
                  complaint: complaint,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ComplaintDetailsScreen(complaintId: complaint.id),
                      ),
                    );
                  },
                );
              }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
