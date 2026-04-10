import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/property_card.dart';
import '../../widgets/property_card_shimmer.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/category_chips.dart';
import '../property/property_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _selectedCategory;
  String? _selectedType;
  double? _minPrice;
  double? _maxPrice;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedTown;
  
  // Filtres avancés
  int? _minBeds;
  int? _maxBeds;
  int? _minBaths;
  int? _maxBaths;
  double? _minArea;
  double? _maxArea;
  int? _minFloor;
  int? _maxFloor;
  bool? _isFurnished;
  bool? _hasParking;
  bool? _hasPool;
  bool? _hasBalcony;
  bool? _hasAirConditioning;
  bool? _hasHeating;
  bool? _petsAllowed;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    propertyProvider.loadCategories();
    propertyProvider.loadProvinces();
    locationProvider.getCurrentLocation();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      if (!propertyProvider.isLoading && propertyProvider.nextCursor != null) {
        _performSearch();
      }
    }
  }

  void _performSearch({bool refresh = false}) {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final queryText = _searchController.text.trim();
    
    print('🔥 SEARCH - _performSearch called');
    print('  - query: "$queryText"');
    print('  - category: "$_selectedCategory"');
    print('  - minPrice: $_minPrice');
    print('  - maxPrice: $_maxPrice');
    print('  - refresh: $refresh');
    
    propertyProvider.searchProperties(
      query: queryText.isEmpty ? null : queryText,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      category: _selectedCategory,
      town: _selectedTown,
      cityId: _selectedCity,
      type: _selectedType,
      bedrooms: _minBeds,
      hasParking: _hasParking,
      hasPool: _hasPool,
      isFurnished: _isFurnished,
      limit: 20,
      offset: 0,
      refresh: refresh,
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AdvancedFiltersBottomSheet(
        selectedType: _selectedType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        selectedProvince: _selectedProvince,
        selectedCity: _selectedCity,
        selectedTown: _selectedTown,
        minBeds: _minBeds,
        maxBeds: _maxBeds,
        minBaths: _minBaths,
        maxBaths: _maxBaths,
        minArea: _minArea,
        maxArea: _maxArea,
        minFloor: _minFloor,
        maxFloor: _maxFloor,
        isFurnished: _isFurnished,
        hasParking: _hasParking,
        hasPool: _hasPool,
        hasBalcony: _hasBalcony,
        hasAirConditioning: _hasAirConditioning,
        hasHeating: _hasHeating,
        petsAllowed: _petsAllowed,
        onApplyFilters: (filters) {
          setState(() {
            _selectedType = filters['type'];
            _minPrice = filters['minPrice'];
            _maxPrice = filters['maxPrice'];
            _selectedProvince = filters['province'];
            _selectedCity = filters['city'];
            _selectedTown = filters['town'];
            _minBeds = filters['minBeds'];
            _maxBeds = filters['maxBeds'];
            _minBaths = filters['minBaths'];
            _maxBaths = filters['maxBaths'];
            _minArea = filters['minArea'];
            _maxArea = filters['maxArea'];
            _minFloor = filters['minFloor'];
            _maxFloor = filters['maxFloor'];
            _isFurnished = filters['isFurnished'];
            _hasParking = filters['hasParking'];
            _hasPool = filters['hasPool'];
            _hasBalcony = filters['hasBalcony'];
            _hasAirConditioning = filters['hasAirConditioning'];
            _hasHeating = filters['hasHeating'];
            _petsAllowed = filters['petsAllowed'];
          });
          _performSearch(refresh: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Rechercher',
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        if (value.length >= 3) {
                          _performSearch(refresh: true);
                        }
                      },
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher une propriété...',
                        hintStyle: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(10),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.primaryLight.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            CupertinoIcons.search,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showFilters,
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: Icon(
                          Icons.tune_rounded,
                          size: 24,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtres rapides (catégories + types)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 8),
                  child: Text(
                    'Catégorie',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                CategoryChips(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (categoryId) {
                    print('🔥 SEARCH - Category selected: $categoryId');
                    setState(() {
                      _selectedCategory = categoryId; // Garder l'ID, pas le nom/slug
                    });
                    _performSearch(refresh: true);
                  },
                ),
                const SizedBox(height: 14),
                _buildQuickFilters(),
              ],
            ),
          ),
          
          // Résultats
          Expanded(
            child: Consumer<PropertyProvider>(
              builder: (context, propertyProvider, child) {
                if (propertyProvider.isLoading && propertyProvider.properties.isEmpty) {
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

                if (propertyProvider.error != null && propertyProvider.properties.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.error.withOpacity(0.1),
                                  AppColors.error.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 40,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Erreur de recherche',
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            propertyProvider.error!,
                            textAlign: TextAlign.center,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
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
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _performSearch(refresh: true),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  child: Text(
                                    'Réessayer',
                                    style: TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (propertyProvider.properties.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.textTertiary.withOpacity(0.1),
                                  AppColors.textTertiary.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 40,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Aucun résultat trouvé',
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Essayez de modifier vos critères de recherche',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => _performSearch(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: propertyProvider.properties.length + 
                        (propertyProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == propertyProvider.properties.length) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: PropertyCardShimmer(),
                        );
                      }

                      final property = propertyProvider.properties[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PropertyCard(
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
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    // Déterminer quels filtres afficher selon la catégorie
    final categoryLower = _selectedCategory?.toLowerCase() ?? '';
    
    // T1-T4+ : Seulement pour Apartment et House
    final showRoomFilters = categoryLower.isEmpty || 
                           categoryLower.contains('apartment') || 
                           categoryLower.contains('appartement') ||
                           categoryLower.contains('house') ||
                           categoryLower.contains('maison');
    
    // Meublé : Pour Apartment et House
    final showFurnished = categoryLower.isEmpty || 
                         categoryLower.contains('apartment') || 
                         categoryLower.contains('appartement') ||
                         categoryLower.contains('house') ||
                         categoryLower.contains('maison');
    
    // Parking : Pour Apartment, House, Event Hall
    final showParking = categoryLower.isEmpty || 
                       categoryLower.contains('apartment') || 
                       categoryLower.contains('appartement') ||
                       categoryLower.contains('house') ||
                       categoryLower.contains('maison') ||
                       categoryLower.contains('event') ||
                       categoryLower.contains('hall') ||
                       categoryLower.contains('salle');
    
    // Piscine : Pour House principalement
    final showPool = categoryLower.isEmpty || 
                    categoryLower.contains('house') ||
                    categoryLower.contains('maison') ||
                    categoryLower.contains('villa');
    
    List<Widget> filters = [];
    
    // Filtres de chambres (T1-T4+)
    if (showRoomFilters) {
      filters.addAll([
        Tooltip(
          message: '1 pièce (studio)',
          child: _buildQuickFilterChip('T1', _minBeds == 1 && _maxBeds == 1, () => _setQuickFilter(1, 1)),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: '2 pièces',
          child: _buildQuickFilterChip('T2', _minBeds == 2 && _maxBeds == 2, () => _setQuickFilter(2, 2)),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: '3 pièces',
          child: _buildQuickFilterChip('T3', _minBeds == 3 && _maxBeds == 3, () => _setQuickFilter(3, 3)),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: '4 pièces et plus',
          child: _buildQuickFilterChip('T4+', _minBeds == 4 && _maxBeds == null, () => _setQuickFilter(4, null)),
        ),
      ]);
    }
    
    // Filtre Meublé
    if (showFurnished) {
      if (filters.isNotEmpty) filters.add(const SizedBox(width: 8));
      filters.add(_buildQuickFilterChip('Meublé', _isFurnished == true, () => _setFurnishedFilter(true)));
    }
    
    // Filtre Parking
    if (showParking) {
      if (filters.isNotEmpty) filters.add(const SizedBox(width: 8));
      filters.add(_buildQuickFilterChip('Parking', _hasParking == true, () => _setParkingFilter(true)));
    }
    
    // Filtre Piscine
    if (showPool) {
      if (filters.isNotEmpty) filters.add(const SizedBox(width: 8));
      filters.add(_buildQuickFilterChip('Piscine', _hasPool == true, () => _setPoolFilter(true)));
    }
    
    // Si aucun filtre à afficher, retourner un widget vide
    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: filters),
    );
  }

  Widget _buildQuickFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.shadow.withOpacity(0.08),
                blurRadius: isSelected ? 8 : 6,
                offset: Offset(0, isSelected ? 3 : 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: isSelected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  void _setQuickFilter(int minBeds, int? maxBeds) {
    setState(() {
      _minBeds = minBeds;
      _maxBeds = maxBeds;
    });
    _performSearch(refresh: true);
  }

  void _setFurnishedFilter(bool furnished) {
    setState(() {
      _isFurnished = furnished;
    });
    _performSearch(refresh: true);
  }

  void _setParkingFilter(bool hasParking) {
    setState(() {
      _hasParking = hasParking;
    });
    _performSearch(refresh: true);
  }

  void _setPoolFilter(bool hasPool) {
    setState(() {
      _hasPool = hasPool;
    });
    _performSearch(refresh: true);
  }
}

class _AdvancedFiltersBottomSheet extends StatefulWidget {
  final String? selectedType;
  final double? minPrice;
  final double? maxPrice;
  final String? selectedProvince;
  final String? selectedCity;
  final String? selectedTown;
  final int? minBeds;
  final int? maxBeds;
  final int? minBaths;
  final int? maxBaths;
  final double? minArea;
  final double? maxArea;
  final int? minFloor;
  final int? maxFloor;
  final bool? isFurnished;
  final bool? hasParking;
  final bool? hasPool;
  final bool? hasBalcony;
  final bool? hasAirConditioning;
  final bool? hasHeating;
  final bool? petsAllowed;
  final Function(Map<String, dynamic>) onApplyFilters;

  const _AdvancedFiltersBottomSheet({
    required this.selectedType,
    required this.minPrice,
    required this.maxPrice,
    required this.selectedProvince,
    required this.selectedCity,
    required this.selectedTown,
    required this.minBeds,
    required this.maxBeds,
    required this.minBaths,
    required this.maxBaths,
    required this.minArea,
    required this.maxArea,
    required this.minFloor,
    required this.maxFloor,
    required this.isFurnished,
    required this.hasParking,
    required this.hasPool,
    required this.hasBalcony,
    required this.hasAirConditioning,
    required this.hasHeating,
    required this.petsAllowed,
    required this.onApplyFilters,
  });

  @override
  State<_AdvancedFiltersBottomSheet> createState() => _AdvancedFiltersBottomSheetState();
}

class _AdvancedFiltersBottomSheetState extends State<_AdvancedFiltersBottomSheet> {
  late String? _selectedType;
  late double? _minPrice;
  late double? _maxPrice;
  late String? _selectedProvince;
  late String? _selectedCity;
  late String? _selectedTown;
  late int? _minBeds;
  late int? _maxBeds;
  late int? _minBaths;
  late int? _maxBaths;
  late double? _minArea;
  late double? _maxArea;
  late int? _minFloor;
  late int? _maxFloor;
  late bool? _isFurnished;
  late bool? _hasParking;
  late bool? _hasPool;
  late bool? _hasBalcony;
  late bool? _hasAirConditioning;
  late bool? _hasHeating;
  late bool? _petsAllowed;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _selectedProvince = widget.selectedProvince;
    _selectedCity = widget.selectedCity;
    _selectedTown = widget.selectedTown;
    _minBeds = widget.minBeds;
    _maxBeds = widget.maxBeds;
    _minBaths = widget.minBaths;
    _maxBaths = widget.maxBaths;
    _minArea = widget.minArea;
    _maxArea = widget.maxArea;
    _minFloor = widget.minFloor;
    _maxFloor = widget.maxFloor;
    _isFurnished = widget.isFurnished;
    _hasParking = widget.hasParking;
    _hasPool = widget.hasPool;
    _hasBalcony = widget.hasBalcony;
    _hasAirConditioning = widget.hasAirConditioning;
    _hasHeating = widget.hasHeating;
    _petsAllowed = widget.petsAllowed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Filtres',
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedType = null;
                          _minPrice = null;
                          _maxPrice = null;
                          _selectedProvince = null;
                          _selectedCity = null;
                          _selectedTown = null;
                          _minBeds = null;
                          _maxBeds = null;
                          _minBaths = null;
                          _maxBaths = null;
                          _minArea = null;
                          _maxArea = null;
                          _minFloor = null;
                          _maxFloor = null;
                          _isFurnished = null;
                          _hasParking = null;
                          _hasPool = null;
                          _hasBalcony = null;
                          _hasAirConditioning = null;
                          _hasHeating = null;
                          _petsAllowed = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Réinitialiser',
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type de propriété
                  _buildSectionTitle('Type de propriété'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeChip('for-rent', 'À louer'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTypeChip('for-sale', 'À vendre'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Prix
                  _buildSectionTitle('Prix'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          hint: 'Prix min',
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _minPrice = double.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          hint: 'Prix max',
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _maxPrice = double.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Localisation hiérarchique
                  _buildSectionTitle('Localisation'),
                  const SizedBox(height: 12),
                  _buildLocationFilters(),
                  
                  const SizedBox(height: 24),
                  
                  // Caractéristiques
                  _buildSectionTitle('Caractéristiques'),
                  const SizedBox(height: 12),
                  _buildCharacteristicsFilters(),
                  
                  const SizedBox(height: 24),
                  
                  // Équipements
                  _buildSectionTitle('Équipements'),
                  const SizedBox(height: 12),
                  _buildAmenitiesFilters(),
                ],
              ),
            ),
          ),
          
          // Apply button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Appliquer les filtres',
              fullWidth: true,
              onPressed: () {
                final filters = {
                  'type': _selectedType,
                  'minPrice': _minPrice,
                  'maxPrice': _maxPrice,
                  'province': _selectedProvince,
                  'city': _selectedCity,
                  'town': _selectedTown,
                  'minBeds': _minBeds,
                  'maxBeds': _maxBeds,
                  'minBaths': _minBaths,
                  'maxBaths': _maxBaths,
                  'minArea': _minArea,
                  'maxArea': _maxArea,
                  'minFloor': _minFloor,
                  'maxFloor': _maxFloor,
                  'isFurnished': _isFurnished,
                  'hasParking': _hasParking,
                  'hasPool': _hasPool,
                  'hasBalcony': _hasBalcony,
                  'hasAirConditioning': _hasAirConditioning,
                  'hasHeating': _hasHeating,
                  'petsAllowed': _petsAllowed,
                };
                widget.onApplyFilters(filters);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTypeChip(String type, String label) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = isSelected ? null : type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationFilters() {
    return Consumer2<PropertyProvider, LocationProvider>(
      builder: (context, propertyProvider, locationProvider, child) {
        return Column(
          children: [
            // Province
            DropdownButtonFormField<String>(
              value: _selectedProvince,
              decoration: const InputDecoration(
                labelText: 'Province',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              items: propertyProvider.provinces.map((province) {
                return DropdownMenuItem(
                  value: province.id,
                  child: Text(province.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProvince = value;
                  _selectedCity = null;
                  _selectedTown = null;
                });
                if (value != null) {
                  propertyProvider.loadCities(province: value);
                }
              },
            ),
            
            const SizedBox(height: 12),
            
            // Ville
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'Ville',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              items: propertyProvider.cities.map((city) {
                return DropdownMenuItem(
                  value: city.id,
                  child: Text(city.name),
                );
              }).toList(),
              onChanged: _selectedProvince != null ? (value) {
                setState(() {
                  _selectedCity = value;
                  _selectedTown = null;
                });
                if (value != null) {
                  propertyProvider.loadTowns(city: value);
                }
              } : null,
            ),
            
            const SizedBox(height: 12),
            
            // Commune
            DropdownButtonFormField<String>(
              value: _selectedTown,
              decoration: const InputDecoration(
                labelText: 'Commune',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: propertyProvider.towns.map((town) {
                return DropdownMenuItem(
                  value: town.id,
                  child: Text(town.name),
                );
              }).toList(),
              onChanged: _selectedCity != null ? (value) {
                setState(() {
                  _selectedTown = value;
                });
              } : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCharacteristicsFilters() {
    return Column(
      children: [
        // Chambres
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hint: 'Chambres min',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _minBeds = int.tryParse(value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                hint: 'Chambres max',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _maxBeds = int.tryParse(value);
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Salles de bain
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hint: 'SDB min',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _minBaths = int.tryParse(value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                hint: 'SDB max',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _maxBaths = int.tryParse(value);
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Surface
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hint: 'Surface min (m²)',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _minArea = double.tryParse(value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                hint: 'Surface max (m²)',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _maxArea = double.tryParse(value);
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Étage
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hint: 'Étage min',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _minFloor = int.tryParse(value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                hint: 'Étage max',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _maxFloor = int.tryParse(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesFilters() {
    return Column(
      children: [
        _buildAmenitySwitch('Meublé', _isFurnished, (value) => _isFurnished = value),
        _buildAmenitySwitch('Parking', _hasParking, (value) => _hasParking = value),
        _buildAmenitySwitch('Piscine', _hasPool, (value) => _hasPool = value),
        _buildAmenitySwitch('Balcon', _hasBalcony, (value) => _hasBalcony = value),
        _buildAmenitySwitch('Climatisation', _hasAirConditioning, (value) => _hasAirConditioning = value),
        _buildAmenitySwitch('Chauffage', _hasHeating, (value) => _hasHeating = value),
        _buildAmenitySwitch('Animaux autorisés', _petsAllowed, (value) => _petsAllowed = value),
      ],
    );
  }

  Widget _buildAmenitySwitch(String label, bool? value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value ?? false,
            onChanged: (newValue) {
              setState(() {
                onChanged(newValue ? true : null);
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
