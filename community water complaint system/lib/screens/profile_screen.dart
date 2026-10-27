import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'admin_dashboard_screen.dart';

/// User profile and app settings screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileBottomSheet(BuildContext context, AppUser user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final communityCtrl = TextEditingController(text: user.community);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Profile Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text('Contact Phone', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_outlined)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text('Residential Community', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: communityCtrl,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.apartment_rounded)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Community is required' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final dataService = Provider.of<MockDataService>(context, listen: false);
                          dataService.updateProfile(
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            community: communityCtrl.text.trim(),
                          );
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated in-memory successfully!'),
                              backgroundColor: AppTheme.statusResolved,
                            ),
                          );
                        }
                      },
                      child: const Text('Save Profile Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to log out of AquaCare? (Session data will remain during current app run).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusError),
            onPressed: () {
              Navigator.of(ctx).pop();
              final dataService = Provider.of<MockDataService>(context, listen: false);
              dataService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<MockDataService>(context);
    final user = dataService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppTheme.primaryLight,
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.water_drop,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isAdmin ? const Color(0xFFF3E5F5) : AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.roleDisplayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: user.isAdmin ? const Color(0xFF7B1FA2) : AppTheme.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit Profile Details'),
                      onPressed: () => _showEditProfileBottomSheet(context, user),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Profile Details List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileItem(
                      icon: Icons.email_outlined,
                      title: 'Email Address',
                      subtitle: user.email,
                    ),
                    const Divider(height: 20),
                    _buildProfileItem(
                      icon: Icons.phone_outlined,
                      title: 'Phone Number',
                      subtitle: user.phone,
                    ),
                    const Divider(height: 20),
                    _buildProfileItem(
                      icon: Icons.apartment_rounded,
                      title: 'Community / Ward',
                      subtitle: user.community,
                    ),
                    const Divider(height: 20),
                    _buildProfileItem(
                      icon: Icons.verified_user_outlined,
                      title: 'Account Role',
                      subtitle: user.isAdmin ? 'Municipal Administrator' : 'Registered Resident',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Presentation Quick Switch Card
            Card(
              color: const Color(0xFFF0FDF4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFBBF7D0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.swap_horiz_rounded, color: AppTheme.statusResolved),
                        SizedBox(width: 8),
                        Text(
                          'College Demo Role Switcher',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF14532D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Instantly test the Admin Dashboard or switch back to Resident flow without logging in again.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                      label: const Text('Open Admin Dashboard Demo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                      ),
                      onPressed: () {
                        dataService.switchRole(UserRole.admin);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // About Project Card
            Card(
              child: ExpansionTile(
                leading: const Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                title: const Text(
                  'About AquaCare Project',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: const Text(
                  'Frontend Mini-Project Specification',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      'AquaCare is a Flutter Material 3 community water grievance tracking application designed as an academic mini-project. It showcases responsive mobile UI, category categorization, status tracking, announcement broadcasting, and in-memory simulated state management without external backend dependencies.',
                      style: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF475569)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: AppTheme.statusError),
                label: const Text('Sign Out', style: TextStyle(color: AppTheme.statusError)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.statusError),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _confirmLogout(context),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
