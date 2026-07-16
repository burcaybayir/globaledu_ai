import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';

class VisaChecklistScreen extends StatefulWidget {
  const VisaChecklistScreen({super.key, required this.country});
  final String country;

  @override
  State<VisaChecklistScreen> createState() => _VisaChecklistScreenState();
}

class _VisaChecklistScreenState extends State<VisaChecklistScreen> {
  final _checklist = <String, bool>{
    'Valid passport (6+ months validity)': true,
    'University acceptance letter (I-20)': true,
    'SEVIS fee payment receipt': true,
    'DS-160 confirmation page': false,
    'Passport-sized photos (2x2 inches)': false,
    'Financial documents (bank statements)': false,
    'Sponsor letter (if applicable)': false,
    'Academic transcripts': true,
    'Standardized test scores': true,
    'Visa appointment confirmation': false,
  };

  @override
  Widget build(BuildContext context) {
    final completed = _checklist.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.country} Visa Checklist'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.of(context).pop()),
      ),
      body: Column(
        children: [
          // Progress
          Container(
            margin: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$completed / ${_checklist.length} completed', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                        child: LinearProgressIndicator(
                          value: completed / _checklist.length,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Text('${(completed / _checklist.length * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28)),
              ],
            ),
          ),

          // Checklist
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingHorizontal),
              children: _checklist.entries.map((entry) {
                return CheckboxListTile(
                  value: entry.value,
                  onChanged: (v) => setState(() => _checklist[entry.key] = v!),
                  title: Text(entry.key, style: context.textTheme.bodyMedium?.copyWith(
                    decoration: entry.value ? TextDecoration.lineThrough : null,
                    color: entry.value ? context.colorScheme.onSurfaceVariant : null,
                  )),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
