import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/favorite_list_provider.dart';
import '../../widgets/favorite_property_card.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final favoriteProvider = context.read<FavoriteProvider>();
      final favoriteListProvider = context.read<FavoriteListProvider>();
      
      // Charger les listes de favoris depuis l'API
      favoriteListProvider.loadFavoriteLists(refresh: true).then((_) {
        // Une fois les listes chargées, essayer de récupérer les propriétés
        final defaultList = favoriteListProvider.defaultFavoriteList;
        if (defaultList != null) {
          print('🔍 Loading properties for list: ${defaultList.id}');
          // Essayer de charger les favoris avec l'ID de la liste
          favoriteProvider.loadFavorites(listId: defaultList.id).catchError((error) {
            print('❌ Error loading favorites for list ${defaultList.id}: $error');
            // Si ça échoue, essayer sans spécifier de liste
            favoriteProvider.loadFavorites().catchError((e) {
              print('❌ Error loading favorites without list: $e');
            });
          });
        } else {
          print('⚠️ No favorite list found, trying to load favorites anyway');
          favoriteProvider.loadFavorites().catchError((error) {
            print('❌ Error loading favorites: $error');
          });
        }
      }).catchError((error) {
        print('❌ Error loading favorite lists: $error');
        // Si les listes échouent, essayer quand même de charger les favoris
        favoriteProvider.loadFavorites().catchError((e) {
          print('❌ Error loading favorites: $e');
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Favoris'),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  final favoriteListProvider = context.read<FavoriteListProvider>();
                  try {
                    await favoriteListProvider.loadFavoriteLists(refresh: true);
                    final defaultList = favoriteListProvider.defaultFavoriteList;
                    if (defaultList != null) {
                      await favoriteProvider.loadFavorites(listId: defaultList.id);
                    } else {
                      await favoriteProvider.loadFavorites();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Favoris actualisés depuis l\'API'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                tooltip: 'Actualiser les favoris',
              );
            },
          ),
        ],
      ),
      body: Consumer2<FavoriteProvider, FavoriteListProvider>(
        builder: (context, favoriteProvider, favoriteListProvider, child) {
          
          if (favoriteProvider.isLoading && favoriteProvider.favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: 16),
                  Text('Chargement de vos favoris...'),
                ],
              ),
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
            onRefresh: () async {
              // Recharger les listes et favoris depuis l'API
              await favoriteListProvider.loadFavoriteLists(refresh: true);
              final defaultList = favoriteListProvider.defaultFavoriteList;
              if (defaultList != null) {
                await favoriteProvider.loadFavorites(listId: defaultList.id);
              } else {
                await favoriteProvider.loadFavorites();
              }
            },
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
