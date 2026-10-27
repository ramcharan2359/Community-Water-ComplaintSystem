# AquaCare – Community Water Complaint System (Flutter Frontend)

**AquaCare** is a modern, responsive, mobile application built using **Flutter and Dart** implementing **Material Design 3**. Designed specifically as a college mini-project, it demonstrates a complete civic water grievance portal allowing residents to report water-related issues (e.g., pipeline leaks, contamination, pressure drops) and administrators to manage civic resolutions using in-memory state.

---

## 🚀 Key Features

### 1. Resident Portal
- **Splash Screen:** Animated water droplet logo with smooth transition.
- **Demo Authentication:** Login & Registration with email validation, password visibility toggles, and 1-tap quick demo fillers.
- **Resident Home Dashboard:**
  - Real-time statistics counters (Total Complaints, Pending, Resolved).
  - Prominent "Report a Water Issue" call to action.
  - Water Supply Announcements & Interruption advisories.
  - Recent complaints list with colored status indicators.
- **Report Complaint Form:**
  - Categorized issues: *No Water Supply, Water Leakage, Dirty Water, Low Pressure, Broken Pipeline, Other*.
  - Interactive Date Picker.
  - Community and exact street landmark fields.
  - Detailed description with form validation.
  - Simulated photo attachment picker.
  - Dynamic Complaint ID generator (e.g., `WC-1007`).
- **My Complaints Screen:**
  - Real-time search across complaint ID, title, and location.
  - Status filter tabs: *All, Pending, In Progress, Resolved*.
  - Category filter dropdown.
  - Empty state with guidance when no results match.
- **Complaint Details Screen:**
  - Full grievance breakdown.
  - **Visual 3-Stage Resolution Timeline:** `Submitted → In Progress → Resolved`.
  - Photo evidence preview and resident contact card.
- **Notifications Screen:**
  - Real-time alerts on complaint status updates and maintenance notices.
  - Unread badge counter with "Mark All as Read" action.
- **Resident Profile:**
  - View resident details, edit profile in-memory, role switcher, and logout.

### 2. Municipal Administrator Portal
- **Admin Dashboard:**
  - High-level civic metrics: Total Complaints, Pending Action, In Progress, Resolved.
  - Comprehensive complaint roster with search and status chips.
  - **Quick Status Updater:** Change status (`Pending` → `In Progress` → `Resolved`) and add engineer remarks live in-memory.
  - **Broadcast Announcements:** Dialog to publish new water supply bulletins directly to residents.
  - Role switcher button for easy project presentations.

---

## 📁 Project Directory Structure

```text
community_water_complaint_system/
├── pubspec.yaml                 # Dependencies and asset configuration
├── analysis_options.yaml        # Linting rules for clean Dart code
├── README.md                    # Project documentation & run guide
└── lib/
    ├── main.dart                # Application entrypoint & Provider initialization
    ├── models/
    │   ├── user.dart            # User profile model & UserRole enum
    │   ├── complaint.dart       # Complaint model & ComplaintStatus enum
    │   ├── announcement.dart    # Water supply advisory bulletin model
    │   └── notification_model.dart # System & status change alert model
    ├── data/
    │   └── dummy_data.dart      # Pre-populated realistic community dummy data
    ├── services/
    │   └── mock_data_service.dart # In-memory state manager (ChangeNotifier)
    ├── theme/
    │   └── app_theme.dart       # Deep Blue & Aqua color scheme, M3 ThemeData
    ├── widgets/
    │   ├── status_chip.dart     # Color-coded status badge (Pending/In Progress/Resolved)
    │   ├── stat_card.dart       # Dashboard metric counter card
    │   ├── complaint_card.dart  # Complaint summary card with icons and timestamp
    │   ├── custom_button.dart   # Standardized elevated & outlined buttons
    │   ├── announcement_card.dart # Community advisory bulletin card
    │   └── status_timeline.dart # 3-stage visual progress stepper
    └── screens/
        ├── splash_screen.dart   # App branding and loading screen
        ├── login_screen.dart    # Role selector (Resident/Admin) and sign-in
        ├── register_screen.dart # Resident registration form
        ├── resident_home_screen.dart # Resident dashboard with bottom navigation
        ├── report_complaint_screen.dart # Form to file a new water issue
        ├── my_complaints_screen.dart # Filterable, searchable complaints list
        ├── complaint_details_screen.dart # Deep-dive view with timeline & admin actions
        ├── admin_dashboard_screen.dart # Municipal admin control desk
        ├── notifications_screen.dart # Alerts and bulletin notices
        └── profile_screen.dart  # User info, profile editor, and role switcher
```

---

## 🛠️ Step-by-Step Setup Guide

### Prerequisites
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.0.0 or later).
2. Install [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).
3. Install Flutter and Dart extensions in your IDE.

### Step 1: Open Project in VS Code / Android Studio
- Open VS Code, select **File > Open Folder...**, and select:
  `c:\Users\srinu\Downloads\community water complaint system`

### Step 2: Install Dependencies
Open the built-in terminal (`Ctrl + \`` in VS Code) and run:
```bash
flutter pub get
```

### Step 3: Run the Application
1. Start an Android Emulator, iOS Simulator, or connect a physical phone with USB Debugging enabled.
2. In the terminal, run:
```bash
flutter run
```
*(Alternatively, you can test on Google Chrome by running `flutter run -d chrome`)*

---

## 👥 Demo Accounts (For Viva & Presentation)

No server or database is required! All authentication is simulated in-memory for instant demonstration:

| Role | Demo Email | Demo Password | Quick Action |
|---|---|---|---|
| **Resident** | `rahul.resident@community.org` | `demo1234` | Tap **"Resident Demo"** button on Login screen |
| **Admin** | `admin.waterboard@aquacare.gov` | `admin1234` | Tap **"Admin Demo"** button on Login screen |

---

## 🎤 Suggested College Presentation Flow

1. **Splash Screen:** Show the clean water droplet logo and discuss the problem statement (delayed reporting of pipe bursts and poor community communication).
2. **Login Screen:** Highlight the role-based design (Resident vs Municipal Admin) and tap the 1-click **Resident Demo** button.
3. **Resident Home:** Show the live statistic tiles, active community announcements, and recent complaints.
4. **Report Water Issue:**
   - Fill in a new complaint (e.g. *Water Leakage at Gate 4*).
   - Show category selection and date picker.
   - Attach sample evidence photo.
   - Tap **Submit** to observe the generated Complaint ID dialog (e.g. `WC-1007`).
5. **My Complaints Screen:**
   - Demonstrate the newly created complaint appearing at the top of the list.
   - Test instant search and status filter chips (*Pending*, *In Progress*, *Resolved*).
6. **Complaint Details Screen:**
   - Walk through the visual 3-stage resolution stepper: `Submitted → In Progress → Resolved`.
7. **Switch to Admin Dashboard:**
   - Use the **Admin Demo** button or Profile role switcher to open the **Admin Portal**.
   - Show dynamic counters reflecting the newly reported issue.
   - Change the complaint status from `Pending` to `In Progress` or `Resolved` and add field remarks.
   - Broadcast a new supply bulletin.
8. **Notifications Screen:**
   - Verify that the status update notification and bulletin immediately arrived in the resident's notification feed.
