import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/features/ai_assistant/domain/entities/chat_message.dart';

/// Bottom input bar: text field + voice + file attachment + send button
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    this.isStreaming = false,
    this.isListening = false,
    this.voiceText = '',
    this.onVoiceStart,
    this.onVoiceStop,
  });

  final void Function(String text, List<MessageAttachment> attachments) onSend;
  final bool isStreaming;
  final bool isListening;
  final String voiceText;
  final VoidCallback? onVoiceStart;
  final VoidCallback? onVoiceStop;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final _picker = ImagePicker();
  final _uuid = const Uuid();
  final List<MessageAttachment> _attachments = [];

  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatInputBar old) {
    super.didUpdateWidget(old);
    // Update text field when voice text changes
    if (widget.voiceText != old.voiceText && widget.voiceText.isNotEmpty) {
      _ctrl.text = widget.voiceText;
      _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    }
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty && _attachments.isEmpty) return;
    widget.onSend(text, List.from(_attachments));
    _ctrl.clear();
    _attachments.clear();
    setState(() {});
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Web: use file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final f = result.files.first;
        setState(() {
          _attachments.add(MessageAttachment(
            id: _uuid.v4(),
            name: f.name,
            type: AttachmentType.image,
            url: '',
            size: f.size,
          ));
        });
      }
    } else {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _attachments.add(MessageAttachment(
            id: _uuid.v4(),
            name: image.name,
            type: AttachmentType.image,
            url: image.path,
            localPath: image.path,
          ));
        });
      }
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      withData: kIsWeb,
    );
    if (result != null && result.files.isNotEmpty) {
      final f = result.files.first;
      // Extract text from PDF/txt on web
      String? extractedText;
      if (f.extension == 'txt' && f.bytes != null) {
        extractedText = String.fromCharCodes(f.bytes!);
      }
      setState(() {
        _attachments.add(MessageAttachment(
          id: _uuid.v4(),
          name: f.name,
          type: f.extension == 'pdf'
              ? AttachmentType.pdf
              : AttachmentType.document,
          url: '',
          size: f.size,
          localPath: kIsWeb ? null : f.path,
          extractedText: extractedText,
        ));
      });
    }
  }

  void _removeAttachment(String id) {
    setState(() => _attachments.removeWhere((a) => a.id == id));
  }

  bool get _canSend =>
      (_ctrl.text.trim().isNotEmpty || _attachments.isNotEmpty) &&
      !widget.isStreaming;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Attachments Preview ────────────────────────────────────────
            if (_attachments.isNotEmpty)
              SizedBox(
                height: 72,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _AttachmentPreview(
                    attachment: _attachments[i],
                    onRemove: () => _removeAttachment(_attachments[i].id),
                  ),
                ),
              ),

            // ── Voice Recording Indicator ──────────────────────────────────
            if (widget.isListening)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _pulse,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.voiceText.isEmpty
                            ? 'Listening...'
                            : widget.voiceText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onVoiceStop,
                      child: Icon(Icons.stop_rounded, color: AppColors.error, size: 20),
                    ),
                  ],
                ),
              ),

            // ── Input Row ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attach button
                  _CircleBtn(
                    icon: Icons.add_rounded,
                    onTap: () => _showAttachMenu(context),
                    color: theme.colorScheme.surfaceContainerHighest,
                    iconColor: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),

                  // Text field
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: widget.isStreaming
                              ? 'AI is thinking...'
                              : 'Ask about universities, visas, scholarships...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        enabled: !widget.isStreaming,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Voice or Send
                  if (_canSend)
                    _CircleBtn(
                      icon: Icons.send_rounded,
                      onTap: _send,
                      gradient: AppColors.primaryGradient,
                      iconColor: Colors.white,
                    )
                  else
                    _CircleBtn(
                      icon: widget.isListening
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                      onTap: widget.isListening
                          ? widget.onVoiceStop
                          : widget.onVoiceStart,
                      color: widget.isListening
                          ? AppColors.error.withOpacity(0.15)
                          : theme.colorScheme.surfaceContainerHighest,
                      iconColor: widget.isListening
                          ? AppColors.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AttachOption(
              icon: Icons.image_rounded,
              label: 'Photo / Image',
              color: AppColors.secondary,
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            const SizedBox(height: 12),
            _AttachOption(
              icon: Icons.picture_as_pdf_rounded,
              label: 'PDF / Document',
              color: AppColors.accent,
              onTap: () {
                Navigator.pop(context);
                _pickDocument();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    this.onTap,
    this.gradient,
    this.color,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? color : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({required this.attachment, required this.onRemove});
  final MessageAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final icon = attachment.type == AttachmentType.image
        ? Icons.image_rounded
        : Icons.picture_as_pdf_rounded;
    final color = attachment.type == AttachmentType.image
        ? AppColors.secondary
        : AppColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            attachment.name.length > 14
                ? '${attachment.name.substring(0, 11)}...'
                : attachment.name,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, color: color, size: 16),
          ),
        ],
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Text(label, style: theme.textTheme.titleSmall),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
