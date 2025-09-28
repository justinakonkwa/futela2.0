import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/property.dart';
import '../utils/app_colors.dart';

class PropertyShareWidget extends StatefulWidget {
  final Property property;
  final GlobalKey repaintBoundaryKey;

  const PropertyShareWidget({
    super.key,
    required this.property,
    required this.repaintBoundaryKey,
  });

  @override
  State<PropertyShareWidget> createState() => _PropertyShareWidgetState();
}

class _PropertyShareWidgetState extends State<PropertyShareWidget> {

  // Méthode pour obtenir la première image disponible
  String? get _firstAvailableImage {
    print('🔍 PropertyShareWidget - Debug Images:');
    print('  - cover: ${widget.property.cover}');
    print('  - images: ${widget.property.images}');
    print('  - images length: ${widget.property.images?.length}');
    
    // Priorité 1: Image de couverture (seulement si c'est une URL complète)
    if (widget.property.cover != null && 
        widget.property.cover!.isNotEmpty && 
        widget.property.cover!.startsWith('http')) {
      print('  ✅ Using cover image: ${widget.property.cover}');
      return widget.property.cover;
    }
    
    // Priorité 2: Première image de la liste
    if (widget.property.images != null && widget.property.images!.isNotEmpty) {
      print('  ✅ Using first image from list: ${widget.property.images!.first}');
      return widget.property.images!.first;
    }
    
    // Aucune image disponible
    print('  ❌ No image available');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: widget.repaintBoundaryKey,
      child: Container(
        width: 350,
        height: 450,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // En-tête avec logo et nom de l'app
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Logo Futela
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/icons/icon.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Nom de l'app
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Futela',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'Votre maison de rêve vous attend',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Image de la propriété avec section téléchargement en overlay
            Container(
              width: double.infinity,
              height: 150,
              child: Stack(
                children: [
                  // Image de fond
                  Positioned.fill(
                    child: _firstAvailableImage != null
                        ? CachedNetworkImage(
                            imageUrl: _firstAvailableImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              print('🔄 Loading image: $_firstAvailableImage');
                              return Container(
                                color: AppColors.grey100,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorWidget: (context, url, error) {
                              print('❌ Error loading image: $_firstAvailableImage - Error: $error');
                              return Container(
                                color: AppColors.grey100,
                                child: const Icon(
                                  Icons.home_work,
                                  size: 48,
                                  color: AppColors.textTertiary,
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
                  
                  // Overlay sombre pour la lisibilité
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.6),
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  
                  // Section téléchargement en bas
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Téléchargez l\'app Futela',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Boutons de téléchargement
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Play Store
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.play_arrow,
                                      color: AppColors.primary,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Play Store',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              
                              // App Store
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.apple,
                                      color: AppColors.primary,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'App Store',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Site web
                          const Text(
                            'futela.com',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Informations de la propriété
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prix et type
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.property.formattedPrice,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.property.type == 'for-rent' 
                                ? AppColors.secondary 
                                : AppColors.success,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.property.typeDisplayName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Titre
                    Text(
                      widget.property.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Adresse
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.property.fullAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Caractéristiques
                    if (widget.property.apartment != null) ...[
                      _buildCharacteristics(
                        'Chambres',
                        '${widget.property.apartment!.beds}',
                        Icons.bed_outlined,
                      ),
                      const SizedBox(height: 6),
                      _buildCharacteristics(
                        'Salles de bain',
                        '${widget.property.apartment!.baths}',
                        Icons.bathtub_outlined,
                      ),
                      const SizedBox(height: 6),
                      _buildCharacteristics(
                        'Surface',
                        '${widget.property.apartment!.area.toInt()} m²',
                        Icons.square_foot,
                      ),
                    ] else if (widget.property.house != null) ...[
                      _buildCharacteristics(
                        'Chambres',
                        '${widget.property.house!.beds}',
                        Icons.bed_outlined,
                      ),
                      const SizedBox(height: 6),
                      _buildCharacteristics(
                        'Salles de bain',
                        '${widget.property.house!.baths}',
                        Icons.bathtub_outlined,
                      ),
                      const SizedBox(height: 6),
                      _buildCharacteristics(
                        'Surface',
                        '${widget.property.house!.area.toInt()} m²',
                        Icons.square_foot,
                      ),
                    ],

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristics(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class PropertyShareButton extends StatelessWidget {
  final Property property;

  const PropertyShareButton({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey repaintBoundaryKey = GlobalKey();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Widget de partage (caché)
        Positioned(
          left: -1000,
          top: -1000,
          child: PropertyShareWidget(
            property: property,
            repaintBoundaryKey: repaintBoundaryKey,
          ),
        ),

        // Bouton de partage
        ElevatedButton.icon(
          onPressed: () => _showShareDialog(context, property, repaintBoundaryKey),
          icon: const Icon(Icons.share),
          label: const Text('Partager'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _showShareDialog(BuildContext context, Property property, GlobalKey repaintBoundaryKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partager cette propriété'),
        content: SizedBox(
          width: 300,
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
              Navigator.of(context).pop();
              await _shareProperty(context, property, repaintBoundaryKey);
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

      // Partager l'image
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Découvrez cette propriété sur Futela !\n\n'
              '${property.title}\n'
              '${property.formattedPrice}${property.type == 'for-rent' ? '/mois' : ''}\n'
              '${property.fullAddress}\n\n'
              'Téléchargez l\'app Futela pour plus de propriétés !',
        subject: 'Propriété Futela - ${property.title}',
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
}
