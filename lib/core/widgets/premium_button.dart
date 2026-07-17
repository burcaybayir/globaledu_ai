import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';

/// Premium animated button with scale + haptic feedback.
class PremiumButton extends StatefulWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.color,
    this.textColor = Colors.white,
    this.outlined = false,
    this.loading = false,
    this.height = AppSpacing.buttonHeight,
    this.borderRadius,
    this.fontSize = 15,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? color;
  final Color textColor;
  final bool outlined;
  final bool loading;
  final double height;
  final double? borderRadius;
  final double fontSize;
  final bool fullWidth;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _ctrl.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(_) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final radius = widget.borderRadius ?? AppSpacing.radiusMd;
    final gradient = widget.gradient ?? AppColors.primaryGradient;
    final color = widget.color ?? primary;

    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : null,
          height: widget.height,
          child: widget.outlined
              ? _OutlinedContent(
                  label: widget.label,
                  icon: widget.icon,
                  color: color,
                  radius: radius,
                  loading: widget.loading,
                  fontSize: widget.fontSize,
                )
              : _FilledContent(
                  label: widget.label,
                  icon: widget.icon,
                  gradient: gradient,
                  textColor: widget.textColor,
                  radius: radius,
                  loading: widget.loading,
                  fontSize: widget.fontSize,
                ),
        ),
      ),
    );
  }
}

class _FilledContent extends StatelessWidget {
  const _FilledContent({
    required this.label,
    required this.gradient,
    required this.textColor,
    required this.radius,
    required this.loading,
    required this.fontSize,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final Gradient gradient;
  final Color textColor;
  final double radius;
  final bool loading;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _buildContent(textColor),
    );
  }

  Widget _buildContent(Color color) {
    if (loading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _OutlinedContent extends StatelessWidget {
  const _OutlinedContent({
    required this.label,
    required this.color,
    required this.radius,
    required this.loading,
    required this.fontSize,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final double radius;
  final bool loading;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color, width: 1.5),
      ),
      child: loading
          ? Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
    );
  }
}
