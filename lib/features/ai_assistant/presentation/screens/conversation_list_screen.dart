import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        itemCount: 5,
        itemBuilder: (context, index) {
          final titles = [
            'University recommendations',
            'SOP writing help',
            'Visa interview prep',
            'Scholarship search',
            'Application strategy',
          ];
          final dates = [
            'Today',
            'Yesterday',
            '2 days ago',
            'Last week',
            '2 weeks ago',
          ];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    context.colorScheme.primaryContainer,
                child: Icon(Icons.auto_awesome,
                    color: context.colorScheme.primary, size: 20),
              ),
              title: Text(titles[index],
                  style: context.textTheme.titleSmall),
              subtitle: Text(dates[index],
                  style: context.textTheme.bodySmall),
              trailing:
                  const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () {
                // Navigate to conversation
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Start new conversation
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
