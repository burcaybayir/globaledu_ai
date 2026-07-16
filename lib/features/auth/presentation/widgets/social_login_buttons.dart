import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/features/auth/presentation/providers/auth_provider.dart';

class SocialLoginButtons extends ConsumerWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    return Column(
      children: [
        // Google
        _SocialButton(
          onPressed: () {
            ref.read(authNotifierProvider.notifier).signInWithGoogle();
          },
          icon: Icons.g_mobiledata_rounded,
          label: 'Continue with Google',
          backgroundColor: isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightSurfaceVariant,
          textColor: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        const SizedBox(height: AppSpacing.md),

        // Apple (iOS only)
        if (isIOS) ...[
          _SocialButton(
            onPressed: () {
              // TODO: Apple sign in
            },
            icon: Icons.apple_rounded,
            label: 'Continue with Apple',
            backgroundColor: isDark ? Colors.white : Colors.black,
            textColor: isDark ? Colors.black : Colors.white,
            iconColor: isDark ? Colors.black : Colors.white,
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.iconColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor ?? textColor, size: 28),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
