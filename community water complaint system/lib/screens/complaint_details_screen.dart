import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/complaint.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';
import '../widgets/status_timeline.dart';

/// Detailed view for an individual water grievance
class ComplaintDetailsScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintDetailsScreen({
    super.key,
    required this.complaintId,
  });

  void _showStatusUpdateDialog(BuildContext context, Complaint complaint) {
    ComplaintStatus newStatus = complaint.status;
    final remarksController = TextEditingController(text: complaint.adminRemarks ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Update Status: ${complaint.id}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select New Complaint Status:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...ComplaintStatus.values.map((status) {
                      return RadioListTile<ComplaintStatus>(
                        value: status,
                        groupValue: newStatus,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            StatusChip(status: status, isCompact: true),
                          ],
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => newStatus = val);
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 12),
                    const Text('Admin / Engineer Remarks:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: remarksController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Plumber dispatched to repair leak valve...',
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
                      remarks: remarksController.text.trim(),
                    );
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status of ${complaint.id} updated to ${newStatus.displayName}!'),
                        backgroundColor: AppTheme.statusResolved,
                      ),
                    );
                  },
                  child: const Text('Save Update'),
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
    final complaint = dataService.getComplaintById(complaintId);
    final currentUser = dataService.currentUser;
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy, hh:mm a');

    if (complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Details')),
        body: const Center(
          child: Text('Complaint not found or has been removed.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(complaint.id),
        actions: [
          // If user is Admin, show quick edit action in AppBar
          if (currentUser.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_note_rounded),
              tooltip: 'Update Status',
              onPressed: () => _showStatusUpdateDialog(context, complaint),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and ID Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            complaint.id,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        StatusChip(status: complaint.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      complaint.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.category_outlined, size: 14, color: AppTheme.primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          complaint.category,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Visual Status Timeline
            StatusTimeline(complaint: complaint),
            const SizedBox(height: 16),

            // Location & Date Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location & Time Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.apartment_rounded,
                      title: 'Community / Area',
                      value: complaint.community,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      icon: Icons.location_on_rounded,
                      title: 'Specific Location',
                      value: complaint.locationDetails,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      icon: Icons.access_time_rounded,
                      title: 'Reported Timestamp',
                      value: dateFormat.format(complaint.submissionDate),
                    ),
                    if (complaint.resolvedDate != null) ...[
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.verified_rounded,
                        title: 'Resolved Timestamp',
                        value: dateFormat.format(complaint.resolvedDate!),
                        valueColor: AppTheme.statusResolved,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Detailed Description Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Problem Description',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      complaint.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Attached Media Card (Simulated evidence)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attached Photo Evidence',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.photo_library_rounded,
                              color: AppTheme.primaryBlue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  complaint.imagePath ?? 'water_pipeline_defect_doc.jpg',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Photo uploaded with geotag • Verified local resident submission',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Resident Details (Visible for Municipal inspection / Demo)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resident Contact Information',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryLight,
                          child: Icon(Icons.person, color: AppTheme.primaryBlue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              complaint.residentName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              complaint.residentPhone,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Admin update action button (or demo trigger)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.published_with_changes_rounded),
                label: Text(
                  currentUser.isAdmin ? 'Update Complaint Status' : 'Admin Status Actions (Demo)',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentUser.isAdmin ? AppTheme.primaryBlue : const Color(0xFF475569),
                ),
                onPressed: () => _showStatusUpdateDialog(context, complaint),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryBlue),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppTheme.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
