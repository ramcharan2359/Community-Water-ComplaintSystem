import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/complaint.dart';
import '../theme/app_theme.dart';

/// Visual 3-step timeline displaying: Submitted → In Progress → Resolved
class StatusTimeline extends StatelessWidget {
  final Complaint complaint;

  const StatusTimeline({
    super.key,
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    // Determine state of each step
    // Step 1: Always completed
    final bool step1Completed = true;

    // Step 2: In progress or completed
    final bool step2Active = complaint.status == ComplaintStatus.inProgress;
    final bool step2Completed =
        complaint.status == ComplaintStatus.inProgress ||
        complaint.status == ComplaintStatus.resolved;

    // Step 3: Resolved
    final bool step3Active = complaint.status == ComplaintStatus.resolved;
    final bool step3Completed = complaint.status == ComplaintStatus.resolved;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resolution Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // Step 1: Submitted
          _buildTimelineStep(
            context: context,
            stepNumber: 1,
            title: 'Complaint Submitted',
            subtitle: 'Registered by resident and logged into civic portal',
            timestamp: dateFormat.format(complaint.submissionDate),
            isCompleted: step1Completed,
            isActive: complaint.status == ComplaintStatus.pending,
            isLast: false,
          ),

          // Step 2: In Progress
          _buildTimelineStep(
            context: context,
            stepNumber: 2,
            title: 'Inspection & Repair In Progress',
            subtitle: complaint.adminRemarks != null && complaint.adminRemarks!.isNotEmpty
                ? complaint.adminRemarks!
                : 'Assigned to municipal field maintenance unit',
            timestamp: complaint.inProgressDate != null
                ? dateFormat.format(complaint.inProgressDate!)
                : (step2Active ? 'Currently active' : 'Awaiting assignment'),
            isCompleted: step2Completed,
            isActive: step2Active,
            isLast: false,
          ),

          // Step 3: Resolved
          _buildTimelineStep(
            context: context,
            stepNumber: 3,
            title: 'Issue Resolved & Closed',
            subtitle: complaint.resolvedDate != null
                ? 'Field inspection confirmed water flow restored'
                : 'Pending final site verification',
            timestamp: complaint.resolvedDate != null
                ? dateFormat.format(complaint.resolvedDate!)
                : (step3Active ? 'Verification complete' : 'Pending resolution'),
            isCompleted: step3Completed,
            isActive: step3Active,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required BuildContext context,
    required int stepNumber,
    required String title,
    required String subtitle,
    required String timestamp,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    Color indicatorColor;
    IconData icon;

    if (isCompleted && !isActive) {
      indicatorColor = AppTheme.statusResolved;
      icon = Icons.check_circle_rounded;
    } else if (isActive) {
      indicatorColor = AppTheme.statusInProgress;
      icon = Icons.radio_button_checked_rounded;
    } else {
      indicatorColor = const Color(0xFFCBD5E1);
      icon = Icons.radio_button_unchecked_rounded;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step circle and connector line column
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppTheme.statusInProgressBg
                      : (isCompleted ? AppTheme.statusResolvedBg : const Color(0xFFF1F5F9)),
                  border: Border.all(
                    color: indicatorColor,
                    width: isActive ? 2.5 : 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: indicatorColor,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted ? AppTheme.statusResolved.withAlpha(120) : const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Step Details Column
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isActive || isCompleted ? AppTheme.textDark : AppTheme.textMuted,
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.statusInProgressBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'CURRENT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.statusInProgress,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        timestamp,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
