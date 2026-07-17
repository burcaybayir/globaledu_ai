import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/features/ai_assistant/domain/entities/chat_message.dart';

/// A single chat bubble — user or assistant
class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.streamingText,
    this.onSpeak,
    this.onCopy,
    this.isStreaming = false,
  });

  final ChatMessage message;
  final String? streamingText;
  final VoidCallback? onSpeak;
  final VoidCallback? onCopy;
  final bool isStreaming;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  bool _showActions = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  bool get isUser => widget.message.role == MessageRole.user;

  String get displayText =>
      widget.isStreaming && widget.streamingText != null
          ? widget.streamingText!
          : widget.message.content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(isUser ? 0.05 : -0.05, 0.02),
          end: Offset.zero,
        ).animate(_fade),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // ── Avatar + Bubble Row ──
              Row(
                mainAxisAlignment:
                    isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isUser) _AiAvatar(),
                  const SizedBox(width: 8),
                  Flexible(
                    child: GestureDetector(
                      onLongPress: () => setState(() => _showActions = !_showActions),
                      child: _BubbleContent(
                        text: displayText,
                        isUser: isUser,
                        isStreaming: widget.isStreaming,
                        attachments: widget.message.attachments,
                        theme: theme,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  if (isUser) const SizedBox(width: 8),
                ],
              ),

              // ── Action Bar (long press) ──
              if (_showActions && !isUser && displayText.isNotEmpty)
                _ActionBar(
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: displayText));
                    setState(() => _showActions = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  onSpeak: () {
                    widget.onSpeak?.call();
                    setState(() => _showActions = false);
                  },
                ),

              // ── Timestamp ──
              Padding(
                padding: EdgeInsets.only(
                  left: isUser ? 0 : 44,
                  right: isUser ? 8 : 0,
                  top: 4,
                ),
                child: Text(
                  _formatTime(widget.message.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  const _BubbleContent({
    required this.text,
    required this.isUser,
    required this.isStreaming,
    required this.attachments,
    required this.theme,
    required this.isDark,
  });

  final String text;
  final bool isUser;
  final bool isStreaming;
  final List<MessageAttachment> attachments;
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bgColor = isUser
        ? null
        : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant);
    final textColor = isUser ? Colors.white : theme.colorScheme.onSurface;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      decoration: BoxDecoration(
        gradient: isUser ? AppColors.primaryGradient : null,
        color: bgColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
          bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: isUser
                ? AppColors.primary.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attachments
          if (attachments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: attachments.map((a) => _AttachmentChip(a: a)).toList(),
              ),
            ),

          // Text content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: isUser
                ? Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  )
                : text.isEmpty && isStreaming
                    ? _TypingDots()
                    : MarkdownBody(
                        data: text,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            height: 1.6,
                          ),
                          h1: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          h2: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          h3: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          strong: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                          em: TextStyle(
                            color: textColor,
                            fontStyle: FontStyle.italic,
                          ),
                          code: TextStyle(
                            backgroundColor: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.06),
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: textColor,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          listBullet: TextStyle(color: textColor),
                          tableHead: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                          tableBody: TextStyle(color: textColor, fontSize: 13),
                          blockquotePadding: const EdgeInsets.symmetric(horizontal: 12),
                          blockquoteDecoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: AppColors.primary,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
          ),

          // Streaming cursor
          if (isStreaming && text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 14, bottom: 10),
              child: _StreamingCursor(),
            ),
        ],
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({required this.a});
  final MessageAttachment a;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = a.type == AttachmentType.image
        ? Icons.image_rounded
        : Icons.picture_as_pdf_rounded;
    final color = a.type == AttachmentType.image
        ? AppColors.secondary
        : AppColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            a.name.length > 20 ? '${a.name.substring(0, 17)}...' : a.name,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onCopy, required this.onSpeak});
  final VoidCallback onCopy;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 44, top: 6),
      child: Row(
        children: [
          _ActionBtn(icon: Icons.copy_rounded, label: 'Copy', onTap: onCopy),
          const SizedBox(width: 8),
          _ActionBtn(icon: Icons.volume_up_rounded, label: 'Read', onTap: onSpeak),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated streaming cursor blink
class _StreamingCursor extends StatefulWidget {
  @override
  State<_StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<_StreamingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 2,
        height: 16,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

/// Three-dot typing indicator
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final delay = i * 0.2;
            final v = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 1.0 + 0.4 * (v < 0.5 ? v * 2 : (1 - v) * 2);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 7,
                height: 7,
                margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.5 + 0.5 * (scale - 1) / 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
