import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/property.dart';
import '../utils/app_colors.dart';
import '../providers/location_provider.dart';
import '../providers/favorite_provider.dart';
import 'package:provider/provider.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool showFavorite;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.onFavorite,
    this.showFavorite = true,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    // Check if it's a valid URL (starts with http/https) or a valid relative path
    return url.startsWith('http://') || 
           url.startsWith('https://') || 
           url.startsWith('/') ||
           url.contains('.') && !url.startsWith('default');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final distance = locationProvider.calculateDistanceToProperty(widget.property);
        final List<String> imageUrls = [
          if (widget.property.cover != null && _isValidImageUrl(widget.property.cover!)) 
            widget.property.cover!,
          ...widget.property.images.where((url) => _isValidImageUrl(url)),
        ];
        
        return Card(
          elevation: 2,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image de couverture
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: imageUrls.isNotEmpty
                            ? PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) => setState(() => _currentPage = index),
                                itemCount: imageUrls.length,
                                itemBuilder: (context, index) {
                                  final url = imageUrls[index];
                                  return CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    placeholder: (context, _) => Shimmer.fromColors(
                                      baseColor: AppColors.grey200,
                                      highlightColor: AppColors.grey100,
                                      child: Container(color: AppColors.grey200),
                                    ),
                                    errorWidget: (context, _, __) => Container(
                                      color: AppColors.grey100,
                                      child: const Icon(
                                        Icons.home_work,
                                        size: 48,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: AppColors.grey100,
                                child: const Icon(
                                  Icons.home_work,
                                  size: 48,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                      ),
                    ),
                    
                    // Badge : listingType (à louer / à vendre) ou type de bien
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.property.listingBadgeUseRentColors
                              ? AppColors.primary
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.property.listingBadgeLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    // Badge de validation
                    if (widget.property.isValidated)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    
                    // Bouton favori
                    if (widget.showFavorite)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Consumer<FavoriteProvider>(
                          builder: (context, favoriteProvider, child) {
                            final isFavorite = favoriteProvider.isFavorite(widget.property.id);
                            return GestureDetector(
                              onTap: widget.onFavorite,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  size: 20,
                                  color: isFavorite ? Colors.red : AppColors.textPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Compteur de photos
                    if (imageUrls.length > 1)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.photo_library, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                '${_currentPage + 1}/${imageUrls.length}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Contenu de la carte
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom et prix sur une ligne
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              widget.property.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.property.formattedPrice,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (widget.property.type == 'for-rent')
                                Text(
                                  '/mois',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Note moyenne et nombre d'avis
                      if (widget.property.reviewCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.property.rating?.toStringAsFixed(1) ?? '0.0'}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${widget.property.reviewCount} avis)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Adresse
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.property.fullAddress,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Caractéristiques selon la catégorie / type
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: _buildDetailChipsForType(context, widget.property),
                            ),
                          ),
                          if (distance != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              locationProvider.formatDistance(distance),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDetailChipsForType(BuildContext context, Property p) {
    final chips = <Widget>[];

    switch (p.type) {
      case 'apartment':
        if (p.bedrooms != null && p.bedrooms! > 0) {
          chips.add(_buildDetailChip(context, Icons.bed_outlined, '${p.bedrooms} ch.'));
        }
        if (p.bathrooms != null && p.bathrooms! > 0) {
          chips.add(_buildDetailChip(context, Icons.bathtub_outlined, '${p.bathrooms} SDB'));
        }
        if (p.squareMeters != null) {
          chips.add(_buildDetailChip(context, Icons.square_foot, '${p.squareMeters!.toInt()} m²'));
        }
        break;
      case 'house':
        if (p.bedrooms != null && p.bedrooms! > 0) {
          chips.add(_buildDetailChip(context, Icons.bed_outlined, '${p.bedrooms} ch.'));
        }
        if (p.bathrooms != null && p.bathrooms! > 0) {
          chips.add(_buildDetailChip(context, Icons.bathtub_outlined, '${p.bathrooms} SDB'));
        }
        if (p.houseSquareMeters != null) {
          chips.add(_buildDetailChip(context, Icons.home, '${p.houseSquareMeters!.toInt()} m²'));
        } else if (p.squareMeters != null) {
          chips.add(_buildDetailChip(context, Icons.square_foot, '${p.squareMeters!.toInt()} m²'));
        }
        if (p.landSquareMeters != null) {
          chips.add(_buildDetailChip(context, Icons.landscape, '${p.landSquareMeters!.toInt()} m² terr.'));
        }
        break;
      case 'land':
        if (p.squareMeters != null) {
          chips.add(_buildDetailChip(context, Icons.square_foot, '${p.squareMeters!.toInt()} m²'));
        }
        if (p.landType != null && p.landType!.isNotEmpty) {
          final label = p.landType == 'residential' ? 'Résid.' : p.landType == 'commercial' ? 'Comm.' : p.landType == 'agricultural' ? 'Agric.' : 'Ind.';
          chips.add(_buildDetailChip(context, Icons.landscape, label));
        }
        break;
      case 'event_hall':
        if (p.capacity != null) {
          chips.add(_buildDetailChip(context, Icons.groups, '${p.capacity} pers.'));
        }
        if (p.hasParking) {
          chips.add(_buildDetailChip(context, Icons.local_parking, 'Parking'));
        }
        break;
      case 'car':
        if (p.brand != null || p.model != null) {
          chips.add(_buildDetailChip(
            context,
            Icons.directions_car,
            [p.brand, p.model].where((e) => e != null && e.isNotEmpty).join(' '),
          ));
        }
        if (p.seats != null) {
          chips.add(_buildDetailChip(context, Icons.event_seat, '${p.seats} pl.'));
        }
        if (p.year != null) {
          chips.add(_buildDetailChip(context, Icons.calendar_today, '${p.year}'));
        }
        break;
      default:
        // Fallback: chambres, SDB, m² si présents
        if (p.bedrooms != null && p.bedrooms! > 0) {
          chips.add(_buildDetailChip(context, Icons.bed_outlined, '${p.bedrooms} ch.'));
        }
        if (p.bathrooms != null && p.bathrooms! > 0) {
          chips.add(_buildDetailChip(context, Icons.bathtub_outlined, '${p.bathrooms} SDB'));
        }
        if (p.squareMeters != null) {
          chips.add(_buildDetailChip(context, Icons.square_foot, '${p.squareMeters!.toInt()} m²'));
        }
    }

    return chips;
  }

  Widget _buildDetailChip(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
