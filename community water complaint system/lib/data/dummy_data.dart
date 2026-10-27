import '../models/user.dart';
import '../models/complaint.dart';
import '../models/announcement.dart';
import '../models/notification_model.dart';

/// Pre-populated dummy data for frontend presentation
class DummyData {
  static const AppUser defaultResident = AppUser(
    id: 'user_resident_1',
    name: 'Rahul Sharma',
    email: 'rahul.resident@community.org',
    phone: '+91 98765 43210',
    role: UserRole.resident,
    community: 'Green Valley Enclave, Block B',
  );

  static const AppUser defaultAdmin = AppUser(
    id: 'user_admin_1',
    name: 'Officer S. K. Verma',
    email: 'admin.waterboard@aquacare.gov',
    phone: '+91 94321 09876',
    role: UserRole.admin,
    community: 'Municipal Water Board Central Zone',
  );

  static List<Complaint> get initialComplaints => [
        Complaint(
          id: 'WC-1001',
          title: 'Main pipeline leak near Community Gate 2',
          category: ComplaintCategory.brokenPipeline,
          community: 'Green Valley Enclave',
          locationDetails: 'Near Security Gate 2, Cross Road 3',
          description:
              'A high-pressure pipeline fracture has caused water to pool across the entrance road. Potable water is wasting rapidly and causing traffic slowdown.',
          submissionDate: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
          status: ComplaintStatus.inProgress,
          userId: 'user_resident_1',
          residentName: 'Rahul Sharma',
          residentPhone: '+91 98765 43210',
          inProgressDate: DateTime.now().subtract(const Duration(days: 1)),
          adminRemarks: 'Assigned to Ward Plumber Unit 4. Repair crew on site.',
        ),
        Complaint(
          id: 'WC-1002',
          title: 'Dirty & brownish tap water in morning hours',
          category: ComplaintCategory.dirtyWater,
          community: 'Green Valley Enclave',
          locationDetails: 'Block B, Flat 304, 3rd Floor',
          description:
              'The tap water supplied during 6 AM to 8 AM contains visible brown silt and sediment. It is unsafe for drinking and cooking purposes.',
          submissionDate: DateTime.now().subtract(const Duration(hours: 14)),
          status: ComplaintStatus.pending,
          userId: 'user_resident_1',
          residentName: 'Rahul Sharma',
          residentPhone: '+91 98765 43210',
        ),
        Complaint(
          id: 'WC-1003',
          title: 'Severe low pressure on upper floors',
          category: ComplaintCategory.lowPressure,
          community: 'Sunrise Heights',
          locationDetails: 'Tower 4, Floors 5 to 9',
          description:
              'Water flow is reduced to a trickle in bathrooms and kitchens. Overhead storage tank is not filling completely during pumping cycles.',
          submissionDate: DateTime.now().subtract(const Duration(days: 4, hours: 6)),
          status: ComplaintStatus.resolved,
          userId: 'user_resident_1',
          residentName: 'Rahul Sharma',
          residentPhone: '+91 98765 43210',
          inProgressDate: DateTime.now().subtract(const Duration(days: 3)),
          resolvedDate: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          adminRemarks: 'Auxiliary booster pump valve repaired and pressure test passed (2.5 bar).',
        ),
        Complaint(
          id: 'WC-1004',
          title: 'Total water supply cutoff without notice',
          category: ComplaintCategory.noWaterSupply,
          community: 'Riverside Residency',
          locationDetails: 'Block C and Community Clubhouse',
          description:
              'No water supply received during the evening supply window between 5 PM and 8 PM. Residents require immediate tanker support.',
          submissionDate: DateTime.now().subtract(const Duration(hours: 6)),
          status: ComplaintStatus.pending,
          userId: 'user_resident_2',
          residentName: 'Priya Patel',
          residentPhone: '+91 98111 22334',
        ),
        Complaint(
          id: 'WC-1005',
          title: 'Overhead tank overflow valve broken',
          category: ComplaintCategory.waterLeakage,
          community: 'Palm Meadows',
          locationDetails: 'Overhead Reservoir 2, North Lane',
          description:
              'Automatic cutoff sensor failed; clean drinking water has been spilling continuously over the building parapet for 3 hours.',
          submissionDate: DateTime.now().subtract(const Duration(days: 3)),
          status: ComplaintStatus.resolved,
          userId: 'user_resident_3',
          residentName: 'Anil Kumar',
          residentPhone: '+91 97222 33445',
          inProgressDate: DateTime.now().subtract(const Duration(days: 2)),
          resolvedDate: DateTime.now().subtract(const Duration(days: 1)),
          adminRemarks: 'Float valve replaced with heavy-duty brass ball cock sensor.',
        ),
        Complaint(
          id: 'WC-1006',
          title: 'Underground supply line leakage near park',
          category: ComplaintCategory.waterLeakage,
          community: 'Green Valley Enclave',
          locationDetails: 'Children Park perimeter, East walkway',
          description:
              'Water bubbling up from under paving tiles. Ground has become soggy and there is risk of sinkhole development.',
          submissionDate: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
          status: ComplaintStatus.inProgress,
          userId: 'user_resident_1',
          residentName: 'Rahul Sharma',
          residentPhone: '+91 98765 43210',
          inProgressDate: DateTime.now().subtract(const Duration(hours: 18)),
          adminRemarks: 'Excavation scheduled today at 3:00 PM for joint sealing.',
        ),
      ];

