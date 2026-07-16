import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';
import 'package:globaledu_ai/core/widgets/buttons/gradient_button.dart';
import 'package:globaledu_ai/core/widgets/inputs/custom_text_field.dart';

class CreateApplicationScreen extends StatelessWidget {
  const CreateApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Application'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const CustomTextField(label: 'University', hint: 'Search university...', prefixIcon: Icons.school_outlined),
            const SizedBox(height: AppSpacing.lg),
            const CustomTextField(label: 'Program', hint: 'e.g., MSc Computer Science', prefixIcon: Icons.book_outlined),
            const SizedBox(height: AppSpacing.lg),
            const CustomTextField(label: 'Application Deadline', hint: 'Select date', prefixIcon: Icons.calendar_today_outlined, readOnly: true),
            const SizedBox(height: AppSpacing.lg),
            const CustomTextField(label: 'Notes', hint: 'Additional notes...', prefixIcon: Icons.notes_rounded, maxLines: 4),
            const SizedBox(height: AppSpacing.xxxl),
            GradientButton(text: 'Create Application', icon: Icons.add_rounded, onPressed: () => Navigator.of(context).pop()),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
