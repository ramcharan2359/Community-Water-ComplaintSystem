/// Status of a water complaint
enum ComplaintStatus {
  pending,
  inProgress,
  resolved,
}

extension ComplaintStatusExtension on ComplaintStatus {
  String get displayName {
    switch (this) {
      case ComplaintStatus.pending:
        return 'Pending';
      case ComplaintStatus.inProgress:
        return 'In Progress';
      case ComplaintStatus.resolved:
        return 'Resolved';
    }
  }
}

/// Standard categories of water issues
class ComplaintCategory {
  static const String noWaterSupply = 'No Water Supply';
  static const String waterLeakage = 'Water Leakage';
  static const String dirtyWater = 'Dirty or Contaminated Water';
  static const String lowPressure = 'Low Water Pressure';
  static const String brokenPipeline = 'Broken Water Pipeline';
  static const String other = 'Other';

  static const List<String> all = [
    noWaterSupply,
    waterLeakage,
    dirtyWater,
    lowPressure,
    brokenPipeline,
    other,
  ];
}

/// Model representing a resident's water issue complaint
class Complaint {
  final String id;
  final String title;
  final String category;
  final String community;
  final String locationDetails;
  final String description;
  final DateTime submissionDate;
  final ComplaintStatus status;
  final String? imagePath;
  final String userId;
  final String residentName;
  final String residentPhone;
  final String? adminRemarks;
  final DateTime? inProgressDate;
  final DateTime? resolvedDate;

  const Complaint({
    required this.id,
    required this.title,
    required this.category,
    required this.community,
    required this.locationDetails,
    required this.description,
    required this.submissionDate,
    this.status = ComplaintStatus.pending,
    this.imagePath,
    required this.userId,
    required this.residentName,
    required this.residentPhone,
    this.adminRemarks,
    this.inProgressDate,
    this.resolvedDate,
  });

  /// Create a copy of the complaint with updated fields (e.g. status changes by admin)
  Complaint copyWith({
    String? id,
    String? title,
    String? category,
    String? community,
    String? locationDetails,
    String? description,
    DateTime? submissionDate,
    ComplaintStatus? status,
    String? imagePath,
    String? userId,
    String? residentName,
    String? residentPhone,
    String? adminRemarks,
    DateTime? inProgressDate,
    DateTime? resolvedDate,
  }) {
    return Complaint(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      community: community ?? this.community,
      locationDetails: locationDetails ?? this.locationDetails,
      description: description ?? this.description,
      submissionDate: submissionDate ?? this.submissionDate,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      userId: userId ?? this.userId,
      residentName: residentName ?? this.residentName,
      residentPhone: residentPhone ?? this.residentPhone,
      adminRemarks: adminRemarks ?? this.adminRemarks,
      inProgressDate: inProgressDate ?? this.inProgressDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
    );
  }
}
