import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/property.dart';
import '../../providers/property_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/role_permissions.dart';
import '../../utils/auth_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/address_display.dart';
import '../../widgets/property_share_widget.dart';
import '../../widgets/property_card_shimmer.dart';
import '../../widgets/image_gallery_viewer.dart';
import '../visits/request_visit_screen.dart';
import 'add_property_screen.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/review_provider.dart';
import '../property/property_reviews_screen.dart';

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
  List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Différer le chargement après le build pour éviter setState() pendant build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProperty();
    });
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<PropertyProvider>(
        builder: (context, propertyProvider, child) {
          final property = widget.myProperty 
              ? propertyProvider.myProperties
                  .where((p) => p.id == widget.propertyId)
                  .firstOrNull
              : propertyProvider.properties
                  .where((p) => p.id == widget.propertyId)
                  .firstOrNull;

          if (property == null) {
            if (propertyProvider.isLoading) {
              return const PropertyDetailShimmer();
            } else if (propertyProvider.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Erreur de chargement',
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        propertyProvider.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryDark,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _loadProperty(),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                              child:const  Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.refresh_rounded,
                                    color: AppColors.white,
                                    size: 22,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Réessayer',
                                    style: TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.15),
                              AppColors.primaryLight.withOpacity(0.08),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.home_work_outlined,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Propriété non trouvée',
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }

          return CustomScrollView(
            slivers: [
              // App Bar avec image moderne
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(14),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (!widget.myProperty) Container(
                    margin: const EdgeInsets.all(8),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Consumer<FavoriteProvider>(
                      builder: (context, favoriteProvider, child) {
                        final isFavorite = favoriteProvider.isFavorite(widget.propertyId);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: favoriteProvider.isLoading
                                ? null
                                : () async {
                                    if (!AuthHelper.requireAuth(
                                      context,
                                      message: 'Connectez-vous pour ajouter des propriétés à vos favoris',
                                    )) {
                                      return;
                                    }
                                    
                                    try {
                                      await favoriteProvider.toggleFavorite(widget.propertyId);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  isFavorite ? Icons.favorite_border : Icons.favorite,
                                                  color: AppColors.white,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  favoriteProvider.isFavorite(widget.propertyId)
                                                      ? 'Ajouté aux favoris'
                                                      : 'Retiré des favoris',
                                                  style: const TextStyle(
                                                    fontFamily: 'Gilroy',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: favoriteProvider.isFavorite(widget.propertyId)
                                                ? AppColors.success
                                                : AppColors.warning,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(Icons.error_outline, color: AppColors.white, size: 20),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    'Erreur: $e',
                                                    style: const TextStyle(
                                                      fontFamily: 'Gilroy',
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: AppColors.error,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            borderRadius: BorderRadius.circular(14),
                            child: Center(
                              child: favoriteProvider.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      ),
                                    )
                                  : Icon(
                                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: isFavorite ? AppColors.error : AppColors.textPrimary,
                                      size: 24,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (!widget.myProperty) Container(
                    margin: const EdgeInsets.all(8),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showShareDialog(context, property);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: const Center(
                          child: Icon(
                            Icons.share_rounded,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final canEdit = widget.myProperty && authProvider.user != null;
                      
                      if (!canEdit) return const SizedBox.shrink();
                      
                      return Container(
                        margin: const EdgeInsets.all(8),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddPropertyScreen(
                                    propertyId: widget.propertyId,
                                    isEditMode: true,
                                    myProperty: widget.myProperty,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: const Center(
                              child: Icon(
                                Icons.edit_rounded,
                                color: AppColors.textPrimary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final canDelete = widget.myProperty && 
                          authProvider.user != null && 
                          RolePermissions.canAddProperties(authProvider.user!);
                      
                      if (!canDelete) return const SizedBox.shrink();
                      
                      return Container(
                        margin: const EdgeInsets.all(8),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: AppColors.error,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text('Supprimer l\'annonce'),
                                    ],
                                  ),
                                  content: const Text(
                                    'Voulez-vous vraiment supprimer cette annonce ?',
                                    style: TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontSize: 15,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text(
                                        'Annuler',
                                        style: TextStyle(
                                          fontFamily: 'Gilroy',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                        foregroundColor: AppColors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Supprimer',
                                        style: TextStyle(
                                          fontFamily: 'Gilroy',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
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
                                      SnackBar(
                                        content: Row(
                                          children: const [
                                            Icon(Icons.check_circle, color: AppColors.white, size: 20),
                                            SizedBox(width: 12),
                                            Text(
                                              'Annonce supprimée',
                                              style: TextStyle(
                                                fontFamily: 'Gilroy',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.error_outline, color: AppColors.white, size: 20),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Erreur: $e',
                                                style: const TextStyle(
                                                  fontFamily: 'Gilroy',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: const Center(
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Builder(
                    builder: (context) {
                      _imageUrls = _buildImageUrls(property);

                      if (_imageUrls.isEmpty) {
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
                            itemCount: _imageUrls.length,
                            itemBuilder: (context, index) {
                              final url = _imageUrls[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ImageGalleryViewer(
                                        imageUrls: _imageUrls,
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: 'property_image_$index',
                                  child: CachedNetworkImage(
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
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Indicateur de position
                          Positioned(
                            
                            left: 12,
                            bottom: MediaQuery.of(context).size.height * 0.25,
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
                                    '${_currentPage + 1}/${_imageUrls.length}',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Bandeau défilant : miniatures en cartes (sélectionnée vs non sélectionnée)
                          if (_imageUrls.length > 1)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 88,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.75),
                                    ],
                                  ),
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  itemCount: _imageUrls.length,
                                  itemBuilder: (context, index) {
                                    final isSelected = index == _currentPage;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() => _currentPage = index);
                                        _pageController.animateToPage(
                                          index,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 64,
                                        height: 64,
                                        margin: const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected ? Colors.white : Colors.white24,
                                            width: isSelected ? 3 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.4),
                                              blurRadius: isSelected ? 8 : 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: _imageUrls[index],
                                                fit: BoxFit.cover,
                                                placeholder: (context, _) => Container(
                                                  color: AppColors.grey200,
                                                  child: const Center(
                                                    child: SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                errorWidget: (context, _, __) => Container(
                                                  color: AppColors.grey200,
                                                  child: const Icon(
                                                    Icons.image,
                                                    size: 28,
                                                    color: Colors.white54,
                                                  ),
                                                ),
                                              ),
                                              if (!isSelected)
                                                Container(
                                                  color: Colors.black.withOpacity(0.25),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header avec prix et type
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            property.pricePerDay != null
                                                ? '\$${property.pricePerDay!.toStringAsFixed(0)}'
                                                : property.pricePerMonth != null
                                                    ? '\$${property.pricePerMonth!.toStringAsFixed(0)}'
                                                    : '\$0',
                                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (property.pricePerDay != null)
                                            Text(
                                              '/jour',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            )
                                          else if (property.pricePerMonth != null)
                                            Text(
                                              '/mois',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          if (property.pricePerDay != null && property.pricePerMonth != null)
                                            Text(
                                              '(\$${property.pricePerMonth!.toStringAsFixed(0)}/mois)',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppColors.textTertiary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: property.listingBadgeUseRentColors
                                        ? AppColors.primary
                                        : AppColors.secondary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    property.listingBadgeLabel,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Text(
                              property.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AddressDisplay(
                                    property: property,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Consumer<LocationProvider>(
                                  builder: (context, locationProvider, child) {
                                    final distance = locationProvider.calculateDistanceToProperty(property);
                                    if (distance != null) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.grey100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          locationProvider.formatDistance(distance),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.textTertiary,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                      _buildPropertyDetails(context, property),

                      // Section Avis
                      _buildReviewsSection(context, property),

                      // Description
                      if (property.description.isNotEmpty)
                        _buildDescription(context, property),

                      // Équipements
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
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bouton Demander visite en pleine largeur
              CustomButton(
                width: double.maxFinite,
                text: 'Demander visite',
                onPressed: () {
                  // Vérifier l'authentification avant de permettre la demande de visite
                  if (AuthHelper.requireAuth(
                    context,
                    message: 'Connectez-vous pour demander une visite',
                  )) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RequestVisitScreen(
                          propertyId: widget.propertyId,
                        ),
                      ),
                    );
                  }
                },
              ),
              
              // Bouton Contacter commenté
              // Row(
              //   children: [
              //     Expanded(
              //       child: CustomButton(
              //         text: 'Contacter',
              //         icon: Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.primary),
              //         isOutlined: true,
              //         onPressed: () => _onContactPressed(context),
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: CustomButton(
              //         text: 'Demander visite',
              //         onPressed: () {
              //           // Vérifier l'authentification avant de permettre la demande de visite
              //           if (AuthHelper.requireAuth(
              //             context,
              //             message: 'Connectez-vous pour demander une visite',
              //           )) {
              //             Navigator.of(context).push(
              //               MaterialPageRoute(
              //                 builder: (context) => RequestVisitScreen(
              //                   propertyId: widget.propertyId,
              //                 ),
              //               ),
              //             );
              //           }
              //         },
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Méthodes de contact commentées (bouton Contacter désactivé)
  // void _onContactPressed(BuildContext context) {
  //   final auth = context.read<AuthProvider>();
  //   final messaging = context.read<MessagingProvider>();
  //   if (auth.user != null) {
  //     _startConversationAsUser(context, messaging, auth.user!.id);
  //   } else {
  //     _showContactOwnerSheet(context, messaging);
  //   }
  // }

  // Future<void> _startConversationAsUser(
  //   BuildContext context,
  //   MessagingProvider messaging,
  //   String userId,
  // ) async {
  //   final conversation = await messaging.startConversationOnProperty(
  //     widget.propertyId,
  //     message: null,
  //   );
  //   if (!context.mounted) return;
  //   if (conversation != null) {
  //     messaging.setCurrentConversation(conversation);
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (context) => ChatScreen(
  //           conversationId: conversation.id,
  //           conversation: conversation,
  //         ),
  //       ),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           messaging.error ?? 'Impossible de démarrer la conversation',
  //         ),
  //         backgroundColor: AppColors.error,
  //       ),
  //     );
  //   }
  // }

  // void _showContactOwnerSheet(BuildContext context, MessagingProvider messaging) {
  //   final nameController = TextEditingController();
  //   final emailController = TextEditingController();
  //   final phoneController = TextEditingController();
  //   final messageController = TextEditingController();

  //   showModalBottomSheet<void>(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Padding(
  //       padding: EdgeInsets.only(
  //         bottom: MediaQuery.of(context).viewInsets.bottom,
  //       ),
  //       child: Container(
  //         padding: const EdgeInsets.all(24),
  //         decoration: BoxDecoration(
  //           color: Theme.of(context).scaffoldBackgroundColor,
  //           borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  //         ),
  //         child: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.stretch,
  //             children: [
  //               Text(
  //                 'Contacter le propriétaire',
  //                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //                   fontWeight: FontWeight.w700,
  //                 ),
  //               ),
  //               const SizedBox(height: 16),
  //               CustomTextField(
  //                 controller: nameController,
  //                 label: 'Nom',
  //                 hint: 'Votre nom',
  //                 prefixIconData: Icons.person_outline,
  //               ),
  //               const SizedBox(height: 12),
  //               CustomTextField(
  //                 controller: emailController,
  //                 label: 'Email',
  //                 hint: 'votre@email.com',
  //                 keyboardType: TextInputType.emailAddress,
  //                 prefixIconData: Icons.email_outlined,
  //               ),
  //               const SizedBox(height: 12),
  //               CustomTextField(
  //                 controller: phoneController,
  //                 label: 'Téléphone (optionnel)',
  //                 hint: '+243...',
  //                 keyboardType: TextInputType.phone,
  //                 prefixIconData: Icons.phone_outlined,
  //               ),
  //               const SizedBox(height: 12),
  //               CustomTextField(
  //                 controller: messageController,
  //                 label: 'Message',
  //                 hint: 'Votre message au propriétaire',
  //                 maxLines: 3,
  //                 prefixIconData: Icons.message_outlined,
  //               ),
  //               const SizedBox(height: 24),
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: CustomButton(
  //                       text: 'Annuler',
  //                       isOutlined: true,
  //                       onPressed: () => Navigator.of(context).pop(),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 12),
  //                   Expanded(
  //                     child: CustomButton(
  //                       text: 'Envoyer',
  //                       onPressed: () async {
  //                         final name = nameController.text.trim();
  //                         final email = emailController.text.trim();
  //                         final message = messageController.text.trim();
  //                         final phone = phoneController.text.trim();
  //                         if (name.isEmpty || email.isEmpty || message.isEmpty) {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             const SnackBar(
  //                               content: Text(
  //                                   'Veuillez remplir le nom, l\'email et le message'),
  //                               backgroundColor: AppColors.error,
  //                             ),
  //                           );
  //                           return;
  //                         }
  //                         final ok = await messaging.contactOwner(
  //                           widget.propertyId,
  //                           name: name,
  //                           email: email,
  //                           message: message,
  //                           phone: phone.isEmpty ? null : phone,
  //                         );
  //                         if (!context.mounted) return;
  //                         Navigator.of(context).pop();
  //                         if (ok) {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             const SnackBar(
  //                               content: Text(
  //                                   'Votre message a été envoyé au propriétaire'),
  //                               backgroundColor: AppColors.success,
  //                             ),
  //                           );
  //                         } else {
  //                           ScaffoldMessenger.of(context).showSnackBar(
  //                             SnackBar(
  //                               content: Text(
  //                                   messaging.error ??
  //                                       'Erreur lors de l\'envoi'),
  //                               backgroundColor: AppColors.error,
  //                             ),
  //                           );
  //                         }
  //                       },
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPropertyDetails(BuildContext context, Property property) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Caractéristiques',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Caractéristiques selon le type : Appartement
          if (property.type == 'apartment') ...[
            Row(
              children: [
                if (property.bedrooms != null)
                  Expanded(
                    child: _buildDetailCard(
                      context, Icons.bed_outlined, '${property.bedrooms}',
                      'Chambre${property.bedrooms! > 1 ? 's' : ''}', AppColors.primary,
                    ),
                  ),
                if (property.bedrooms != null && property.bathrooms != null) const SizedBox(width: 12),
                if (property.bathrooms != null)
                  Expanded(
                    child: _buildDetailCard(
                      context, Icons.bathtub_outlined, '${property.bathrooms}', 'SDB', AppColors.secondary,
                    ),
                  ),
                if (property.squareMeters != null) ...[
                  if (property.bedrooms != null || property.bathrooms != null) const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(
                      context, Icons.square_foot, '${property.squareMeters!.toInt()}', 'm²', AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
            if (property.floor != null || (property.isFurnished == true)) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (property.floor != null)
                    Expanded(
                      child: _buildDetailCard(
                        context, Icons.stairs, '${property.floor}', 'Étage', AppColors.warning,
                      ),
                    ),
                  if (property.floor != null && property.hasElevator) const SizedBox(width: 12),
                  if (property.hasElevator)
                    Expanded(
                      child: _buildDetailCard(context, Icons.elevator, '', 'Ascenseur', AppColors.info),
                    ),
                  if (property.hasBalcony) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailCard(context, Icons.balcony, '', 'Balcon', AppColors.info),
                    ),
                  ],
                  if (property.isFurnished == true) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailCard(context, Icons.chair, '', 'Meublé', AppColors.info),
                    ),
                  ],
                ],
              ),
            ],
          ],
          
          // Caractéristiques selon le type : Maison (différent de l'appartement)
          if (property.type == 'house') ...[
            Row(
              children: [
                if (property.bedrooms != null)
                  Expanded(
                    child: _buildDetailCard(
                      context, Icons.bed_outlined, '${property.bedrooms}',
                      'Chambre${property.bedrooms! > 1 ? 's' : ''}', AppColors.primary,
                    ),
                  ),
                if (property.bedrooms != null && property.bathrooms != null) const SizedBox(width: 12),
                if (property.bathrooms != null)
                  Expanded(
                    child: _buildDetailCard(
                      context, Icons.bathtub_outlined, '${property.bathrooms}', 'SDB', AppColors.secondary,
                    ),
                  ),
                if (property.floors != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(
                      context, Icons.stairs, '${property.floors}',
                      'Étage${property.floors! > 1 ? 's' : ''}', AppColors.warning,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (property.houseSquareMeters != null)
                  Expanded(
                    child: _buildDetailCard(
                      context, Icons.home, '${property.houseSquareMeters!.toInt()}', 'm² habitable', AppColors.info,
                    ),
                  ),
                if (property.houseSquareMeters != null && property.landSquareMeters != null) const SizedBox(width: 12),
                if (property.landSquareMeters != null)
                  Expanded(
                    child: _buildDetailCard(
                      context, Icons.landscape, '${property.landSquareMeters!.toInt()}', 'm² terrain', AppColors.success,
                    ),
                  ),
                if (property.isFurnished == true) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(context, Icons.chair, '', 'Meublé', AppColors.info),
                  ),
                ],
              ],
            ),
          ],
          
          // Caractéristiques selon le type : Terrain / Parcelle
          if (property.type == 'land') ...[
            Row(
              children: [
                if (property.squareMeters != null)
                  Expanded(
                    child: _buildDetailCard(
                      context, Icons.square_foot, '${property.squareMeters!.toInt()}', 'm²', AppColors.success,
                    ),
                  ),
                if (property.landType != null && property.landType!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(
                      context, Icons.landscape,
                      property.landType == 'residential' ? 'Résidentiel' : property.landType == 'commercial' ? 'Commercial' : property.landType == 'agricultural' ? 'Agricole' : 'Industriel',
                      'Type', AppColors.info,
                    ),
                  ),
                ],
              ],
            ),
          ],
          
          // Caractéristiques selon le type : Véhicule
          if (property.type == 'car') ...[
            Row(
              children: [
                if (property.brand != null)
                  Expanded(
                    child: _buildDetailCard(context, Icons.directions_car, property.brand!, 'Marque', AppColors.primary),
                  ),
                if (property.brand != null && property.model != null) const SizedBox(width: 12),
                if (property.model != null)
                  Expanded(
                    child: _buildDetailCard(
                      context,
                      Icons.car_repair,
                      property.model!.trim().isEmpty ? '—' : property.model!,
                      'Modèle',
                      AppColors.secondary,
                    ),
                  ),
                if (property.year != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(context, Icons.calendar_today, '${property.year}', 'Année', AppColors.warning),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (property.seats != null)
                  Expanded(
                    child: _buildDetailCard(context, Icons.event_seat, '${property.seats}', 'Places', AppColors.info),
                  ),
                if (property.seats != null && property.fuelType != null) const SizedBox(width: 12),
                if (property.fuelType != null)
                  Expanded(
                    child: _buildDetailCard(
                      context,
                      Icons.local_gas_station,
                      property.fuelType == 'diesel'
                          ? 'Diesel'
                          : property.fuelType == 'gasoline'
                              ? 'Essence'
                              : property.fuelType == 'electric'
                                  ? 'Électrique'
                                  : property.fuelType == 'plugin_hybrid'
                                      ? 'Hybride rechargeable'
                                      : 'Hybride',
                      'Carburant',
                      AppColors.success,
                    ),
                  ),
                if (property.transmission != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(
                      context, Icons.settings,
                      property.transmission == 'automatic' ? 'Auto' : 'Manuelle',
                      'Transmission', AppColors.textTertiary,
                    ),
                  ),
                ],
                if (property.mileage != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(context, Icons.speed, '${_formatNumber(property.mileage)} km', 'Kilométrage', AppColors.textTertiary),
                  ),
                ],
              ],
            ),
            if (property.color != null || property.withDriver == true) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (property.color != null)
                    Expanded(
                      child: _buildDetailCard(context, Icons.palette, property.color!, 'Couleur', AppColors.info),
                    ),
                  if (property.withDriver == true) ...[
                    if (property.color != null) const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailCard(context, Icons.person, '', 'Avec chauffeur', AppColors.primary),
                    ),
                  ],
                ],
              ),
            ],
          ],
          
          // Caractéristiques selon le type : Salle de fête / Événement (aligné sur le modèle API)
          if (property.type == 'event_hall') ...[
            Row(
              children: [
                if (property.capacity != null)
                  Expanded(
                    child: _buildDetailCard(
                      context, Icons.groups, '${property.capacity}', 'Capacité (personnes)', AppColors.primary,
                    ),
                  ),
                if (property.capacity != null && property.hasParking) const SizedBox(width: 12),
                if (property.hasParking)
                  Expanded(
                    child: _buildDetailCard(context, Icons.local_parking, '', 'Parking', AppColors.success),
                  ),
              ],
            ),
            if (property.eventTypes != null && property.eventTypes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...property.eventTypes!.map((e) {
                    final label = _eventTypeLabel(e);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ],
          
          // Statistiques (vues et avis)
          if (property.viewCount > 0 || property.reviewCount > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (property.viewCount > 0)
                  Expanded(
                    child: _buildDetailCard(
                      context, 
                      Icons.visibility_outlined, 
                      '${property.viewCount}', 
                      'Vue${property.viewCount > 1 ? 's' : ''}',
                      AppColors.textTertiary,
                    ),
                  ),
                if (property.viewCount > 0 && property.reviewCount > 0)
                  const SizedBox(width: 12),
                if (property.reviewCount > 0)
                  Expanded(
                    child: _buildDetailCard(
                      context, 
                      Icons.star_outline, 
                      '${property.reviewCount}', 
                      'Avis',
                      AppColors.warning,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _eventTypeLabel(String value) {
    final v = value.toLowerCase();
    if (v == 'wedding' || v == 'mariage') return 'Mariage';
    if (v == 'seminar' || v == 'seminaire') return 'Séminaire';
    if (v == 'birthday' || v == 'anniversaire') return 'Anniversaire';
    if (v == 'conference' || v == 'conference') return 'Conférence';
    if (v == 'cocktail') return 'Cocktail';
    if (v == 'gala') return 'Gala';
    if (v == 'reception') return 'Réception';
    if (v == 'party' || v == 'fete') return 'Fête';
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  /// Formate un nombre (ex: kilométrage) avec espaces comme séparateur de milliers.
  static String _formatNumber(int? value) {
    if (value == null) return '—';
    final s = value.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Widget _buildDetailCard(BuildContext context, IconData icon, String value, String label, Color color) {
    final displayValue = value.trim().isEmpty ? '—' : value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          if (displayValue != '—')
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                displayValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, Property property) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withValues(alpha: 0.08),
                AppColors.warning.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.warning, Color(0xFFFFA726)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warning.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Avis des visiteurs',
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (property.reviewCount > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${property.rating?.toStringAsFixed(1) ?? '0.0'}',
                                style: const TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${property.reviewCount} avis)',
                                style: const TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Les 2 derniers avis - Affichage simple sans chargement automatique
              if (property.reviewCount > 0) ...[
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PropertyReviewsScreen(
                                propertyId: property.id,
                                propertyTitle: property.title,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Voir les avis',
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${property.reviewCount})',
                                style: const TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.warning.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.rate_review_rounded,
                          size: 32,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Aucun avis pour le moment',
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescription(BuildContext context, property) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            property.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities(BuildContext context, Property property) {
    // Toutes les caractéristiques du type, disponibles ou non (nom -> disponible)
    final amenities = <String, bool>{};

    switch (property.type) {
      case 'apartment':
        amenities['Parking'] = property.hasParking;
        amenities['Ascenseur'] = property.hasElevator;
        amenities['Balcon'] = property.hasBalcony;
        break;
      case 'house':
        amenities['Parking'] = property.hasParking;
        amenities['Jardin'] = property.hasGarden ?? false;
        amenities['Piscine'] = property.hasPool ?? false;
        amenities['Garage'] = property.hasGarage ?? false;
        break;
      case 'event_hall':
        amenities['Parking'] = property.hasParking;
        amenities['Système sonore'] = property.hasSoundSystem ?? false;
        amenities['Vidéoprojecteur'] = property.hasVideoProjector ?? false;
        amenities['Cuisine'] = property.hasKitchen ?? false;
        amenities['Espace extérieur'] = property.hasOutdoorSpace ?? false;
        break;
      case 'land':
        amenities['Accès eau'] = property.hasWaterAccess ?? false;
        amenities['Électricité'] = property.hasElectricityAccess ?? false;
        amenities['Clôturé'] = property.isFenced ?? false;
        amenities['Permis de construire'] = property.hasBuildingPermit ?? false;
        break;
      case 'car':
        amenities['Avec chauffeur'] = property.withDriver ?? false;
        break;
      default:
        amenities['Parking'] = property.hasParking;
    }

    if (amenities.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tune,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Équipements & commodités',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: amenities.entries.map((entry) {
              final available = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: available
                      ? AppColors.success.withOpacity(0.12)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: available
                        ? AppColors.success.withOpacity(0.35)
                        : Theme.of(context).dividerColor.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      available ? Icons.check_circle : Icons.cancel_outlined,
                      size: 18,
                      color: available ? AppColors.success : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: available ? AppColors.success : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: available ? FontWeight.w600 : FontWeight.w500,
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                property.ownerName.isNotEmpty
                    ? property.ownerName[0].toUpperCase()
                    : 'U',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Propriétaire',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Note: La vérification du propriétaire n'est pas disponible dans le modèle Property actuel
                    // Si nécessaire, ajouter un champ isOwnerVerified dans Property
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  property.ownerName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildImageUrls(property) {
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

  void _showShareDialog(BuildContext context, Property property) {
    final GlobalKey repaintBoundaryKey = GlobalKey();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partager cette propriété'),
        content: SizedBox(
          width: 350,
          height: 500,
          child: PropertyShareWidget(
            property: property,
            repaintBoundaryKey: repaintBoundaryKey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Ne pas fermer le dialog immédiatement
              await _shareProperty(context, property, repaintBoundaryKey);
              // Fermer le dialog seulement après le partage
              if (mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Partager'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareProperty(BuildContext context, Property property, GlobalKey repaintBoundaryKey) async {
    try {
      // Capturer l'image du widget
      final RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Sauvegarder l'image temporairement
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'futela_property_${property.id}.png';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      // Texte adapté à la propriété (catégorie, type, prix, adresse)
      final categoryLabel = property.categoryName.isNotEmpty ? '${property.categoryName} • ' : '';
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Découvrez cette annonce sur Futela !\n\n'
              '$categoryLabel${property.typeDisplayName}\n'
              '${property.title}\n'
              '${property.formattedPrice}${property.type == 'for-rent' ? '/mois' : ''}\n'
              '${property.fullAddress}\n\n'
              'Téléchargez l\'app Futela ou visitez futela.com',
        subject: 'Futela - ${property.categoryName.isNotEmpty ? property.categoryName : "Annonce"} : ${property.title}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Méthode _formatReviewDate commentée (non utilisée actuellement)
  // String _formatReviewDate(DateTime date) {
  //   final now = DateTime.now();
  //   final difference = now.difference(date);

  //   if (difference.inDays == 0) {
  //     if (difference.inHours == 0) {
  //       if (difference.inMinutes == 0) {
  //         return 'À l\'instant';
  //       }
  //       return 'Il y a ${difference.inMinutes} min';
  //     }
  //     return 'Il y a ${difference.inHours}h';
  //   } else if (difference.inDays == 1) {
  //     return 'Hier';
  //   } else if (difference.inDays < 7) {
  //     return 'Il y a ${difference.inDays} jours';
  //   } else if (difference.inDays < 30) {
  //     final weeks = (difference.inDays / 7).floor();
  //     return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
  //   } else if (difference.inDays < 365) {
  //     final months = (difference.inDays / 30).floor();
  //     return 'Il y a $months mois';
  //   } else {
  //     final years = (difference.inDays / 365).floor();
  //     return 'Il y a $years an${years > 1 ? 's' : ''}';
  //   }
  // }
}
