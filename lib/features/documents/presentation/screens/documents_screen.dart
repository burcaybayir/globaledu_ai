import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key, this.applicationId});
  final String? applicationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(icon: const Icon(Icons.cloud_upload_outlined), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        children: [
          _DocumentTile(name: 'Statement_of_Purpose.pdf', type: 'PDF', size: '245 KB', status: 'AI Reviewed', statusColor: AppColors.success),
          _DocumentTile(name: 'Transcript_Official.pdf', type: 'PDF', size: '1.2 MB', status: 'Uploaded', statusColor: AppColors.info),
          _DocumentTile(name: 'CV_Resume_2025.pdf', type: 'PDF', size: '180 KB', status: 'AI Reviewed', statusColor: AppColors.success),
          _DocumentTile(name: 'Recommendation_Prof_Smith.pdf', type: 'PDF', size: '520 KB', status: 'Uploaded', statusColor: AppColors.info),
          _DocumentTile(name: 'TOEFL_Score_Report.pdf', type: 'PDF', size: '340 KB', status: 'Pending Review', statusColor: AppColors.warning),
          _DocumentTile(name: 'Passport_Copy.jpg', type: 'Image', size: '2.8 MB', status: 'Uploaded', statusColor: AppColors.info),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.name, required this.type, required this.size, required this.status, required this.statusColor});
  final String name;
  final String type;
  final String size;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: type == 'PDF' ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            type == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
            color: type == 'PDF' ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(name, style: context.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('$size • $status', style: TextStyle(fontSize: 12, color: statusColor)),
        trailing: PopupMenuButton<String>(
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'preview', child: Text('Preview')),
            const PopupMenuItem(value: 'review', child: Text('AI Review')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {},
        ),
      ),
    );
  }
}
