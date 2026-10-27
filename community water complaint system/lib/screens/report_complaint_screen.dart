import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/complaint.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'complaint_details_screen.dart';

/// Screen allowing residents to submit a new water complaint
class ReportComplaintScreen extends StatefulWidget {
  final VoidCallback? onComplaintSubmitted;

  const ReportComplaintScreen({
    super.key,
    this.onComplaintSubmitted,
  });

  @override
  State<ReportComplaintScreen> createState() => _ReportComplaintScreenState();
}

class _ReportComplaintScreenState extends State<ReportComplaintScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _communityController = TextEditingController();
  final _locationDetailsController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = ComplaintCategory.waterLeakage;
  DateTime _selectedDate = DateTime.now();
  String? _attachedImagePlaceholder;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Default community from currently logged in user
    final user = Provider.of<MockDataService>(context, listen: false).currentUser;
    _communityController.text = user.community;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _communityController.dispose();
    _locationDetailsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectSampleAttachment(String sampleName) {
    setState(() {
      _attachedImagePlaceholder = sampleName;
    });
    Navigator.of(context).pop();
  }

  void _showImageAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attach Evidence Photo (Demo)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a simulated photo sample to attach with your water grievance report.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryLight,
                    child: Icon(Icons.water_drop, color: AppTheme.primaryBlue),
                  ),
                  title: const Text('Broken Pipe & Gushing Leakage Photo'),
                  subtitle: const Text('Simulated JPG evidence • 1.2 MB'),
                  onTap: () => _selectSampleAttachment('pipe_leak_sample.jpg'),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF3E0),
                    child: Icon(Icons.waves, color: Color(0xFFEF6C00)),
                  ),
                  title: const Text('Dirty / Muddy Tap Water Photo'),
                  subtitle: const Text('Simulated JPG evidence • 950 KB'),
                  onTap: () => _selectSampleAttachment('dirty_water_sample.jpg'),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.speed, color: Color(0xFF2E7D32)),
                  ),
                  title: const Text('Low Pressure Pressure Gauge Photo'),
                  subtitle: const Text('Simulated JPG evidence • 840 KB'),
                  onTap: () => _selectSampleAttachment('pressure_gauge_sample.jpg'),
                ),
                if (_attachedImagePlaceholder != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.statusErrorBg,
                      child: Icon(Icons.delete_outline, color: AppTheme.statusError),
                    ),
                    title: const Text(
                      'Remove Attachment',
                      style: TextStyle(color: AppTheme.statusError),
                    ),
                    onTap: () {
                      setState(() => _attachedImagePlaceholder = null);
                      Navigator.of(ctx).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitComplaint() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        final dataService = Provider.of<MockDataService>(context, listen: false);

        final newComplaint = dataService.submitComplaint(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          community: _communityController.text.trim(),
          locationDetails: _locationDetailsController.text.trim(),
          description: _descriptionController.text.trim(),
          submissionDate: _selectedDate,
          imagePath: _attachedImagePlaceholder,
        );

        setState(() => _isSubmitting = false);

        // Show Success Dialog with generated Complaint ID
        _showSuccessDialog(newComplaint);
      });
    }
  }

  void _showSuccessDialog(Complaint complaint) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppTheme.statusResolvedBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.statusResolved,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Complaint Registered!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your water grievance has been successfully lodged with the municipal water department.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primaryBlue.withAlpha(60)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Complaint ID: ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    complaint.id,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _resetForm();
                      if (widget.onComplaintSubmitted != null) {
                        widget.onComplaintSubmitted!();
                      }
                    },
                    child: const Text('Back to Home'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _resetForm();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ComplaintDetailsScreen(complaintId: complaint.id),
                        ),
                      );
                    },
                    child: const Text('View Status'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    _titleController.clear();
    _locationDetailsController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = ComplaintCategory.waterLeakage;
      _selectedDate = DateTime.now();
      _attachedImagePlaceholder = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Report Water Issue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Intro Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryLight,
                      child: Icon(Icons.add_alert_rounded, color: AppTheme.primaryBlue),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Civic Water Grievance Form',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Fill in the accurate location & issue category for faster municipal response.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Complaint Title
              const Text(
                'Complaint Title *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Major pipeline burst spilling drinking water',
                  prefixIcon: Icon(Icons.title_rounded, color: AppTheme.primaryBlue),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a brief complaint title';
                  }
                  if (v.trim().length < 5) {
                    return 'Title should be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              const Text(
                'Water Issue Category *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined, color: AppTheme.primaryBlue),
                ),
                items: ComplaintCategory.all.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Community Name
              const Text(
                'Community / Residential Society *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _communityController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Green Valley Enclave, Sector 4',
                  prefixIcon: Icon(Icons.apartment_rounded, color: AppTheme.primaryBlue),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Community name is required' : null,
              ),
              const SizedBox(height: 16),

              // Street & Location Details
              const Text(
                'Specific Street / Landmark / Flat Details *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationDetailsController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Gate #2 near Electrical Substation, Main Avenue',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.primaryBlue),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please specify the exact location' : null,
              ),
              const SizedBox(height: 16),

              // Date Selection
              const Text(
                'Incident Observation Date *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, color: AppTheme.primaryBlue, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            dateFormat.format(_selectedDate),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Text(
                        'Change Date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Detailed Description
              const Text(
                'Complaint Description *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Describe the intensity of water issue, how long it has been occurring, and if emergency tankers are needed...',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please describe the problem';
                  }
                  if (v.trim().length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image Attachment UI
              const Text(
                'Evidence Photo (Optional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _showImageAttachmentSheet,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _attachedImagePlaceholder != null
                          ? AppTheme.secondaryAqua
                          : AppTheme.cardBorder,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _attachedImagePlaceholder == null
                      ? const Column(
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 36, color: AppTheme.secondaryAqua),
                            SizedBox(height: 8),
                            Text(
                              'Tap to attach photo proof',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Helps municipal engineers assess pipe damage or water turbidity',
                              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.statusResolvedBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.image_rounded,
                                color: AppTheme.statusResolved,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _attachedImagePlaceholder!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const Text(
                                    'Sample attachment attached successfully',
                                    style: TextStyle(fontSize: 11, color: AppTheme.statusResolved),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppTheme.statusError),
                              onPressed: () {
                                setState(() => _attachedImagePlaceholder = null);
                              },
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              CustomButton(
                text: 'Submit Grievance Report',
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                onPressed: _submitComplaint,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
