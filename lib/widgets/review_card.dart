import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review/property_review.dart';
import '../utils/app_colors.dart';

class ReviewCard extends StatelessWidget {
  final PropertyReview review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec avatar et nom
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                backgroundImage: review.userAvatar != null
                    ? NetworkImage(review.userAvatar!)
                    : null,
                child: review.userAvatar == null
                    ? Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      df.format(review.createdAt),
                      style: const TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.warning, Color(0xFFFFA726)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 13, color: AppColors.white),
                    const SizedBox(width: 3),
                    Text(
                      review.rating.toString(),
                      style: const TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            if (review.title != null && review.title!.isNotEmpty) ...[
              Text(
                review.title!,
                style: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              review.comment!,
              style: const TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ] else if (review.title != null && review.title!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.title!,
              style: const TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],

          if (review.wouldRecommend) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up_rounded, size: 12, color: AppColors.info),
                  SizedBox(width: 5),
                  Text(
                    'Recommande cette propriété',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
