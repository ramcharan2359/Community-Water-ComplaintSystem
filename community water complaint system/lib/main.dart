  import 'dart:async';
import 'package:flutter/material.dart';

// ============================================================================
// 1. DATE FORMATTER & ZERO-DEPENDENCY PROVIDER
// ============================================================================

class AppDate {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String full(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = _months[dt.month - 1];
    final y = dt.year;
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$d $m $y, $h:$min $ampm';
  }

  static String dateOnly(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = _months[dt.month - 1];
    final y = dt.year;
    final day = _days[dt.weekday - 1];
    return '$day, $d $m $y';
  }

  static String short(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = _months[dt.month - 1];
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$d $m, $h:$min $ampm';
  }
}

class DateFormat {
  final String pattern;
  const DateFormat(this.pattern);

  String format(DateTime dt) {
    if (pattern.contains('EEE')) return AppDate.dateOnly(dt);
    if (pattern.contains('yyyy')) return AppDate.full(dt);
    return AppDate.short(dt);
  }
}

class AppProvider extends InheritedNotifier<MockDataService> {
  const AppProvider({
    super.key,
    required MockDataService service,
    required super.child,
  }) : super(notifier: service);

  static MockDataService of(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<AppProvider>()!.notifier!;
    } else {
      final elem = context.getElementForInheritedWidgetOfExactType<AppProvider>();
      return (elem?.widget as AppProvider).notifier!;
    }
  }
}

class Provider {
  static T of<T extends ChangeNotifier>(BuildContext context, {bool listen = true}) {
    if (T == MockDataService) {
      return AppProvider.of(context, listen: listen) as T;
    }
    throw UnimplementedError('Provider configured for MockDataService');
  }
}

class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext context) create;
  final Widget child;

  const ChangeNotifierProvider({
    super.key,
    required this.create,
    required this.child,
  });

  @override
  State<ChangeNotifierProvider<T>> createState() => _ChangeNotifierProviderState<T>();
}

class _ChangeNotifierProviderState<T extends ChangeNotifier> extends State<ChangeNotifierProvider<T>> {
  late final T _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_notifier is MockDataService) {
      return AppProvider(
        service: _notifier as MockDataService,
        child: widget.child,
      );
    }
    return widget.child;
  }
}

// ============================================================================
// 2. DATA MODELS
// ============================================================================

enum UserRole { resident, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String community;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.community,
  });

  bool get isAdmin => role == UserRole.admin;
  String get roleDisplayName => isAdmin ? 'Municipal Administrator' : 'Community Resident';

  AppUser copyWith({String? name, String? email, String? phone, UserRole? role, String? community}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      community: community ?? this.community,
    );
  }
}

enum ComplaintStatus { pending, inProgress, resolved }

extension ComplaintStatusExtension on ComplaintStatus {
  String get displayName {
    switch (this) {
      case ComplaintStatus.pending: return 'Pending';
      case ComplaintStatus.inProgress: return 'In Progress';
      case ComplaintStatus.resolved: return 'Resolved';
    }
  }
}

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

  Complaint copyWith({
    ComplaintStatus? status,
    String? adminRemarks,
    DateTime? inProgressDate,
    DateTime? resolvedDate,
  }) {
    return Complaint(
      id: id,
      title: title,
      category: category,
      community: community,
      locationDetails: locationDetails,
      description: description,
      submissionDate: submissionDate,
      status: status ?? this.status,
      imagePath: imagePath,
      userId: userId,
      residentName: residentName,
      residentPhone: residentPhone,
      adminRemarks: adminRemarks ?? this.adminRemarks,
      inProgressDate: inProgressDate ?? this.inProgressDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
    );
  }
}

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

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedComplaintId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.relatedComplaintId,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      relatedComplaintId: relatedComplaintId,
    );
  }
}

// ============================================================================
// 3. IN-MEMORY STATE SERVICE (NO BACKEND)
// ============================================================================

class MockDataService extends ChangeNotifier {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  static MockDataService get instance => _instance;

  MockDataService._internal() {
    _initData();
  }

  AppUser _currentUser = const AppUser(
    id: 'user_res_1',
    name: 'Rahul Sharma',
    email: 'rahul.resident@community.org',
    phone: '+91 98765 43210',
    role: UserRole.resident,
    community: 'Green Valley Enclave, Block B',
  );

  final List<Complaint> _complaints = [];
  final List<WaterAnnouncement> _announcements = [];
  final List<AppNotification> _notifications = [];

