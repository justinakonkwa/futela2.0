import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/property.dart';
import '../utils/app_colors.dart';
import '../providers/location_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final distance = locationProvider.calculateDistanceToProperty(widget.property);
        final List<String> imageUrls = [
          if (widget.property.cover != null) widget.property.cover!,
          ...?widget.property.images,
        ];
        
        return Card(
          elevation: 2,
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
                                    placeholder: (context, _) => Container(
                                      color: AppColors.grey100,
                                      child: const Center(child: CircularProgressIndicator()),
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
                    
                    // Badge de type
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.property.type == 'for-rent' 
                              ? AppColors.primary 
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.property.typeDisplayName,
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
                        child: GestureDetector(
                          onTap: widget.onFavorite,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              size: 20,
                              color: AppColors.textPrimary,
                            ),
                          ),
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
                      // Prix
                      Row(
                        children: [
                          Text(
                            widget.property.formattedPrice,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (widget.property.type == 'for-rent') ...[
                            Text(
                              '/mois',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Titre
                      Text(
                        widget.property.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Adresse
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.property.address,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Détails de la propriété
                      Row(
                        children: [
                          // Chambres
                          if (widget.property.apartment != null) ...[
                            _buildDetailChip(
                              context,
                              Icons.bed_outlined,
                              '${widget.property.apartment!.beds} ch.',
                            ),
                            const SizedBox(width: 8),
                          ] else if (widget.property.house != null) ...[
                            _buildDetailChip(
                              context,
                              Icons.bed_outlined,
                              '${widget.property.house!.beds} ch.',
                            ),
                            const SizedBox(width: 8),
                          ],
                          
                          // Salles de bain
                          if (widget.property.apartment != null) ...[
                            _buildDetailChip(
                              context,
                              Icons.bathtub_outlined,
                              '${widget.property.apartment!.baths} SDB',
                            ),
                            const SizedBox(width: 8),
                          ] else if (widget.property.house != null) ...[
                            _buildDetailChip(
                              context,
                              Icons.bathtub_outlined,
                              '${widget.property.house!.baths} SDB',
                            ),
                            const SizedBox(width: 8),
                          ],
                          
                          // Surface
                          if (widget.property.apartment != null) ...[
                            _buildDetailChip(
                              context,
                              Icons.square_foot,
                              '${widget.property.apartment!.area.toInt()} m²',
                            ),
                          ] else if (widget.property.house != null) ...[
                            _buildDetailChip(
                              context,
                              Icons.square_foot,
                              '${widget.property.house!.area.toInt()} m²',
                            ),
                          ],
                          
                          const Spacer(),
                          
                          // Distance
                          if (distance != null)
                            Text(
                              locationProvider.formatDistance(distance),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
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

  Widget _buildDetailChip(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
