import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/complaint.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/complaint_card.dart';
import 'complaint_details_screen.dart';

/// Screen displaying complaints filed by the current resident with search and filters
class MyComplaintsScreen extends StatefulWidget {
  final VoidCallback? onNavigateToReport;

  const MyComplaintsScreen({
    super.key,
    this.onNavigateToReport,
  });

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Filter states
  ComplaintStatus? _statusFilter; // null means all
  String? _categoryFilter; // null means all

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<MockDataService>(context);
    final userComplaints = dataService.userComplaints;

    // Filter logic
    final query = _searchController.text.trim().toLowerCase();
    final filteredComplaints = userComplaints.where((complaint) {
      final matchesSearch = query.isEmpty ||
          complaint.title.toLowerCase().contains(query) ||
          complaint.id.toLowerCase().contains(query) ||
          complaint.locationDetails.toLowerCase().contains(query) ||
          complaint.community.toLowerCase().contains(query);

      final matchesStatus = _statusFilter == null || complaint.status == _statusFilter;
      final matchesCategory = _categoryFilter == null || complaint.category == _categoryFilter;

      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Complaints'),
        actions: [
          if (_statusFilter != null || _categoryFilter != null || query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined),
              tooltip: 'Reset Filters',
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _statusFilter = null;
                  _categoryFilter = null;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by ID (e.g. WC-1001), keyword, or location...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),

                // Horizontal Status Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'All (${userComplaints.length})',
                        isSelected: _statusFilter == null,
                        onSelected: () => setState(() => _statusFilter = null),
                        activeColor: AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Pending (${dataService.userPendingComplaints})',
                        isSelected: _statusFilter == ComplaintStatus.pending,
                        onSelected: () => setState(() => _statusFilter = ComplaintStatus.pending),
                        activeColor: AppTheme.statusPending,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'In Progress (${dataService.userInProgressComplaints})',
                        isSelected: _statusFilter == ComplaintStatus.inProgress,
                        onSelected: () => setState(() => _statusFilter = ComplaintStatus.inProgress),
                        activeColor: AppTheme.statusInProgress,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Resolved (${dataService.userResolvedComplaints})',
                        isSelected: _statusFilter == ComplaintStatus.resolved,
                        onSelected: () => setState(() => _statusFilter = ComplaintStatus.resolved),
                        activeColor: AppTheme.statusResolved,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Category Filter Dropdown Bar
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, size: 16, color: AppTheme.textMuted),
                    const SizedBox(width: 6),
                    const Text('Category:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: _categoryFilter,
                            isExpanded: true,
                            hint: const Text('All Categories', style: TextStyle(fontSize: 12)),
                            style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('All Issue Categories'),
                              ),
                              ...ComplaintCategory.all.map((c) => DropdownMenuItem<String?>(
                                    value: c,
                                    child: Text(c),
                                  )),
                            ],
                            onChanged: (val) {
                              setState(() => _categoryFilter = val);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Complaint List or Empty State
          Expanded(
            child: filteredComplaints.isEmpty
                ? _buildEmptyState(isFiltering: userComplaints.isNotEmpty)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = filteredComplaints[index];
                      return ComplaintCard(
                        complaint: complaint,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ComplaintDetailsScreen(complaintId: complaint.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    required Color activeColor,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppTheme.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required bool isFiltering}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltering ? Icons.search_off_rounded : Icons.water_drop_outlined,
                size: 52,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltering ? 'No Matching Complaints' : 'No Complaints Logged Yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltering
                  ? 'Try adjusting your search criteria or resetting the status and category filters.'
                  : 'Everything looks clear! If you observe pipe leaks, contaminated tap water, or pressure drops, lodge an issue.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),
            if (isFiltering)
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset All Filters'),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _statusFilter = null;
                    _categoryFilter = null;
                  });
                },
              )
            else if (widget.onNavigateToReport != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text('Report a Water Issue'),
                onPressed: widget.onNavigateToReport,
              ),
          ],
        ),
      ),
    );
  }
}
