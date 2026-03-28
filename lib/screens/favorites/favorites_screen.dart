import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/favorite_property_card.dart';
import '../../widgets/property_card_shimmer.dart';
import '../../widgets/futela_logo.dart';
import '../property/property_detail_screen.dart';
import '../main_navigation.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFavorites());
  }

  void _loadFavorites() {
    context.read<FavoriteProvider>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Favoris'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: favoriteProvider.isLoading
                    ? null
                    : () async {
                        try {
                          await favoriteProvider.loadFavorites();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Favoris actualisés'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                tooltip: 'Actualiser les favoris',
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          
          if (favoriteProvider.isLoading && favoriteProvider.favorites.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: PropertyCardShimmer(),
                );
              },
            );
          }

          if (favoriteProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    favoriteProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      favoriteProvider.loadFavorites();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (favoriteProvider.favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Futela avec icône de favori
                    const FutelaLogoWithBadge(
                      size: 120,
                      badgeIcon: Icons.favorite,
                      badgeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Aucun favori',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Les propriétés que vous avez ajoutées aux favoris apparaîtront ici',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Naviguer vers la page d'accueil avec la navigation principale
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MainNavigation(initialIndex: 0),
                          ),
                        );
                      },
                      icon: const Icon(Icons.explore),
                      label: const Text('Explorer les propriétés'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => favoriteProvider.loadFavorites(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteProvider.favorites.length,
              itemBuilder: (context, index) {
                final listProperty = favoriteProvider.favorites[index];
                final property = listProperty.property;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FavoritePropertyCard(
                    property: property,
                    onRemoveFavorite: () {
                      favoriteProvider.toggleFavorite(property.id);
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PropertyDetailScreen(
                            propertyId: property.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
