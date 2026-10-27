import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/complaint.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/complaint_card.dart';
import '../widgets/announcement_card.dart';
import '../widgets/status_chip.dart';
import 'complaint_details_screen.dart';
import 'login_screen.dart';
import 'resident_home_screen.dart';

/// Comprehensive administration panel for municipal water board operators
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  ComplaintStatus? _selectedStatusFilter;
  String? _selectedCategoryFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddAnnouncementDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final areasCtrl = TextEditingController(text: 'All Sectors');
    String selectedCategory = 'Scheduled Maintenance';
    bool isUrgent = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.campaign_rounded, color: AppTheme.primaryBlue),
                  SizedBox(width: 8),
                  Text('Publish Announcement'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Announcement Title *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Feeder Line Repairs',
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 12),

                      const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: const [
                          DropdownMenuItem(value: 'Scheduled Maintenance', child: Text('Scheduled Maintenance')),
                          DropdownMenuItem(value: 'Supply Interruption', child: Text('Supply Interruption')),
                          DropdownMenuItem(value: 'Quality Advisory', child: Text('Quality Advisory')),
                          DropdownMenuItem(value: 'Infrastructure Notice', child: Text('Infrastructure Notice')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedCategory = val);
                        },
                      ),
                      const SizedBox(height: 12),

                      const Text('Affected Areas *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: areasCtrl,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Sector 2, 3, & Sunrise Enclave',
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Specify areas' : null,
                      ),
                      const SizedBox(height: 12),

                      const Text('Notice Details *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Provide timing and supply advice...',
                          contentPadding: EdgeInsets.all(10),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 10),

                      CheckboxListTile(
                        value: isUrgent,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Mark as Urgent Advisory', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: const Text('Highlights notification in red for residents', style: TextStyle(fontSize: 11)),
                        onChanged: (val) {
                          setDialogState(() => isUrgent = val ?? false);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final service = Provider.of<MockDataService>(context, listen: false);
                      service.addAnnouncement(
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        category: selectedCategory,
                        affectedAreas: areasCtrl.text.trim(),
                        isUrgent: isUrgent,
                      );
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Announcement broadcasted to residents!'),
                          backgroundColor: AppTheme.statusResolved,
                        ),
                      );
                    }
                  },
                  child: const Text('Broadcast Now'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQuickStatusDialog(BuildContext context, Complaint complaint) {
    ComplaintStatus newStatus = complaint.status;
    final remarksCtrl = TextEditingController(text: complaint.adminRemarks ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Update ${complaint.id}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complaint.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    const Text('Change Status:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(height: 6),
                    ...ComplaintStatus.values.map((s) {
                      return RadioListTile<ComplaintStatus>(
                        value: s,
                        groupValue: newStatus,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            StatusChip(status: s, isCompact: true),
                          ],
                        ),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => newStatus = val);
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                    const Text('Engineer Remarks / Action Taken:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: remarksCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Repair crew sealed 4-inch mainline leak.',
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final service = Provider.of<MockDataService>(context, listen: false);
                    service.updateComplaintStatus(
                      complaintId: complaint.id,
                      newStatus: newStatus,
                      remarks: remarksCtrl.text.trim(),
                    );
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status of ${complaint.id} updated!'),
                        backgroundColor: AppTheme.statusResolved,
                      ),
                    );
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<MockDataService>(context);
    final allComplaints = dataService.complaints;
    final announcements = dataService.announcements;

    // Filter by query, status, category
    final query = _searchController.text.trim().toLowerCase();
    final filtered = allComplaints.where((c) {
      final matchesQuery = query.isEmpty ||
          c.title.toLowerCase().contains(query) ||
          c.id.toLowerCase().contains(query) ||
          c.community.toLowerCase().contains(query) ||
          c.residentName.toLowerCase().contains(query);

      final matchesStatus = _selectedStatusFilter == null || c.status == _selectedStatusFilter;
      final matchesCategory = _selectedCategoryFilter == null || c.category == _selectedCategoryFilter;

      return matchesQuery && matchesStatus && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Portal'),
            Text(
              'Municipal Water Authority Dashboard',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Switch to resident view button (for presentations)
          IconButton(
            icon: const Icon(Icons.person_pin_rounded),
            tooltip: 'View as Resident (Demo)',
            onPressed: () {
              dataService.switchRole(UserRole.resident);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ResidentHomeScreen()),
              );
            },
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () {
              dataService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAnnouncementDialog(context),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('New Announcement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Info Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE8EAF6),
                    child: Icon(Icons.shield_outlined, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Central Control Desk',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        Text(
                          'Review resident complaints & dispatch engineering field teams',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.statusResolvedBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ONLINE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.statusResolved),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Grid: 4 Cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Grievances',
                    count: dataService.totalComplaints,
                    icon: Icons.list_alt_rounded,
                    color: AppTheme.primaryBlue,
                    backgroundColor: AppTheme.primaryLight,
                    onTap: () => setState(() => _selectedStatusFilter = null),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Pending Action',
                    count: dataService.pendingComplaints,
                    icon: Icons.access_time_rounded,
                    color: AppTheme.statusPending,
                    backgroundColor: AppTheme.statusPendingBg,
                    onTap: () => setState(() => _selectedStatusFilter = ComplaintStatus.pending),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'In Progress',
                    count: dataService.inProgressComplaints,
                    icon: Icons.engineering_rounded,
                    color: AppTheme.statusInProgress,
                    backgroundColor: AppTheme.statusInProgressBg,
                    onTap: () => setState(() => _selectedStatusFilter = ComplaintStatus.inProgress),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Resolved',
                    count: dataService.resolvedComplaints,
                    icon: Icons.check_circle_outline_rounded,
                    color: AppTheme.statusResolved,
                    backgroundColor: AppTheme.statusResolvedBg,
                    onTap: () => setState(() => _selectedStatusFilter = ComplaintStatus.resolved),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Announcements management summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.campaign_outlined, color: AppTheme.primaryBlue, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Active Supply Bulletins',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Post', style: TextStyle(fontSize: 13)),
                  onPressed: () => _showAddAnnouncementDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (announcements.isEmpty)
              const Text('No active announcements.', style: TextStyle(color: AppTheme.textMuted))
            else
              ...announcements.take(2).map((a) => AnnouncementCard(announcement: a)),
            const SizedBox(height: 20),

            // Complaint Management Header & Filter controls
            const Row(
              children: [
                Icon(Icons.manage_accounts_outlined, color: AppTheme.primaryBlue, size: 20),
                SizedBox(width: 6),
                Text(
                  'Community Grievances Roster',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Search bar
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by ID, resident name, or area...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),

            // Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildAdminFilterChip('All (${allComplaints.length})', _selectedStatusFilter == null, () {
                    setState(() => _selectedStatusFilter = null);
                  }, AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  _buildAdminFilterChip('Pending (${dataService.pendingComplaints})', _selectedStatusFilter == ComplaintStatus.pending, () {
                    setState(() => _selectedStatusFilter = ComplaintStatus.pending);
                  }, AppTheme.statusPending),
                  const SizedBox(width: 8),
                  _buildAdminFilterChip('In Progress (${dataService.inProgressComplaints})', _selectedStatusFilter == ComplaintStatus.inProgress, () {
                    setState(() => _selectedStatusFilter = ComplaintStatus.inProgress);
                  }, AppTheme.statusInProgress),
                  const SizedBox(width: 8),
                  _buildAdminFilterChip('Resolved (${dataService.resolvedComplaints})', _selectedStatusFilter == ComplaintStatus.resolved, () {
                    setState(() => _selectedStatusFilter = ComplaintStatus.resolved);
                  }, AppTheme.statusResolved),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Complaints List with quick status buttons
            if (filtered.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 40, color: AppTheme.textMuted),
                    SizedBox(height: 8),
                    Text('No complaints matching filter criteria', style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              )
            else
              ...filtered.map((complaint) {
                return Stack(
                  children: [
                    ComplaintCard(
                      complaint: complaint,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ComplaintDetailsScreen(complaintId: complaint.id),
                          ),
                        );
                      },
                    ),
                    // Quick Action button in top-right of card for admin convenience
                    Positioned(
                      top: 12,
                      right: 120,
                      child: InkWell(
                        onTap: () => _showQuickStatusDialog(context, complaint),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primaryBlue.withAlpha(60)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_note, size: 14, color: AppTheme.primaryBlue),
                              SizedBox(width: 2),
                              Text(
                                'Change',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            const SizedBox(height: 80), // Padding for FloatingActionButton
          ],
        ),
      ),
    );
  }

  Widget _buildAdminFilterChip(String label, bool isSelected, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : AppTheme.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}
