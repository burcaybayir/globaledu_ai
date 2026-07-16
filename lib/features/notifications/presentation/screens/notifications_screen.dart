import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.of(context).pop()),
        actions: [TextButton(onPressed: () {}, child: const Text('Mark all read'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        children: [
          _NotificationTile(
            icon: Icons.calendar_today_rounded, color: AppColors.error,
            title: 'Deadline Approaching', body: 'MIT application deadline is in 12 days', time: '2 hours ago', isUnread: true,
          ),
          _NotificationTile(
            icon: Icons.auto_awesome, color: AppColors.primary,
            title: 'AI Insight', body: 'New scholarship match found: Fulbright (92% match)', time: '5 hours ago', isUnread: true,
          ),
          _NotificationTile(
            icon: Icons.check_circle_rounded, color: AppColors.success,
            title: 'Document Reviewed', body: 'Your SOP has been reviewed by AI. Score: 78/100', time: 'Yesterday', isUnread: false,
          ),
          _NotificationTile(
            icon: Icons.school_rounded, color: AppColors.secondary,
            title: 'University Update', body: 'ETH Zurich has updated their admission requirements', time: '2 days ago', isUnread: false,
          ),
          _NotificationTile(
            icon: Icons.workspace_premium_rounded, color: AppColors.goldGradient.colors.first,
            title: 'Special Offer', body: 'Get 30% off Premium for the first 3 months!', time: '3 days ago', isUnread: false,
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.icon, required this.color, required this.title, required this.body, required this.time, required this.isUnread});
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: isUnread ? color.withOpacity(0.04) : null,
      child: ListTile(
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: context.textTheme.titleSmall?.copyWith(fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(body, style: context.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontSize: 11, color: context.colorScheme.onSurfaceVariant)),
          ],
        ),
        isThreeLine: true,
        trailing: isUnread ? Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)) : null,
        onTap: () {},
      ),
    );
  }
}
