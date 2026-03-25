import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../models/announcement.dart';
import '../services/auth_service.dart';
import '../widgets/shared_widgets.dart';

class AnnouncementCarousel extends StatefulWidget {
  final String userRole;
  final String? userClass;

  const AnnouncementCarousel({
    super.key,
    required this.userRole,
    this.userClass,
  });

  @override
  State<AnnouncementCarousel> createState() => _AnnouncementCarouselState();
}

class _AnnouncementCarouselState extends State<AnnouncementCarousel> {
  late PageController _pageController;
  Timer? _carouselTimer;
  int _currentPage = 0;
  int _actualCount = 0;
  late Stream<QuerySnapshot> _announcementsStream;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    
    _announcementsStream = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('date', descending: true)
        .snapshots();
        
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && _actualCount > 1) {
        _currentPage = (_currentPage + 1) % _actualCount;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _announcementsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 90, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return SizedBox(height: 90, child: Center(child: Text("Error: ${snapshot.error}")));
        }

        final docs = snapshot.data?.docs ?? [];
        final List<Announcement> allVisible = [];

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final ann = Announcement.fromMap(data, doc.id);
          
          if (!ann.isActive) continue;

          // Filtering logic based on user profile
          bool roleMatch = false;
          if (widget.userRole == 'admin') {
            roleMatch = true; // Admin sees everything
          } else if (widget.userRole == 'teacher') {
            roleMatch = ann.targetRole == 'all' || ann.targetRole == 'teachers';
          } else if (widget.userRole == 'parent' || widget.userRole == 'student') {
            roleMatch = ann.targetRole == 'all' || ann.targetRole == 'students' || ann.targetRole == 'parents' || ann.targetRole == 'parent';
          }

          if (!roleMatch) continue;

          // Class filtering (mostly for students/parents)
          if (ann.targetClass != null && widget.userClass != null && ann.targetClass != widget.userClass) {
             if (widget.userRole != 'admin') continue;
          }

          allVisible.add(ann);
        }

        final announcements = allVisible.take(5).toList();
        
        // Sync actual count for timer
        if (_actualCount != announcements.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _actualCount = announcements.length);
          });
        }

        if (announcements.isEmpty) {
          return _buildEmptyState();
        }

        if (_currentPage >= announcements.length) {
          _currentPage = 0;
        }

        return Column(
          children: [
            SizedBox(
              height: 90,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final ann = announcements[index];
                  return _buildAnnouncementItem(ann);
                },
              ),
            ),
            if (announcements.length > 1) _buildPageIndicator(announcements.length),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome to Dastur School', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Stay tuned for upcoming announcements.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(Announcement ann) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context, 
          '/announcement-detail', 
          arguments: ann,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getAnnouncementColor(ann.type).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAnnouncementIcon(ann.type),
                  color: _getAnnouncementColor(ann.type),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ann.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ann.date.day}/${ann.date.month}/${ann.date.year}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: ann.type.toUpperCase(),
                color: _getAnnouncementColor(ann.type),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentPage == index ? 12 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: _currentPage == index 
                ? AppColors.primary 
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }

  Color _getAnnouncementColor(String type) {
    switch (type) {
      case 'alert': return AppColors.error;
      case 'event': return AppColors.info;
      case 'circular': return AppColors.accent;
      default: return AppColors.success;
    }
  }

  IconData _getAnnouncementIcon(String type) {
    switch (type) {
      case 'alert': return Icons.warning_amber_rounded;
      case 'event': return Icons.event;
      case 'circular': return Icons.article_outlined;
      default: return Icons.campaign;
    }
  }
}
