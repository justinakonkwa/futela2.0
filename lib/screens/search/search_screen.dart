import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/property_card.dart';
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
    
    propertyProvider.searchProperties(
      query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      category: _selectedCategory,
      town: _selectedTown,
      type: _selectedType,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rechercher'),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchController,
                    hint: 'Rechercher une propriété...',
                    prefixIcon: const Icon(Icons.search),
                    onChanged: (value) {
                      if (value.length >= 3) {
                        _performSearch(refresh: true);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _showFilters,
                  icon: const Icon(Icons.tune),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.grey100,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtres rapides
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                // Catégories
                CategoryChips(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (categoryId) {
                    setState(() {
                      _selectedCategory = categoryId;
                    });
                    _performSearch(refresh: true);
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Filtres rapides par type de logement
                _buildQuickFilters(),
              ],
            ),
          ),
          
          // Résultats
          Expanded(
            child: Consumer<PropertyProvider>(
              builder: (context, propertyProvider, child) {
                if (propertyProvider.isLoading && propertyProvider.properties.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (propertyProvider.error != null && propertyProvider.properties.isEmpty) {
                  return Center(
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
                          'Erreur de recherche',
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
                          onPressed: () => _performSearch(refresh: true),
                        ),
                      ],
                    ),
                  );
                }

                if (propertyProvider.properties.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun résultat trouvé',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez de modifier vos critères de recherche',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _performSearch(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: propertyProvider.properties.length + 
                        (propertyProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == propertyProvider.properties.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildQuickFilterChip('T1', () => _setQuickFilter(1, 1)),
          const SizedBox(width: 8),
          _buildQuickFilterChip('T2', () => _setQuickFilter(2, 2)),
          const SizedBox(width: 8),
          _buildQuickFilterChip('T3', () => _setQuickFilter(3, 3)),
          const SizedBox(width: 8),
          _buildQuickFilterChip('T4+', () => _setQuickFilter(4, null)),
          const SizedBox(width: 8),
          _buildQuickFilterChip('Meublé', () => _setFurnishedFilter(true)),
          const SizedBox(width: 8),
          _buildQuickFilterChip('Parking', () => _setParkingFilter(true)),
          const SizedBox(width: 8),
          _buildQuickFilterChip('Piscine', () => _setPoolFilter(true)),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
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
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Filtres',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
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
                  child: const Text('Réinitialiser'),
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
