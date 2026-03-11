import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';

/// E-Books Screen – shows downloadable textbooks grouped by subject.
class EbooksScreen extends StatelessWidget {
  const EbooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ebooks = MockDataService.ebooks;

    return Scaffold(
      appBar: const GradientAppBar(title: 'E-Books / Textbooks', showBackButton: true),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ebooks.length,
        itemBuilder: (context, index) {
          final book = ebooks[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Book icon with subject color
                Container(
                  width: 52,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.tileIconColors[index % AppColors.tileIconColors.length]
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.tileIconColors[index % AppColors.tileIconColors.length],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        book.subject,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // View / Download button
                GestureDetector(
                  onTap: () {
                    // Navigate to PDF viewer
                    Navigator.pushNamed(context, '/pdf-viewer',
                        arguments: {'title': book.title, 'url': book.pdfUrl});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility, size: 14, color: AppColors.primaryDark),
                        SizedBox(width: 4),
                        Text('View',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Simple PDF Viewer screen placeholder.
/// In production, use syncfusion_flutter_pdfviewer for real PDF rendering.
class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final title = args?['title'] ?? 'E-Book';

    return Scaffold(
      appBar: GradientAppBar(title: title, showBackButton: true),
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.picture_as_pdf, size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'PDF Viewer\nAdd syncfusion_flutter_pdfviewer for full support',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download started...')),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
