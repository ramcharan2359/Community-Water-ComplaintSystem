import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../theme/app_theme.dart';

/// Reusable status chip with color coding for complaint states
class StatusChip extends StatelessWidget {
  final ComplaintStatus status;
  final bool isCompact;

  const StatusChip({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (status) {
      case ComplaintStatus.pending:
        bg = AppTheme.statusPendingBg;
        fg = AppTheme.statusPending;
        icon = Icons.access_time_rounded;
        label = 'Pending';
        break;
      case ComplaintStatus.inProgress:
        bg = AppTheme.statusInProgressBg;
        fg = AppTheme.statusInProgress;
        icon = Icons.engineering_rounded;
        label = 'In Progress';
        break;
      case ComplaintStatus.resolved:
        bg = AppTheme.statusResolvedBg;
        fg = AppTheme.statusResolved;
        icon = Icons.check_circle_rounded;
        label = 'Resolved';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