  static List<WaterAnnouncement> get initialAnnouncements => [
        WaterAnnouncement(
          id: 'ANN-01',
          title: 'Scheduled Water Supply Interruption',
          description:
              'Maintenance and cleaning of central feeder pipelines. Supply will be suspended across Green Valley and Sunrise Heights from 10:00 AM to 02:00 PM tomorrow.',
          category: 'Scheduled Maintenance',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          affectedAreas: 'Green Valley & Sunrise Heights',
          isUrgent: true,
        ),
        WaterAnnouncement(
          id: 'ANN-02',
          title: 'Monthly Water Quality Audit: Grade A',
          description:
              'Routine microbiological and chemical tests for municipal water supply were completed. Turbidity and chlorine levels are within optimal WHO/BIS guidelines.',
          category: 'Quality Advisory',
          dateTime: DateTime.now().subtract(const Duration(days: 2)),
          affectedAreas: 'All Community Sectors',
          isUrgent: false,
        ),
        WaterAnnouncement(
          id: 'ANN-03',
          title: 'Monsoon Pipeline Desilting Drive',
          description:
              'Pre-monsoon desilting of drainage channels and secondary water conduits starting this weekend. Minimal pressure fluctuations may occur.',
          category: 'Infrastructure Notice',
          dateTime: DateTime.now().subtract(const Duration(days: 5)),
          affectedAreas: 'Riverside Residency & Palm Meadows',
          isUrgent: false,
        ),
      ];

  static List<AppNotification> get initialNotifications => [
        AppNotification(
          id: 'NOTIF-01',
          title: 'Complaint Update: #WC-1001',
          message: 'Your complaint regarding broken pipeline near Gate 2 has been updated to IN PROGRESS.',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: false,
          relatedComplaintId: 'WC-1001',
        ),
        AppNotification(
          id: 'NOTIF-02',
          title: 'Urgent: Maintenance Tomorrow',
          message: 'Water supply cutoff between 10 AM and 2 PM tomorrow. Please store adequate drinking water.',
          timestamp: DateTime.now().subtract(const Duration(hours: 7)),
          isRead: false,
          type: 'maintenance',
        ),
        AppNotification(
          id: 'NOTIF-03',
          title: 'Complaint Resolved: #WC-1003',
          message: 'Your low water pressure complaint was marked RESOLVED. Booster pump repaired.',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          isRead: true,
          relatedComplaintId: 'WC-1003',
        ),
        AppNotification(
          id: 'NOTIF-04',
          title: 'New Announcement Published',
          message: 'Municipal Water Board published Monthly Quality Audit Report.',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
          type: 'announcement',
        ),
      ];
}