  void _initData() {
    _complaints.addAll([
      Complaint(
        id: 'WC-1001',
        title: 'Main pipeline leak near Community Gate 2',
        category: ComplaintCategory.brokenPipeline,
        community: 'Green Valley Enclave',
        locationDetails: 'Near Security Gate 2, Cross Road 3',
        description: 'High-pressure pipeline fracture spilling potable drinking water rapidly over the road.',
        submissionDate: DateTime.now().subtract(const Duration(days: 2)),
        status: ComplaintStatus.inProgress,
        userId: 'user_res_1',
        residentName: 'Rahul Sharma',
        residentPhone: '+91 98765 43210',
        inProgressDate: DateTime.now().subtract(const Duration(days: 1)),
        adminRemarks: 'Field crew assigned. Replacement joint fitted.',
      ),
      Complaint(
        id: 'WC-1002',
        title: 'Brownish & muddy tap water in morning hours',
        category: ComplaintCategory.dirtyWater,
        community: 'Green Valley Enclave',
        locationDetails: 'Block B, Flat 304, 3rd Floor',
        description: 'Morning water supply contains visible brown sediment and silt. Unfit for drinking.',
        submissionDate: DateTime.now().subtract(const Duration(hours: 14)),
        status: ComplaintStatus.pending,
        userId: 'user_res_1',
        residentName: 'Rahul Sharma',
        residentPhone: '+91 98765 43210',
      ),
      Complaint(
        id: 'WC-1003',
        title: 'Severe low pressure on upper floors',
        category: ComplaintCategory.lowPressure,
        community: 'Sunrise Heights',
        locationDetails: 'Tower 4, Floors 5 to 9',
        description: 'Trickling water flow in kitchen and bathrooms. Overhead tank is not filling completely.',
        submissionDate: DateTime.now().subtract(const Duration(days: 4)),
        status: ComplaintStatus.resolved,
        userId: 'user_res_1',
        residentName: 'Rahul Sharma',
        residentPhone: '+91 98765 43210',
        inProgressDate: DateTime.now().subtract(const Duration(days: 3)),
        resolvedDate: DateTime.now().subtract(const Duration(days: 1)),
        adminRemarks: 'Booster pump pressure valve replaced and tested.',
      ),
      Complaint(
        id: 'WC-1004',
        title: 'Overhead reservoir overflow valve failure',
        category: ComplaintCategory.waterLeakage,
        community: 'Palm Meadows',
        locationDetails: 'Overhead Reservoir 2, North Lane',
        description: 'Float valve failed; clean water spilling over the building parapet for hours.',
        submissionDate: DateTime.now().subtract(const Duration(days: 1)),
        status: ComplaintStatus.pending,
        userId: 'user_res_2',
        residentName: 'Priya Patel',
        residentPhone: '+91 98111 22334',
      ),
    ]);

    _announcements.addAll([
      WaterAnnouncement(
        id: 'ANN-01',
        title: 'Scheduled Water Supply Interruption',
        description: 'Pipeline flushing and cleaning. Supply suspended across Sector 3 & 4 tomorrow from 10 AM to 2 PM.',
        category: 'Scheduled Maintenance',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        affectedAreas: 'Green Valley & Sunrise Heights',
        isUrgent: true,
      ),
      WaterAnnouncement(
        id: 'ANN-02',
        title: 'Monthly Water Quality Audit: Grade A',
        description: 'Microbiological and chemical tests completed. All parameters meet national WHO/BIS standards.',
        category: 'Quality Advisory',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        affectedAreas: 'All Community Sectors',
        isUrgent: false,
      ),
    ]);

    _notifications.addAll([
      AppNotification(
        id: 'NOTIF-01',
        title: 'Complaint Update: #WC-1001',
        message: 'Your grievance regarding the pipeline leak is now marked IN PROGRESS.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: false,
        relatedComplaintId: 'WC-1001',
      ),
      AppNotification(
        id: 'NOTIF-02',
        title: 'Maintenance Advisory',
        message: 'Scheduled water supply cutoff tomorrow from 10 AM to 2 PM. Please store sufficient water.',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        isRead: false,
      ),
      AppNotification(
        id: 'NOTIF-03',
        title: 'Complaint Resolved: #WC-1003',
        message: 'Your low water pressure complaint was resolved. Booster pump repaired.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        relatedComplaintId: 'WC-1003',
      ),
    ]);
  }

