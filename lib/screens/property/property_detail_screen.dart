import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/property_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../visits/request_visit_screen.dart';
import 'add_property_screen.dart';
import '../../providers/favorite_provider.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;
  final bool myProperty;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
    this.myProperty = false,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadProperty();
  }

  void _loadProperty() {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    if (widget.myProperty) {
      propertyProvider.getMyPropertyById(widget.propertyId);
    } else {
      propertyProvider.getPropertyById(widget.propertyId);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<PropertyProvider>(
        builder: (context, propertyProvider, child) {
          final property = propertyProvider.properties
              .where((p) => p.id == widget.propertyId)
              .firstOrNull;

          if (property == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar avec image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.white,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  if (!widget.myProperty) Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Consumer<FavoriteProvider>(
                      builder: (context, favoriteProvider, child) {
                        final isFavorite = favoriteProvider.isFavorite(widget.propertyId);
                        return IconButton(
                          icon: favoriteProvider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                )
                              : Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? AppColors.error : AppColors.textPrimary,
                                ),
                          onPressed: favoriteProvider.isLoading
                              ? null
                              : () async {
                                  try {
                                    await favoriteProvider.toggleFavorite(widget.propertyId);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            favoriteProvider.isFavorite(widget.propertyId)
                                                ? 'Ajouté aux favoris'
                                                : 'Retiré des favoris',
                                          ),
                                          backgroundColor: favoriteProvider.isFavorite(widget.propertyId)
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Erreur: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                        );
                      },
                    ),
                  ),
                  if (!widget.myProperty) Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: AppColors.textPrimary),
                      onPressed: () {
                        // TODO: Implémenter le partage
                      },
                    ),
                  ),
                  if (widget.myProperty) Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.textPrimary),
                      tooltip: 'Modifier',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddPropertyScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  if (widget.myProperty) Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      tooltip: 'Supprimer',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Supprimer l\'annonce'),
                            content: const Text('Voulez-vous vraiment supprimer cette annonce ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await Provider.of<PropertyProvider>(context, listen: false)
                                .deleteProperty(widget.propertyId);
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Annonce supprimée'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Builder(
                    builder: (context) {
                      final List<String> imageUrls = [
                        if (property.cover != null && property.cover!.startsWith('http')) property.cover!,
                        ...[property.images].whereType<List<String>>()
                            .expand((e) => e)
                            .where((u) => u.startsWith('http'))
                            .toList(),
                      ];

                      if (imageUrls.isEmpty) {
                        return Container(
                          color: AppColors.grey100,
                          child: const Icon(
                            Icons.home_work,
                            size: 64,
                            color: AppColors.textTertiary,
                          ),
                        );
                      }

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (i) => setState(() => _currentPage = i),
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
                                    size: 64,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.photo_library, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_currentPage + 1}/${imageUrls.length}',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Contenu principal
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header avec prix et type
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    property.formattedPrice,
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: property.type == 'for-rent' 
                                        ? AppColors.primary 
                                        : AppColors.secondary,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    property.typeDisplayName,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              property.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
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
                                    property.address,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Consumer<LocationProvider>(
                                  builder: (context, locationProvider, child) {
                                    final distance = locationProvider.calculateDistanceToProperty(property);
                                    if (distance != null) {
                                      return Text(
                                        locationProvider.formatDistance(distance),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Détails de la propriété
                      if (property.apartment != null || property.house != null)
                        _buildPropertyDetails(context, property),

                      // Description
                      if (property.description.isNotEmpty)
                        _buildDescription(context, property),

                      // Équipements
                      if (property.apartment != null || property.house != null)
                        _buildAmenities(context, property),

                      // Informations sur le propriétaire
                      _buildOwnerInfo(context, property),

                      const SizedBox(height: 100), // Espace pour le bouton fixe
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Contacter',
                  isOutlined: true,
                  onPressed: () {
                    // TODO: Implémenter le contact
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Demander une visite',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RequestVisitScreen(
                          propertyId: widget.propertyId,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyDetails(BuildContext context, property) {
    final details = property.apartment ?? property.house;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDetailItem(context, Icons.bed_outlined, '${details.beds} chambres'),
              const SizedBox(width: 24),
              _buildDetailItem(context, Icons.bathtub_outlined, '${details.baths} SDB'),
              const SizedBox(width: 24),
              _buildDetailItem(context, Icons.square_foot, '${details.area.toInt()} m²'),
            ],
          ),
          if (property.apartment != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDetailItem(context, Icons.stairs, 'Étage ${property.apartment.floor}'),
                if (property.apartment.isFurnished) ...[
                  const SizedBox(width: 24),
                  _buildDetailItem(context, Icons.chair, 'Meublé'),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, property) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            property.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities(BuildContext context, property) {
    final details = property.apartment ?? property.house;
    final amenities = <String, bool>{
      'Cuisine': details.kitchen,
      'Cuisine équipée': details.equippedKitchen,
      'Piscine': details.pool,
      'Parking': details.parking,
      'Lave-linge': details.laundry,
      'Climatisation': details.airConditioning,
      'Cheminée': details.chimney,
      'Chauffage': details.heating,
      'Barbecue': details.barbecue,
    };

    if (property.apartment != null) {
      amenities.addAll({
        'Balcon': property.apartment.balcony,
        'Animaux autorisés': property.apartment.catsAllowed || property.apartment.dogsAllowed,
      });
    }

    final availableAmenities = amenities.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (availableAmenities.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Équipements',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableAmenities.map((amenity) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      amenity,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfo(BuildContext context, property) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primary,
            backgroundImage: property.owner.profilePictureFilePath != null
                ? NetworkImage(property.owner.profilePictureFilePath!)
                : null,
            child: property.owner.profilePictureFilePath == null
                ? Text(
                    property.owner.firstName.isNotEmpty
                        ? property.owner.firstName[0].toUpperCase()
                        : 'U',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Propriétaire',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  property.owner.fullName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (property.owner.isIdVerified)
            Container(
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
        ],
      ),
    );
  }
}
