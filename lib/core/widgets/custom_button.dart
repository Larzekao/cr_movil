import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonType type;
  final double? width;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = ButtonType.primary,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getForegroundColor(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: type == ButtonType.primary ? 2 : 0,
          side: type == ButtonType.outlined
              ? const BorderSide(color: AppColors.primary)
              : null,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(
                      color: _getForegroundColor(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.outlined:
        return Colors.transparent;
      case ButtonType.text:
        return Colors.transparent;
      case ButtonType.error:
        return AppColors.error;
    }
  }

  Color _getForegroundColor() {
    switch (type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
        return Colors.white;
      case ButtonType.outlined:
        return AppColors.primary;
      case ButtonType.text:
        return AppColors.primary;
      case ButtonType.error:
        return Colors.white;
    }
  }
}

enum ButtonType { primary, secondary, outlined, text, error }