  AppUser get currentUser => _currentUser;
  List<Complaint> get complaints => List.unmodifiable(_complaints);
  List<Complaint> get userComplaints => _currentUser.isAdmin
      ? List.unmodifiable(_complaints)
      : List.unmodifiable(_complaints.where((c) => c.userId == _currentUser.id));
  List<WaterAnnouncement> get announcements => List.unmodifiable(_announcements);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;
  int get totalComplaints => _complaints.length;
  int get pendingComplaints => _complaints.where((c) => c.status == ComplaintStatus.pending).length;
  int get inProgressComplaints => _complaints.where((c) => c.status == ComplaintStatus.inProgress).length;
  int get resolvedComplaints => _complaints.where((c) => c.status == ComplaintStatus.resolved).length;

  int get userTotalComplaints => userComplaints.length;
  int get userPendingComplaints => userComplaints.where((c) => c.status == ComplaintStatus.pending).length;
  int get userInProgressComplaints => userComplaints.where((c) => c.status == ComplaintStatus.inProgress).length;
  int get userResolvedComplaints => userComplaints.where((c) => c.status == ComplaintStatus.resolved).length;

  void login({required String email, required UserRole role, String? name}) {
    if (role == UserRole.admin) {
      _currentUser = const AppUser(
        id: 'user_admin_1',
        name: 'Officer S. K. Verma',
        email: 'admin.waterboard@aquacare.gov',
        phone: '+91 94321 09876',
        role: UserRole.admin,
        community: 'Municipal Water Board Central Zone',
      );
    } else {
      _currentUser = AppUser(
        id: 'user_res_1',
        name: name ?? 'Rahul Sharma',
        email: email.isNotEmpty ? email : 'rahul.resident@community.org',
        phone: '+91 98765 43210',
        role: UserRole.resident,
        community: 'Green Valley Enclave, Block B',
      );
    }
    notifyListeners();
  }

  void logout() {
    _currentUser = const AppUser(
      id: 'guest',
      name: 'Guest User',
      email: '',
      phone: '',
      role: UserRole.resident,
      community: '',
    );
    notifyListeners();
  }

  void switchRole(UserRole newRole) {
    if (newRole == UserRole.admin) {
      _currentUser = const AppUser(
        id: 'user_admin_1',
        name: 'Officer S. K. Verma',
        email: 'admin.waterboard@aquacare.gov',
        phone: '+91 94321 09876',
        role: UserRole.admin,
        community: 'Municipal Water Board Central Zone',
      );
    } else {
      _currentUser = const AppUser(
        id: 'user_res_1',
        name: 'Rahul Sharma',
        email: 'rahul.resident@community.org',
        phone: '+91 98765 43210',
        role: UserRole.resident,
        community: 'Green Valley Enclave, Block B',
      );
    }
    notifyListeners();
  }

  void updateProfile({required String name, required String phone, required String community}) {
    _currentUser = _currentUser.copyWith(name: name, phone: phone, community: community);
    notifyListeners();
  }

  Complaint submitComplaint({
    required String title,
    required String category,
    required String community,
    required String locationDetails,
    required String description,
    required DateTime submissionDate,
    String? imagePath,
  }) {
    final complaintId = 'WC-${1000 + _complaints.length + 1}';
    final complaint = Complaint(
      id: complaintId,
      title: title.trim(),
      category: category,
      community: community.trim(),
      locationDetails: locationDetails.trim(),
      description: description.trim(),
      submissionDate: submissionDate,
      status: ComplaintStatus.pending,
      imagePath: imagePath,
      userId: _currentUser.id,
      residentName: _currentUser.name,
      residentPhone: _currentUser.phone,
    );

    _complaints.insert(0, complaint);
    _notifications.insert(
      0,
      AppNotification(
        id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Complaint Registered: $complaintId',
        message: 'Your complaint for "$category" has been logged with municipal engineering.',
        timestamp: DateTime.now(),
        relatedComplaintId: complaintId,
      ),
    );
    notifyListeners();
    return complaint;
  }

