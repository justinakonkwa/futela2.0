import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../screens/search/search_screen.dart';
import '../utils/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final String? initialQuery;
  final VoidCallback? onTap;

  const SearchBarWidget({
    super.key,
    this.initialQuery,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SearchScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.search,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  initialQuery ?? 'Rechercher une propriété...',
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: initialQuery != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.tune_rounded,
                color: AppColors.textTertiary.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
