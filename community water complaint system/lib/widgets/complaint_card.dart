import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/complaint.dart';
import '../theme/app_theme.dart';
import 'status_chip.dart';

/// Card widget to display a water complaint in list views
class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onTap;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case ComplaintCategory.noWaterSupply:
        return Icons.water_drop_outlined;
      case ComplaintCategory.waterLeakage:
        return Icons.opacity_rounded;
      case ComplaintCategory.dirtyWater:
        return Icons.science_outlined;
      case ComplaintCategory.lowPressure:
        return Icons.speed_rounded;
      case ComplaintCategory.brokenPipeline:
        return Icons.plumbing_rounded;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case ComplaintCategory.noWaterSupply:
        return const Color(0xFFE53935);
      case ComplaintCategory.waterLeakage:
        return const Color(0xFF0288D1);
      case ComplaintCategory.dirtyWater:
        return const Color(0xFF8D6E63);
      case ComplaintCategory.lowPressure:
        return const Color(0xFFFB8C00);
      case ComplaintCategory.brokenPipeline:
        return const Color(0xFF7B1FA2);
      default:
        return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final categoryColor = _getCategoryColor(complaint.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID and Status Chip
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
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  StatusChip(status: complaint.status, isCompact: true),
                ],
              ),
              const SizedBox(height: 10),

              // Category row with icon tag
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(complaint.category),
                    size: 16,
                    color: categoryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    complaint.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Title
              Text(
                complaint.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              // Location and Date Footer
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${complaint.community} (${complaint.locationDetails})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(complaint.submissionDate),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: AppTheme.primaryBlue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