  void updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus newStatus,
    String? remarks,
  }) {
    final idx = _complaints.indexWhere((c) => c.id == complaintId);
    if (idx != -1) {
      final existing = _complaints[idx];
      _complaints[idx] = existing.copyWith(
        status: newStatus,
        adminRemarks: remarks ?? existing.adminRemarks,
        inProgressDate: newStatus == ComplaintStatus.inProgress ? DateTime.now() : existing.inProgressDate,
        resolvedDate: newStatus == ComplaintStatus.resolved ? DateTime.now() : existing.resolvedDate,
      );

      _notifications.insert(
        0,
        AppNotification(
          id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Status Updated: ${existing.id}',
          message: 'Grievance changed to ${newStatus.displayName.toUpperCase()}${remarks != null && remarks.isNotEmpty ? ': "$remarks"' : '.'}',
          timestamp: DateTime.now(),
          relatedComplaintId: existing.id,
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

  void addAnnouncement({
    required String title,
    required String description,
    required String category,
    required String affectedAreas,
    bool isUrgent = false,
  }) {
    _announcements.insert(
      0,
      WaterAnnouncement(
        id: 'ANN-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        category: category,
        dateTime: DateTime.now(),
        affectedAreas: affectedAreas,
        isUrgent: isUrgent,
      ),
    );
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }
}

// ============================================================================
// 4. THEME & PALETTE (MATERIAL DESIGN 3)
// ============================================================================

class AppTheme {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFFE3F2FD);
  static const Color secondaryAqua = Color(0xFF00ACC1);

  static const Color statusPending = Color(0xFFEF6C00);
  static const Color statusPendingBg = Color(0xFFFFF3E0);
  static const Color statusInProgress = Color(0xFF0288D1);
  static const Color statusInProgressBg = Color(0xFFE1F5FE);
  static const Color statusResolved = Color(0xFF2E7D32);
  static const Color statusResolvedBg = Color(0xFFE8F5E9);
  static const Color statusError = Color(0xFFD32F2F);

  static const Color backgroundLight = Color(0xFFF7FAFD);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: secondaryAqua,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryBlue, width: 2)),
      ),
    );
  }
}

// ============================================================================
// 5. REUSABLE WIDGETS
// ============================================================================

class StatusChip extends StatelessWidget {
  final ComplaintStatus status;
  final bool isCompact;

