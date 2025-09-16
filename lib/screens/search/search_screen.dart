import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_provider.dart';
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
  String? _selectedTown;

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
    
    propertyProvider.loadCategories();
    propertyProvider.loadProvinces();
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
      builder: (context) => _FiltersBottomSheet(
        selectedType: _selectedType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        selectedTown: _selectedTown,
        onApplyFilters: (type, minPrice, maxPrice, town) {
          setState(() {
            _selectedType = type;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
            _selectedTown = town;
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
          // Catégories
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CategoryChips(
              selectedCategory: _selectedCategory,
              onCategorySelected: (categoryId) {
                setState(() {
                  _selectedCategory = categoryId;
                });
                _performSearch(refresh: true);
              },
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
}

class _FiltersBottomSheet extends StatefulWidget {
  final String? selectedType;
  final double? minPrice;
  final double? maxPrice;
  final String? selectedTown;
  final Function(String?, double?, double?, String?) onApplyFilters;

  const _FiltersBottomSheet({
    required this.selectedType,
    required this.minPrice,
    required this.maxPrice,
    required this.selectedTown,
    required this.onApplyFilters,
  });

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  late String? _selectedType;
  late double? _minPrice;
  late double? _maxPrice;
  late String? _selectedTown;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _selectedTown = widget.selectedTown;
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
                      _selectedTown = null;
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
                  Text(
                    'Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                  Text(
                    'Prix',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                  
                  // Localisation
                  Text(
                    'Localisation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hint: 'Ville ou commune',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    onChanged: (value) {
                      _selectedTown = value.isEmpty ? null : value;
                    },
                  ),
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
                widget.onApplyFilters(_selectedType, _minPrice, _maxPrice, _selectedTown);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
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
}
