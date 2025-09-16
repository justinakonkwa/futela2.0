import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? icon;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.padding,
    this.borderRadius,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? 
        (isOutlined ? Colors.transparent : AppColors.primary);
    final effectiveTextColor = textColor ?? 
        (isOutlined ? AppColors.primary : AppColors.white);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    Widget buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: SpinKitThreeBounce(
              color: effectiveTextColor,
              size: 10,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: effectiveTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        width: fullWidth ? double.infinity : width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: effectiveBackgroundColor,
            foregroundColor: effectiveTextColor,
            side: BorderSide(
              color: onPressed != null ? AppColors.primary : AppColors.grey300,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: effectiveBorderRadius,
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: effectiveBorderRadius,
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: buttonChild,
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.grey100;
    final effectiveIconColor = iconColor ?? AppColors.textPrimary;

    Widget button = Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: effectiveIconColor,
          size: size,
        ),
        padding: EdgeInsets.zero,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;

  const CustomFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: iconColor ?? AppColors.white,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