  const StatusChip({super.key, required this.status, this.isCompact = false});

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
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 10, vertical: isCompact ? 4 : 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: fg.withAlpha(60))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompact ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: fg, fontSize: isCompact ? 11 : 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 22),
                Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 6),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          ],
        ),
      ),
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onTap;

  const ComplaintCard({super.key, required this.complaint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(6)),
                    child: Text(complaint.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryDark, fontSize: 12)),
                  ),
                  StatusChip(status: complaint.status, isCompact: true),
                ],
              ),
              const SizedBox(height: 8),
              Text(complaint.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.water_drop_outlined, size: 14, color: AppTheme.primaryBlue),
                  const SizedBox(width: 4),
                  Text(complaint.category, style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Expanded(child: Text('${complaint.community} (${complaint.locationDetails})', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted))),
                  Text(AppDate.full(complaint.submissionDate), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          );

    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: child,
            ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final WaterAnnouncement announcement;

  const AnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (announcement.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: AppTheme.statusError, borderRadius: BorderRadius.circular(4)),
                    child: const Text('URGENT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                Text(announcement.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                const Spacer(),
                Text(AppDate.dateOnly(announcement.dateTime), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
            const SizedBox(height: 6),
            Text(announcement.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 4),
            Text(announcement.description, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.3)),
            const SizedBox(height: 6),
            Text('Affected: ${announcement.affectedAreas}', style: const TextStyle(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class StatusTimeline extends StatelessWidget {
  final Complaint complaint;

  const StatusTimeline({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final step1Done = true;
    final step2Active = complaint.status == ComplaintStatus.inProgress;
    final step2Done = step2Active || complaint.status == ComplaintStatus.resolved;
    final step3Done = complaint.status == ComplaintStatus.resolved;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resolution Progress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _step('Complaint Submitted', 'Registered in municipal civic portal', AppDate.full(complaint.submissionDate), step1Done, complaint.status == ComplaintStatus.pending, false),
          _step('Inspection In Progress', complaint.adminRemarks ?? 'Field crew assigned to inspect defect', complaint.inProgressDate != null ? AppDate.full(complaint.inProgressDate!) : 'Awaiting dispatch', step2Done, step2Active, false),
          _step('Resolved & Verified', 'Inspection confirmed water flow restored', complaint.resolvedDate != null ? AppDate.full(complaint.resolvedDate!) : 'Pending completion', step3Done, step3Done, true),
        ],
      ),
    );
  }

  Widget _step(String title, String subtitle, String time, bool isDone, bool isActive, bool isLast) {
    final color = isDone ? AppTheme.statusResolved : (isActive ? AppTheme.statusInProgress : const Color(0xFFCBD5E1));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(isDone ? Icons.check_circle : (isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked), size: 20, color: color),
              if (!isLast) Expanded(child: Container(width: 2, color: isDone ? AppTheme.statusResolved.withAlpha(120) : const Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDone || isActive ? AppTheme.textDark : AppTheme.textMuted)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                  Text(time, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. ALL 10 SCREENS
// ============================================================================

// ----------------------------------------------------------------------------
// SCREEN A: SPLASH SCREEN
// ----------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _goToLogin,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE3F2FD), Colors.white, Color(0xFFE0F7FA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.secondaryAqua]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_rounded, size: 54, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('AquaCare', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(16)),
                child: const Text('Community Water Complaints', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              ),
              const SizedBox(height: 16),
              const Text('Civic Water Grievance Portal\nCollege Mini-Project Demo', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 30),
              const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue))),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// SCREEN B: LOGIN SCREEN
// ----------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'rahul.resident@community.org');
  final _passwordController = TextEditingController(text: 'demo1234');

  UserRole _role = UserRole.resident;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemo(UserRole r) {
    setState(() {
      _role = r;
      if (r == UserRole.resident) {
        _emailController.text = 'rahul.resident@community.org';
        _passwordController.text = 'demo1234';
      } else {
        _emailController.text = 'admin.waterboard@aquacare.gov';
        _passwordController.text = 'admin1234';
      }
    });
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _loading = true);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        final service = Provider.of<MockDataService>(context, listen: false);
        service.login(email: _emailController.text.trim(), role: _role);
        setState(() => _loading = false);

        if (_role == UserRole.admin) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ResidentHomeScreen()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.water_drop_rounded, size: 52, color: AppTheme.primaryBlue),
                  const SizedBox(height: 10),
                  const Text('Welcome to AquaCare', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
                  const Text('Sign in to report and track water grievances', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFFE082))),
                    child: const Text('Frontend Demo: Data is simulated locally in-memory. Use quick fill below to sign in.', style: TextStyle(fontSize: 11, color: Color(0xFF795548))),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Resident')),
                          selected: _role == UserRole.resident,
                          onSelected: (_) => _fillDemo(UserRole.resident),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Municipal Admin')),
                          selected: _role == UserRole.admin,
                          onSelected: (_) => _fillDemo(UserRole.admin),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Password required' : null,
                  ),
                  const SizedBox(height: 18),

                  CustomButton(
                    text: _role == UserRole.admin ? 'Sign In as Admin' : 'Sign In as Resident',
                    icon: Icons.login,
                    isLoading: _loading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => _fillDemo(UserRole.resident), child: const Text('Resident Demo', style: TextStyle(fontSize: 12)))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton(onPressed: () => _fillDemo(UserRole.admin), child: const Text('Admin Demo', style: TextStyle(fontSize: 12)))),
                    ],
                  ),
                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('New Resident? Create Account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// SCREEN C: REGISTER SCREEN
// ----------------------------------------------------------------------------
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _commCtrl = TextEditingController(text: 'Green Valley Enclave');
  final _pwdCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _commCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      final service = Provider.of<MockDataService>(context, listen: false);
      service.login(email: _emailCtrl.text.trim(), role: UserRole.resident, name: _nameCtrl.text.trim());
      service.updateProfile(name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim(), community: _commCtrl.text.trim());

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ResidentHomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Create Resident Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email Address *'), validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number *'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _commCtrl, decoration: const InputDecoration(labelText: 'Community Name *'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _pwdCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password *'), validator: (v) => (v == null || v.length < 4) ? 'At least 4 chars' : null),
              const SizedBox(height: 20),
              CustomButton(text: 'Complete Registration', onPressed: _register),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// SCREEN D: RESIDENT MAIN SHELL & DASHBOARD
// ----------------------------------------------------------------------------
class ResidentHomeScreen extends StatefulWidget {
  const ResidentHomeScreen({super.key});

  @override
  State<ResidentHomeScreen> createState() => _ResidentHomeScreenState();
}

class _ResidentHomeScreenState extends State<ResidentHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final unread = service.unreadNotificationsCount;

    final pages = [
      _ResidentDashboardView(onReport: () => setState(() => _tab = 2), onViewComplaints: () => setState(() => _tab = 1)),
      MyComplaintsScreen(onNavigateToReport: () => setState(() => _tab = 2)),
      ReportComplaintScreen(onSubmitted: () => setState(() => _tab = 1)),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.water_drop_rounded, size: 20),
            SizedBox(width: 8),
            Text('AquaCare'),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              ),
              if (unread > 0)
                Positioned(
                  right: 8,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppTheme.statusError, shape: BoxShape.circle),
                    child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'My Complaints'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Report Issue'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _ResidentDashboardView extends StatelessWidget {
  final VoidCallback onReport;
  final VoidCallback onViewComplaints;

  const _ResidentDashboardView({required this.onReport, required this.onViewComplaints});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final user = service.currentUser;
    final complaints = service.userComplaints;
    final announcements = service.announcements;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primaryBlue, Color(0xFF1E88E5)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, ${user.name} 👋', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(user.community, style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 12)),
                const SizedBox(height: 10),
                const Text('Civic Helpline: 1800-419-AQUA (Toll Free)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: StatCard(title: 'Total Lodged', count: service.userTotalComplaints, icon: Icons.assignment, color: AppTheme.primaryBlue, backgroundColor: AppTheme.primaryLight, onTap: onViewComplaints)),
              const SizedBox(width: 8),
              Expanded(child: StatCard(title: 'Pending', count: service.userPendingComplaints, icon: Icons.hourglass_top, color: AppTheme.statusPending, backgroundColor: AppTheme.statusPendingBg, onTap: onViewComplaints)),
              const SizedBox(width: 8),
              Expanded(child: StatCard(title: 'Resolved', count: service.userResolvedComplaints, icon: Icons.check_circle, color: AppTheme.statusResolved, backgroundColor: AppTheme.statusResolvedBg, onTap: onViewComplaints)),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.add_alert_rounded, color: AppTheme.primaryBlue, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Facing a Water Problem?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Report leaks or dirty water supply.', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  ElevatedButton(onPressed: onReport, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue), child: const Text('Report')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          const Text('Water Supply Announcements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...announcements.take(2).map((a) => AnnouncementCard(announcement: a)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Grievances', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton(onPressed: onViewComplaints, child: const Text('View All')),
            ],
          ),
          ...complaints.take(2).map((c) => ComplaintCard(complaint: c, onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ComplaintDetailsScreen(complaintId: c.id)));
          })),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// SCREEN E: REPORT COMPLAINT SCREEN
