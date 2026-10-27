import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/complaint.dart';
import '../models/announcement.dart';
import '../models/notification_model.dart';
import '../data/dummy_data.dart';

/// In-memory state manager for the AquaCare application.
/// Manages complaints, user sessions, announcements, and notifications without requiring a backend.
class MockDataService extends ChangeNotifier {
  // Singleton pattern for easy global access and Provider compatibility
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  static MockDataService get instance => _instance;

  MockDataService._internal() {
    _initData();
  }

  // --- In-Memory State Variables ---
  AppUser? _currentUser;
  final List<Complaint> _complaints = [];
  final List<WaterAnnouncement> _announcements = [];
  final List<AppNotification> _notifications = [];

  void _initData() {
    _currentUser = DummyData.defaultResident;
    _complaints.clear();
    _complaints.addAll(DummyData.initialComplaints);
    _announcements.clear();
    _announcements.addAll(DummyData.initialAnnouncements);
    _notifications.clear();
    _notifications.addAll(DummyData.initialNotifications);
  }

  // --- Getters ---
  AppUser get currentUser => _currentUser ?? DummyData.defaultResident;
  bool get isLoggedIn => _currentUser != null;

  List<Complaint> get complaints => List.unmodifiable(_complaints);

  /// Returns complaints relevant to the currently logged in user
  List<Complaint> get userComplaints {
    if (_currentUser == null) return [];
    if (_currentUser!.isAdmin) return List.unmodifiable(_complaints);
    return List.unmodifiable(
      _complaints.where((c) => c.userId == _currentUser!.id).toList(),
    );
  }

  List<WaterAnnouncement> get announcements => List.unmodifiable(_announcements);

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  // --- Stats Getters for Dashboards ---
  int get totalComplaints => _complaints.length;
  int get pendingComplaints =>
      _complaints.where((c) => c.status == ComplaintStatus.pending).length;
  int get inProgressComplaints =>
      _complaints.where((c) => c.status == ComplaintStatus.inProgress).length;
  int get resolvedComplaints =>
      _complaints.where((c) => c.status == ComplaintStatus.resolved).length;

  int get userTotalComplaints => userComplaints.length;
  int get userPendingComplaints =>
      userComplaints.where((c) => c.status == ComplaintStatus.pending).length;
  int get userInProgressComplaints =>
      userComplaints.where((c) => c.status == ComplaintStatus.inProgress).length;
  int get userResolvedComplaints =>
      userComplaints.where((c) => c.status == ComplaintStatus.resolved).length;

  // --- Authentication Simulation ---
  void login({
    required String email,
    required String password,
    required UserRole role,
    String? name,
  }) {
    if (role == UserRole.admin) {
      _currentUser = DummyData.defaultAdmin.copyWith(
        email: email.isNotEmpty ? email : null,
      );
    } else {
      _currentUser = DummyData.defaultResident.copyWith(
        email: email.isNotEmpty ? email : null,
        name: name ?? DummyData.defaultResident.name,
      );
    }
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  /// Switch role on the fly for demo presentation ease
  void switchRole(UserRole newRole) {
    if (newRole == UserRole.admin) {
      _currentUser = DummyData.defaultAdmin;
    } else {
      _currentUser = DummyData.defaultResident;
    }
    notifyListeners();
  }

  /// Update resident/admin profile details locally
  void updateProfile({
    required String name,
    required String phone,
    required String community,
  }) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        community: community,
      );
      notifyListeners();
    }
  }

  // --- Complaint Management ---

  /// Adds a new complaint to in-memory state and triggers notifications
  Complaint submitComplaint({
    required String title,
    required String category,
    required String community,
    required String locationDetails,
    required String description,
    required DateTime submissionDate,
    String? imagePath,
  }) {
    // Generate unique complaint ID formatted as WC-XXXX
    final int nextNumber = 1000 + _complaints.length + 1;
    final String complaintId = 'WC-$nextNumber';

    final newComplaint = Complaint(
      id: complaintId,
      title: title.trim(),
      category: category,
      community: community.trim(),
      locationDetails: locationDetails.trim(),
      description: description.trim(),
      submissionDate: submissionDate,
      status: ComplaintStatus.pending,
      imagePath: imagePath,
      userId: currentUser.id,
      residentName: currentUser.name,
      residentPhone: currentUser.phone,
    );

    // Insert at start of list for immediate visibility
    _complaints.insert(0, newComplaint);

    // Add automated confirmation notification
    _notifications.insert(
      0,
      AppNotification(
        id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Complaint Registered: $complaintId',
        message:
            'Your complaint for "$category" in "$community" has been registered and is pending municipal review.',
        timestamp: DateTime.now(),
        isRead: false,
        relatedComplaintId: complaintId,
      ),
    );

    notifyListeners();
    return newComplaint;
  }

  /// Updates complaint status from Admin dashboard or details screen
  void updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus newStatus,
    String? remarks,
  }) {
    final index = _complaints.indexWhere((c) => c.id == complaintId);
    if (index != -1) {
      final existing = _complaints[index];
      final updated = existing.copyWith(
        status: newStatus,
        adminRemarks: remarks ?? existing.adminRemarks,
        inProgressDate: newStatus == ComplaintStatus.inProgress
            ? (existing.inProgressDate ?? DateTime.now())
            : existing.inProgressDate,
        resolvedDate: newStatus == ComplaintStatus.resolved
            ? DateTime.now()
            : existing.resolvedDate,
      );

      _complaints[index] = updated;

      // Create an alert notification for the user
      _notifications.insert(
        0,
        AppNotification(
          id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Status Updated: ${updated.id}',
          message:
              'Complaint "${updated.title}" changed to ${newStatus.displayName.toUpperCase()}${remarks != null && remarks.isNotEmpty ? ': "$remarks"' : '.'}',
          timestamp: DateTime.now(),
          isRead: false,
          relatedComplaintId: updated.id,
        ),
      );

      notifyListeners();
    }
  }

  Complaint? getComplaintById(String id) {
    try {
      return _complaints.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Announcements Management ---
  void addAnnouncement({
    required String title,
    required String description,
    required String category,
    required String affectedAreas,
    bool isUrgent = false,
  }) {
    final newAnnouncement = WaterAnnouncement(
      id: 'ANN-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      category: category,
      dateTime: DateTime.now(),
      affectedAreas: affectedAreas,
      isUrgent: isUrgent,
    );

    _announcements.insert(0, newAnnouncement);

    // Also push a notification
    _notifications.insert(
      0,
      AppNotification(
        id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
        title: 'New Announcement: $title',
        message: description,
        timestamp: DateTime.now(),
        isRead: false,
        type: 'announcement',
      ),
    );

    notifyListeners();
  }

  // --- Notifications Management ---
  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Reset to pristine dummy state
  void resetToDefault() {
    _initData();
    notifyListeners();
  }
}
