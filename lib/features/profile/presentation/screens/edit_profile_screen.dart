import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';
import 'package:globaledu_ai/core/widgets/buttons/primary_button.dart';
import 'package:globaledu_ai/core/widgets/inputs/custom_text_field.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            // Avatar
            Stack(
              children: [
                CircleAvatar(radius: 50, backgroundColor: context.colorScheme.primaryContainer,
                  child: Text('JD', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: context.colorScheme.primary))),
                Positioned(bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: context.colorScheme.primary, shape: BoxShape.circle, border: Border.all(color: context.colorScheme.surface, width: 2)),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const CustomTextField(label: 'Full Name', hint: 'John Doe', prefixIcon: Icons.person_outline),
            const SizedBox(height: AppSpacing.lg),
            const CustomTextField(label: 'Phone', hint: '+1 234 567 890', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: AppSpacing.lg),
            const CustomTextField(label: 'Nationality', hint: 'Select nationality', prefixIcon: Icons.flag_outlined, readOnly: true),
            const SizedBox(height: AppSpacing.lg),
            const CustomTextField(label: 'Current School', hint: 'University name', prefixIcon: Icons.school_outlined),
            const SizedBox(height: AppSpacing.lg),
            const CustomTextField(label: 'GPA', hint: '3.50', prefixIcon: Icons.grade_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: AppSpacing.xxxl),
            PrimaryButton(text: 'Save Changes', onPressed: () => Navigator.of(context).pop()),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