// ----------------------------------------------------------------------------
class ReportComplaintScreen extends StatefulWidget {
  final VoidCallback? onSubmitted;

  const ReportComplaintScreen({super.key, this.onSubmitted});

  @override
  State<ReportComplaintScreen> createState() => _ReportComplaintScreenState();
}

class _ReportComplaintScreenState extends State<ReportComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _commCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _category = ComplaintCategory.waterLeakage;
  DateTime _date = DateTime.now();
  String? _attachedPhoto;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<MockDataService>(context, listen: false).currentUser;
    _commCtrl.text = user.community;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _commCtrl.dispose();
    _locCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final service = Provider.of<MockDataService>(context, listen: false);
      final newComplaint = service.submitComplaint(
        title: _titleCtrl.text.trim(),
        category: _category,
        community: _commCtrl.text.trim(),
        locationDetails: _locCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        submissionDate: _date,
        imagePath: _attachedPhoto,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(children: [Icon(Icons.check_circle, color: AppTheme.statusResolved), SizedBox(width: 8), Text('Lodged!')]),
          content: Text('Complaint generated with ID: ${newComplaint.id}\nMunicipal desk notified.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _titleCtrl.clear();
                _descCtrl.clear();
                if (widget.onSubmitted != null) widget.onSubmitted!();
              },
              child: const Text('View Complaints'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Report Water Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title *', hintText: 'e.g. Major pipe burst'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category *'),
                items: ComplaintCategory.all.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _commCtrl, decoration: const InputDecoration(labelText: 'Community / Ward *'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _locCtrl, decoration: const InputDecoration(labelText: 'Specific Street / Landmark *'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.cardBorder)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Date: ${AppDate.dateOnly(_date)}'),
                      const Text('Change', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Problem Description *'), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() => _attachedPhoto = _attachedPhoto == null ? 'pipe_leak_sample.jpg' : null);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.cardBorder)),
                  child: Row(
                    children: [
                      const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryBlue),
                      const SizedBox(width: 10),
                      Text(_attachedPhoto != null ? 'Attached: $_attachedPhoto (Tap to remove)' : 'Tap to attach evidence photo sample'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(text: 'Submit Grievance', icon: Icons.send, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// SCREEN F: MY COMPLAINTS SCREEN
// ----------------------------------------------------------------------------
class MyComplaintsScreen extends StatefulWidget {
  final VoidCallback? onNavigateToReport;

  const MyComplaintsScreen({super.key, this.onNavigateToReport});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  final _searchCtrl = TextEditingController();
  ComplaintStatus? _status;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final list = service.userComplaints;

    final q = _searchCtrl.text.trim().toLowerCase();
    final filtered = list.where((c) {
      final matchesQ = q.isEmpty || c.title.toLowerCase().contains(q) || c.id.toLowerCase().contains(q);
      final matchesS = _status == null || c.status == _status;
      return matchesQ && matchesS;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('My Complaints')),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(hintText: 'Search by ID (e.g. WC-1001), title...', prefixIcon: Icon(Icons.search)),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chip('All', _status == null, () => setState(() => _status = null)),
                      const SizedBox(width: 6),
                      _chip('Pending', _status == ComplaintStatus.pending, () => setState(() => _status = ComplaintStatus.pending)),
                      const SizedBox(width: 6),
                      _chip('In Progress', _status == ComplaintStatus.inProgress, () => setState(() => _status = ComplaintStatus.inProgress)),
                      const SizedBox(width: 6),
                      _chip('Resolved', _status == ComplaintStatus.resolved, () => setState(() => _status = ComplaintStatus.resolved)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No complaints matching filter.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => ComplaintCard(complaint: filtered[i], onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ComplaintDetailsScreen(complaintId: filtered[i].id)));
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool sel, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: sel ? AppTheme.primaryBlue : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
        child: Text(label, style: TextStyle(fontSize: 12, color: sel ? Colors.white : AppTheme.textDark, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// SCREEN G: COMPLAINT DETAILS SCREEN
// ----------------------------------------------------------------------------
class ComplaintDetailsScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintDetailsScreen({super.key, required this.complaintId});

  void _showStatusDialog(BuildContext context, Complaint complaint) {
    ComplaintStatus newS = complaint.status;
    final remarksCtrl = TextEditingController(text: complaint.adminRemarks ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Update ${complaint.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...ComplaintStatus.values.map((s) => RadioListTile<ComplaintStatus>(
                    value: s,
                    groupValue: newS,
                    title: StatusChip(status: s, isCompact: true),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => newS = val);
                    },
                  )),
              TextField(controller: remarksCtrl, decoration: const InputDecoration(hintText: 'Engineer remarks...')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final service = Provider.of<MockDataService>(context, listen: false);
                service.updateComplaintStatus(complaintId: complaint.id, newStatus: newS, remarks: remarksCtrl.text.trim());
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final complaint = service.getComplaintById(complaintId);

    if (complaint == null) {
      return Scaffold(appBar: AppBar(title: const Text('Complaint')), body: const Center(child: Text('Complaint not found.')));
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: Text(complaint.id)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(complaint.id, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        StatusChip(status: complaint.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(complaint.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(complaint.category, style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            StatusTimeline(complaint: complaint),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Location & Submission', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Community: ${complaint.community}'),
                    Text('Location: ${complaint.locationDetails}'),
                    Text('Date: ${AppDate.full(complaint.submissionDate)}'),
                    Text('Resident Contact: ${complaint.residentName} (${complaint.residentPhone})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(complaint.description, style: const TextStyle(color: Color(0xFF475569))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(text: 'Update Status (Admin Demo)', onPressed: () => _showStatusDialog(context, complaint)),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// SCREEN H: ADMIN DASHBOARD SCREEN
// ----------------------------------------------------------------------------
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _searchCtrl = TextEditingController();
  ComplaintStatus? _filter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _addAnnouncementDialog(BuildContext context) {
    final title = TextEditingController();
    final desc = TextEditingController();
    final areas = TextEditingController(text: 'All Sectors');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Post Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: areas, decoration: const InputDecoration(labelText: 'Affected Areas')),
            TextField(controller: desc, maxLines: 2, decoration: const InputDecoration(labelText: 'Details')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (title.text.isNotEmpty) {
                Provider.of<MockDataService>(context, listen: false).addAnnouncement(
                  title: title.text.trim(),
                  description: desc.text.trim(),
                  category: 'Scheduled Notice',
                  affectedAreas: areas.text.trim(),
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Broadcast'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final all = service.complaints;

    final q = _searchCtrl.text.trim().toLowerCase();
    final filtered = all.where((c) {
      final matchesQ = q.isEmpty || c.title.toLowerCase().contains(q) || c.id.toLowerCase().contains(q);
      final matchesS = _filter == null || c.status == _filter;
      return matchesQ && matchesS;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Municipal Admin Desk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Switch to Resident',
            onPressed: () {
              service.switchRole(UserRole.resident);
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ResidentHomeScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              service.logout();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addAnnouncementDialog(context),
        icon: const Icon(Icons.add_alert),
        label: const Text('Post Bulletin'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: StatCard(title: 'Total Lodged', count: service.totalComplaints, icon: Icons.list_alt, color: AppTheme.primaryBlue, backgroundColor: AppTheme.primaryLight, onTap: () => setState(() => _filter = null))),
                const SizedBox(width: 8),
                Expanded(child: StatCard(title: 'Pending Action', count: service.pendingComplaints, icon: Icons.access_time, color: AppTheme.statusPending, backgroundColor: AppTheme.statusPendingBg, onTap: () => setState(() => _filter = ComplaintStatus.pending))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: StatCard(title: 'In Progress', count: service.inProgressComplaints, icon: Icons.engineering, color: AppTheme.statusInProgress, backgroundColor: AppTheme.statusInProgressBg, onTap: () => setState(() => _filter = ComplaintStatus.inProgress))),
                const SizedBox(width: 8),
                Expanded(child: StatCard(title: 'Resolved', count: service.resolvedComplaints, icon: Icons.check_circle, color: AppTheme.statusResolved, backgroundColor: AppTheme.statusResolvedBg, onTap: () => setState(() => _filter = ComplaintStatus.resolved))),
              ],
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Search grievances...', prefixIcon: Icon(Icons.search)),
            ),
            const SizedBox(height: 14),

            ...filtered.map((c) => ComplaintCard(complaint: c, onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ComplaintDetailsScreen(complaintId: c.id)));
            })),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// SCREEN I: NOTIFICATIONS SCREEN
// ----------------------------------------------------------------------------
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final notifications = service.notifications;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(icon: const Icon(Icons.done_all), onPressed: () => service.markAllNotificationsAsRead()),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final notif = notifications[i];
          return Card(
            child: ListTile(
              leading: Icon(notif.isRead ? Icons.notifications_none : Icons.notifications_active, color: notif.isRead ? AppTheme.textMuted : AppTheme.primaryBlue),
              title: Text(notif.title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold)),
              subtitle: Text('${notif.message}\n${AppDate.short(notif.timestamp)}'),
              onTap: () {
                service.markNotificationAsRead(notif.id);
                if (notif.relatedComplaintId != null) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ComplaintDetailsScreen(complaintId: notif.relatedComplaintId!)));
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// SCREEN J: PROFILE SCREEN
// ----------------------------------------------------------------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _editSheet(BuildContext context, AppUser user) {
    final name = TextEditingController(text: user.name);
    final phone = TextEditingController(text: user.phone);
    final comm = TextEditingController(text: user.community);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 16, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: comm, decoration: const InputDecoration(labelText: 'Community')),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                Provider.of<MockDataService>(context, listen: false).updateProfile(name: name.text.trim(), phone: phone.text.trim(), community: comm.text.trim());
                Navigator.of(ctx).pop();
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<MockDataService>(context);
    final user = service.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(radius: 32, backgroundColor: AppTheme.primaryLight, child: Text(user.name.isNotEmpty ? user.name[0] : 'U', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue))),
                    const SizedBox(height: 8),
                    Text(user.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    Text(user.roleDisplayName, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: () => _editSheet(context, user), child: const Text('Edit Profile')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(leading: const Icon(Icons.email_outlined), title: Text(user.email.isNotEmpty ? user.email : 'Not set')),
                  ListTile(leading: const Icon(Icons.phone_outlined), title: Text(user.phone.isNotEmpty ? user.phone : 'Not set')),
                  ListTile(leading: const Icon(Icons.home_outlined), title: Text(user.community.isNotEmpty ? user.community : 'Not set')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Switch to Admin Demo',
              isOutlined: true,
              onPressed: () {
                service.switchRole(UserRole.admin);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
              },
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: 'Sign Out',
              onPressed: () {
                service.logout();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 7. APPLICATION ENTRYPOINT
// ============================================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AquaCareApp());
}

class AquaCareApp extends StatelessWidget {
  const AquaCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MockDataService(),
      child: MaterialApp(
        title: 'AquaCare – Community Water Complaints',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}