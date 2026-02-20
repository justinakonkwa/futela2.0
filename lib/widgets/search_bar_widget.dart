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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.grey200, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.search,
                color: AppColors.textTertiary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  initialQuery ?? 'Rechercher une propriété...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: initialQuery != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
