import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../screens/search/search_screen.dart';

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
    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search,
              color: AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                initialQuery ?? 'Rechercher une propriété...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: initialQuery != null 
                      ? AppColors.textPrimary 
                      : AppColors.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
