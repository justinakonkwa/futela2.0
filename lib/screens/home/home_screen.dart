import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/error_formatter.dart';
import '../../utils/role_permissions.dart';
import '../../utils/auth_helper.dart';
import '../../widgets/property_card.dart';
import '../../widgets/property_card_shimmer.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/futela_logo.dart';
import '../property/property_detail_screen.dart';
import '../property/add_property_screen.dart';
import '../notifications/notifications_screen.dart';

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
      final propertyProvider =
          Provider.of<PropertyProvider>(context, listen: false);
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      final favoriteProvider =
          Provider.of<FavoriteProvider>(context, listen: false);

      // Charger les catégories en premier
      propertyProvider.loadCategories().then((_) {
        // Puis charger les propriétés
        propertyProvider.loadHomeProperties(refresh: true);
      });
      propertyProvider.loadProvinces();
      locationProvider.getCurrentLocation();
      favoriteProvider.loadLocalFavorites();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final propertyProvider =
          Provider.of<PropertyProvider>(context, listen: false);
      if (!propertyProvider.isLoading && propertyProvider.hasMoreHomeFeed) {
        propertyProvider.loadHomeProperties(categoryId: _selectedCategory);
      }
    }
  }

  void _refreshData() {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    propertyProvider.loadHomeProperties(
        categoryId: _selectedCategory, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshData(),
          color: AppColors.primary,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar moderne avec header élégant
              SliverAppBar(
                expandedHeight: 160,
                floating: true,
                pinned: true,
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.primaryLight.withOpacity(0.04),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                 Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bonjour ! 👋',
                                        style: TextStyle(
                                          fontFamily: 'Gilroy',
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).textTheme.displayLarge?.color,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Trouvez votre maison de rêve',
                                        style: TextStyle(
                                          fontFamily: 'Gilroy',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).textTheme.bodySmall?.color,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Actions groupées
                                Row(
                                  children: [
                                    // Bouton pour créer une propriété
                                    Consumer<AuthProvider>(
                                      builder: (context, authProvider, child) {
                                        if (authProvider.user != null &&
                                            RolePermissions.canAddProperties(
                                                authProvider.user!)) {
                                          return Container(
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primary
                                                      .withOpacity(0.15),
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
                                                      builder: (context) =>
                                                          const AddPropertyScreen(),
                                                    ),
                                                  );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  child: const Icon(
                                                    Icons.add_rounded,
                                                    color: AppColors.primary,
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                    // Icône de notification
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.15),
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
                                                builder: (context) =>
                                                    const NotificationsScreen(),
                                              ),
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            child: const Icon(
                                              Icons.notifications_outlined,
                                              color: AppColors.primary,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(68),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.08),
                          AppColors.primaryLight.withOpacity(0.04),
                        ],
                      ),
                    ),
                    child: const SearchBarWidget(),
                  ),
                ),
              ),

              // Catégories avec design amélioré
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: CategoryChips(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (categoryName) {
                      print('🔥 HOME - Category selected: "$categoryName"');
                      setState(() {
                        _selectedCategory = categoryName;
                      });

                      final propertyProvider =
                          Provider.of<PropertyProvider>(context, listen: false);

                      print(
                          '🔥 HOME - Calling loadHomeProperties with categoryId: "$categoryName"');
                      propertyProvider.loadHomeProperties(
                        categoryId: categoryName,
                        refresh: true,
                      );
                    },
                  ),
                ),
              ),

              // Liste des propriétés avec design amélioré
              Consumer<PropertyProvider>(
                builder: (context, propertyProvider, child) {
                  if (propertyProvider.isLoading &&
                      propertyProvider.homeProperties.isEmpty) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: PropertyCardShimmer(),
                            );
                          },
                          childCount: 6,
                        ),
                      ),
                    );
                  }

                  if (propertyProvider.error != null &&
                      propertyProvider.homeProperties.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
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
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.displayLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                ErrorFormatter.format(propertyProvider.error),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
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
                                    onTap: _refreshData,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 32),
                                      child: const Row(
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
                      ),
                    );
                  }

                  if (propertyProvider.homeProperties.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          final canAddProperty = authProvider.user != null && 
                              RolePermissions.canAddProperties(authProvider.user!);
                          
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
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.2),
                                          blurRadius: 30,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const FutelaLogo(size: 80),
                                  ),
                                  const SizedBox(height: 28),
                                  Text(
                                    'Aucune propriété trouvée',
                                    style: TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).textTheme.displayLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    canAddProperty
                                        ? 'Soyez le premier à ajouter une propriété !'
                                        : 'Aucune propriété disponible pour le moment',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                      height: 1.5,
                                    ),
                                  ),
                                  if (canAddProperty) ...[
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
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AddPropertyScreen(),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(16),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16, horizontal: 32),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.add_home_rounded,
                                                  color: AppColors.white,
                                                  size: 22,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Ajouter une propriété',
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
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final property =
                              propertyProvider.homeProperties[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Consumer<FavoriteProvider>(
                              builder: (context, favoriteProvider, child) {
                                return PropertyCard(
                                  property: property,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PropertyDetailScreen(
                                          propertyId: property.id,
                                        ),
                                      ),
                                    );
                                  },
                                  onFavorite: () {
                                    if (AuthHelper.requireAuth(
                                      context,
                                      message:
                                          'Connectez-vous pour ajouter des propriétés à vos favoris',
                                    )) {
                                      favoriteProvider
                                          .toggleFavorite(property.id);
                                    }
                                  },
                                  showFavorite: true,
                                );
                              },
                            ),
                          );
                        },
                        childCount: propertyProvider.homeProperties.length,
                      ),
                    ),
                  );
                },
              ),

              // Indicateur de chargement en bas avec design amélioré
              Consumer<PropertyProvider>(
                builder: (context, propertyProvider, child) {
                  if (propertyProvider.isLoading &&
                      propertyProvider.homeProperties.isNotEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox(height: 24));
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user != null &&
              RolePermissions.canAddProperties(authProvider.user!)) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddPropertyScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
