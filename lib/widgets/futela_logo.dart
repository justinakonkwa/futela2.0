import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FutelaLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const FutelaLogo({
    super.key,
    this.size = 80,
    this.showShadow = true,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(size * 0.25),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.1),
                  blurRadius: size * 0.125,
                  offset: Offset(0, size * 0.05),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(size * 0.25),
        child: Image.asset(
          'assets/icons/icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class FutelaLogoWithBadge extends StatelessWidget {
  final double size;
  final IconData badgeIcon;
  final Color badgeColor;
  final bool showShadow;

  const FutelaLogoWithBadge({
    super.key,
    this.size = 80,
    this.badgeIcon = Icons.verified,
    this.badgeColor = AppColors.success,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutelaLogo(
          size: size,
          showShadow: showShadow,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(size * 0.2),
              border: Border.all(
                color: AppColors.white,
                width: 3,
              ),
            ),
            child: Icon(
              badgeIcon,
              size: size * 0.2,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class FutelaLogoWithText extends StatelessWidget {
  final double logoSize;
  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final MainAxisAlignment alignment;
  final bool showShadow;

  const FutelaLogoWithText({
    super.key,
    this.logoSize = 60,
    this.title = 'Futela',
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.alignment = MainAxisAlignment.center,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: alignment,
      children: [
        FutelaLogo(
          size: logoSize,
          showShadow: showShadow,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: titleStyle ??
              Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: subtitleStyle ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
          ),
        ],
      ],
    );
  }
}
