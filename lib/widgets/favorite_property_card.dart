import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/property.dart';
import '../utils/app_colors.dart';

class FavoritePropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onRemoveFavorite;

  const FavoritePropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = _buildImageUrls(property);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container
        (
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image à gauche
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 120,
                height: 110,
                child: imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (context, _) => Container(
                          color: AppColors.grey100,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, _, __) => Container(
                          color: AppColors.grey100,
                          child: const Icon(
                            Icons.home_work,
                            size: 36,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.grey100,
                        child: const Icon(
                          Icons.home_work,
                          size: 36,
                          color: AppColors.textTertiary,
                        ),
                      ),
              ),
            ),

            // Contenu à droite
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ligne titre + bouton supprimer favori
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            property.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onRemoveFavorite,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.favorite, color: Colors.red, size: 20),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Adresse
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.fullAddress,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Prix + type
                    Row(
                      children: [
                        Text(
                          property.formattedPrice,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (property.type == 'for-rent') ...[
                          Text(
                            '/mois',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const Spacer(),
                        _TypeBadge(type: property.type, isValidated: property.isValidated),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _buildImageUrls(Property property) {
    final List<String> urls = [];
    if (property.cover != null && _isValidUrl(property.cover!)) {
      urls.add(property.cover!);
    }
    if (property.images != null) {
      urls.addAll(property.images!.where(_isValidUrl));
    }
    return urls;
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    if (url.toLowerCase() == 'default.png') return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }
}

class _TypeBadge extends StatelessWidget {
  final String type; // 'for-rent' | 'for-sale'
  final bool isValidated;

  const _TypeBadge({
    required this.type,
    required this.isValidated,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = type == 'for-rent' ? AppColors.primary : AppColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isValidated) ...[
            const Icon(Icons.verified, size: 14, color: AppColors.success),
            const SizedBox(width: 4),
          ],
          Text(
            type == 'for-rent' ? 'À louer' : 'À vendre',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: bg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


