/// Model representing official community water supply announcements
class WaterAnnouncement {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime dateTime;
  final String affectedAreas;
  final bool isUrgent;

  const WaterAnnouncement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
    required this.affectedAreas,
    this.isUrgent = false,
  });
}
