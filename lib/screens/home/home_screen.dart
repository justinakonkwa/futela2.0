import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/property_card.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/custom_button.dart';
import '../property/property_detail_screen.dart';
import '../property/add_property_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

      propertyProvider.loadProperties(refresh: true);
      propertyProvider.loadCategories();
      propertyProvider.loadProvinces();
      locationProvider.getCurrentLocation();
      favoriteProvider.loadLocalFavorites();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      if (!propertyProvider.isLoading && propertyProvider.nextCursor != null) {
        propertyProvider.loadProperties(category: _selectedCategory);
      }
    }
  }

  void _refreshData() {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    propertyProvider.loadProperties(category: _selectedCategory, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshData(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar avec recherche
              SliverAppBar(
                expandedHeight: 140,
                floating: true,
                pinned: true,
                backgroundColor: AppColors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour ! 👋',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Trouvez votre maison de rêve',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const SearchBarWidget(),
                  ),
                ),
              ),

              // Catégories
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CategoryChips(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (categoryId) {
                      setState(() {
                        _selectedCategory = categoryId;
                      });
                      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
                      propertyProvider.loadProperties(category: _selectedCategory, refresh: true);
                    },
                  ),
                ),
              ),

              // Liste des propriétés
              Consumer<PropertyProvider>(
                builder: (context, propertyProvider, child) {
                  if (propertyProvider.isLoading && propertyProvider.properties.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (propertyProvider.error != null && propertyProvider.properties.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur de chargement',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              propertyProvider.error!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: 'Réessayer',
                              onPressed: _refreshData,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (propertyProvider.properties.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_work_outlined,
                              size: 64,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune propriété trouvée',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Soyez le premier à ajouter une propriété !',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: 'Ajouter une propriété',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AddPropertyScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final property = propertyProvider.properties[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Consumer<FavoriteProvider>(
                              builder: (context, favoriteProvider, child) {
                                return PropertyCard(
                                  property: property,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => PropertyDetailScreen(
                                          propertyId: property.id,
                                        ),
                                      ),
                                    );
                                  },
                                  onFavorite: () {
                                    favoriteProvider.toggleFavorite(property.id);
                                  },
                                  showFavorite: true,
                                );
                              },
                            ),
                          );
                        },
                        childCount: propertyProvider.properties.length,
                      ),
                    ),
                  );
                },
              ),

              // Indicateur de chargement en bas
              Consumer<PropertyProvider>(
                builder: (context, propertyProvider, child) {
                  if (propertyProvider.isLoading && propertyProvider.properties.isNotEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox(height: 16));
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddPropertyScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: AppColors.white,
        ),
      ),
    );
  }
}
