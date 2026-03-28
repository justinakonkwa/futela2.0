import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../providers/property_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/property/category.dart';
import '../../models/property/property_photo.dart';

class AddPropertyScreen extends StatefulWidget {
  final String? propertyId; // Pour l'édition
  final bool isEditMode;
  final bool myProperty;

  const AddPropertyScreen({
    super.key,
    this.propertyId,
    this.isEditMode = false,
    this.myProperty = false,
  });

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _pricePerDayController = TextEditingController();
  final _pricePerMonthController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _keywordsController = TextEditingController();

  String? _selectedCategory;
  String? _selectedType; // dérivé de la catégorie : apartment, house, land, event_hall, car
  /// API : `for_rent` ou `for_sale` (enum unique côté backend).
  String _listingType = 'for_rent';
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedTown;
  /// Noms affichés en édition quand les listes province/ville/commune ne sont pas chargées
  String? _loadedProvinceName;
  String? _loadedCityName;
  String? _loadedTownName;

  // Photos (une seule liste ; la principale est désignée par étoile, conforme API multipart)
  List<File> _photoFiles = [];
  /// Photos existantes (mode édition) — pour affichage et suppression
  List<PropertyPhoto> _existingPhotos = [];
  /// IDs des photos supprimées par l'utilisateur (à envoyer à l'API à l'enregistrement)
  final Set<String> _deletedPhotoIds = {};
  int _primaryPhotoIndex = 0;
  final TextEditingController _photoCaptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  // Champs communs
  final _bedsController = TextEditingController();
  final _bathsController = TextEditingController();
  final _areaController = TextEditingController();
  final _floorController = TextEditingController();
  final _floorsController = TextEditingController(); // Pour les maisons
  final _houseSquareMetersController = TextEditingController(); // Pour les maisons
  final _landSquareMetersController = TextEditingController(); // Pour les maisons et terrains
  final _capacityController = TextEditingController(); // Pour les salles d'événements
  final _brandController = TextEditingController(); // Pour les véhicules
  final _modelController = TextEditingController(); // Pour les véhicules
  final _yearController = TextEditingController(); // Pour les véhicules
  final _licensePlateController = TextEditingController(); // Pour les véhicules
  final _seatsController = TextEditingController(); // Pour les véhicules
  final _mileageController = TextEditingController(); // Pour les véhicules
  final _colorController = TextEditingController(); // Pour les véhicules

  // Booléens communs
  bool _parking = false;
  bool _isFurnished = false;

  // Booléens Appartement
  bool _hasElevator = false;
  bool _hasBalcony = false;

  // Booléens Maison
  bool _hasGarden = false;
  bool _hasPool = false;
  bool _hasGarage = false;

  // Booléens Terrain
  String? _landType; // residential, commercial, agricultural, industrial
  bool _hasWaterAccess = false;
  bool _hasElectricityAccess = false;
  bool _isFenced = false;
  bool _hasBuildingPermit = false;

  // Booléens Salle d'événement
  bool _hasSoundSystem = false;
  bool _hasVideoProjector = false;
  bool _hasKitchen = false;
  bool _hasOutdoorSpace = false;
  List<String> _selectedEventTypes = []; // wedding, conference, party, corporate

  // Booléens Véhicule
  String? _fuelType; // diesel, gasoline, electric, hybrid, plugin_hybrid
  String? _transmission; // automatic, manual, semi_automatic
  bool _withDriver = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pricePerDayController.dispose();
    _pricePerMonthController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _keywordsController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _areaController.dispose();
    _floorController.dispose();
    _floorsController.dispose();
    _houseSquareMetersController.dispose();
    _landSquareMetersController.dispose();
    _capacityController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _seatsController.dispose();
    _mileageController.dispose();
    _colorController.dispose();
    _photoCaptionController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);

    propertyProvider.loadCategories();
    propertyProvider.loadProvinces();

    // Si on est en mode édition, charger les données de la propriété
    if (widget.isEditMode && widget.propertyId != null) {
      _loadPropertyData();
    }
  }

  Future<void> _loadPropertyData() async {
    if (widget.propertyId == null) return;

    try {
      final propertyProvider =
          Provider.of<PropertyProvider>(context, listen: false);
      final property = widget.myProperty
          ? await propertyProvider.getMyPropertyById(widget.propertyId!)
          : await propertyProvider.getPropertyById(widget.propertyId!);

      if (property == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Propriété non trouvée'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Remplir les champs avec les données existantes
      _titleController.text = property.title;
      _listingType = property.listingTypeApiValue;
      if (property.pricePerDay != null) {
        _pricePerDayController.text = property.pricePerDay.toString();
      }
      if (property.pricePerMonth != null) {
        _pricePerMonthController.text = property.pricePerMonth.toString();
      }
      _addressController.text = property.address?.formattedAddress ?? '';
      _descriptionController.text = property.description;
      _keywordsController.text = property.keywords;

      // Sélectionner la catégorie
      _selectedCategory = property.category['id'];

      // Sélectionner le type
      _selectedType = property.type;

      // Localisation : utiliser address (cityId, townId). Ne pas utiliser property.town (province = 'dummy').
      _selectedProvince = null;
      _selectedCity = property.address?.cityId;
      _selectedTown = property.address?.townId;
      _loadedCityName = property.address?.cityName;
      _loadedTownName = property.address?.townName;
      // Récupérer la province via l'API ville (l'adresse ne contient pas toujours province)
      if (_selectedCity != null && _selectedCity!.isNotEmpty) {
        final city = await propertyProvider.getCityById(_selectedCity!);
        if (city != null) {
          if (city.provinceId.isNotEmpty) _selectedProvince = city.provinceId;
          if (city.provinceName.isNotEmpty) _loadedProvinceName = city.provinceName;
        }
        if (_loadedProvinceName == null || _loadedProvinceName!.isEmpty) {
          _loadedProvinceName = property.address?.provinceName;
        }
        try {
          await propertyProvider.loadTowns(city: _selectedCity!);
        } catch (_) {}
      } else {
        _loadedProvinceName = property.address?.provinceName;
      }

      // Photos existantes (mode édition) — garder la liste pour affichage et suppression
      _existingPhotos = List<PropertyPhoto>.from(property.photos);
      _deletedPhotoIds.clear();

      // Remplir les détails selon le type
      switch (property.type) {
        case 'apartment':
          if (property.bedrooms != null) {
            _bedsController.text = property.bedrooms.toString();
          }
          if (property.bathrooms != null) {
            _bathsController.text = property.bathrooms.toString();
          }
          if (property.squareMeters != null) {
            _areaController.text = property.squareMeters.toString();
          }
          if (property.floor != null) {
            _floorController.text = property.floor.toString();
          }
          _hasElevator = property.hasElevator;
          _hasBalcony = property.hasBalcony;
          _parking = property.hasParking;
          break;

        case 'house':
          if (property.bedrooms != null) {
            _bedsController.text = property.bedrooms.toString();
          }
          if (property.bathrooms != null) {
            _bathsController.text = property.bathrooms.toString();
          }
          if (property.floors != null) {
            _floorsController.text = property.floors.toString();
          }
          if (property.houseSquareMeters != null) {
            _houseSquareMetersController.text = property.houseSquareMeters.toString();
          }
          if (property.landSquareMeters != null) {
            _landSquareMetersController.text = property.landSquareMeters.toString();
          }
          _hasGarden = property.hasGarden ?? false;
          _hasPool = property.hasPool ?? false;
          _hasGarage = property.hasGarage ?? false;
          _isFurnished = property.isFurnished ?? false;
          break;

        case 'land':
          if (property.squareMeters != null) {
            _landSquareMetersController.text = property.squareMeters.toString();
          }
          // Note: landType n'est pas dans le modèle Property actuel
          _hasWaterAccess = false; // À adapter selon le modèle
          _hasElectricityAccess = false; // À adapter selon le modèle
          _isFenced = false; // À adapter selon le modèle
          _hasBuildingPermit = false; // À adapter selon le modèle
          break;

        case 'event_hall':
          if (property.capacity != null) {
            _capacityController.text = property.capacity.toString();
          }
          _hasSoundSystem = property.hasSoundSystem ?? false;
          _hasVideoProjector = property.hasVideoProjector ?? false;
          _hasKitchen = property.hasKitchen ?? false;
          _hasOutdoorSpace = property.hasOutdoorSpace ?? false;
          _parking = property.hasParking;
          _selectedEventTypes = property.eventTypes ?? [];
          break;

        case 'car':
          if (property.brand != null) {
            _brandController.text = property.brand!;
          }
          if (property.model != null) {
            _modelController.text = property.model!;
          }
          if (property.year != null) {
            _yearController.text = property.year.toString();
          }
          if (property.seats != null) {
            _seatsController.text = property.seats.toString();
          }
          if (property.mileage != null) {
            _mileageController.text = property.mileage.toString();
          }
          if (property.color != null) {
            _colorController.text = property.color!;
          }
          _fuelType = property.fuelType;
          _transmission = property.transmission;
          _withDriver = property.withDriver ?? false;
          break;
      }

      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onProvinceChanged(String? provinceId) {
    setState(() {
      _selectedProvince = provinceId;
      _selectedCity = null; // Reset city when province changes
      _selectedTown = null; // Reset town when province changes
    });

    if (provinceId != null && provinceId.isNotEmpty) {
      final propertyProvider =
          Provider.of<PropertyProvider>(context, listen: false);
      print('🔄 Province changed to: $provinceId, loading cities...');
      propertyProvider.loadCities(province: provinceId).then((_) {
        if (mounted) {
          setState(() {}); // Refresh UI after cities are loaded
        }
      });
    }
  }

  void _onCityChanged(String? cityId) {
    setState(() {
      _selectedCity = cityId;
      _selectedTown = null; // Reset town when city changes
    });

    if (cityId != null && cityId.isNotEmpty) {
      final propertyProvider =
          Provider.of<PropertyProvider>(context, listen: false);
      print('🔄 City changed to: $cityId, loading towns...');
      propertyProvider.loadTowns(city: cityId).then((_) {
        if (mounted) {
          setState(() {}); // Refresh UI after towns are loaded
        }
      });
    }
  }

  /// Dérive le type (API) à partir d'une catégorie (slug / nom).
  static String? _typeFromCategory(String nameOrSlug) {
    final s = nameOrSlug.toLowerCase();
    if (s.contains('apartment') || s.contains('appartement')) return 'apartment';
    if (s.contains('house') || s.contains('maison') || s.contains('villa')) return 'house';
    if (s.contains('land') || s.contains('terrain')) return 'land';
    if (s.contains('event') || s.contains('salle')) return 'event_hall';
    if (s.contains('car') || s.contains('vehicule') || s.contains('voiture')) return 'car';
    return null;
  }

  void _resetTypeSpecificFields() {
    // Réinitialiser tous les champs spécifiques
    _bedsController.clear();
    _bathsController.clear();
    _areaController.clear();
    _floorController.clear();
    _floorsController.clear();
    _houseSquareMetersController.clear();
    _landSquareMetersController.clear();
    _capacityController.clear();
    _brandController.clear();
    _modelController.clear();
    _yearController.clear();
    _licensePlateController.clear();
    _seatsController.clear();
    _mileageController.clear();
    _colorController.clear();
    
    // Réinitialiser les booléens
    _parking = false;
    _isFurnished = false;
    _hasElevator = false;
    _hasBalcony = false;
    _hasGarden = false;
    _hasPool = false;
    _hasGarage = false;
    _hasWaterAccess = false;
    _hasElectricityAccess = false;
    _isFenced = false;
    _hasBuildingPermit = false;
    _hasSoundSystem = false;
    _hasVideoProjector = false;
    _hasKitchen = false;
    _hasOutdoorSpace = false;
    _withDriver = false;
    
    // Réinitialiser les sélections
    _landType = null;
    _fuelType = null;
    _transmission = null;
    _selectedEventTypes = [];
  }

  Future<void> _pickPhotos() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (images.isNotEmpty && mounted) {
        setState(() {
          final startCount = _photoFiles.length;
          _photoFiles.addAll(images.map((x) => File(x.path)));
          if (startCount == 0) _primaryPhotoIndex = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection des photos: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoFiles.removeAt(index);
      if (_primaryPhotoIndex >= _photoFiles.length) {
        _primaryPhotoIndex = _photoFiles.length > 0 ? 0 : 0;
      } else if (index < _primaryPhotoIndex) {
        _primaryPhotoIndex = _primaryPhotoIndex - 1;
      }
    });
  }

  void _setPrimaryPhoto(int index) {
    if (index >= 0 && index < _photoFiles.length) {
      setState(() => _primaryPhotoIndex = index);
    }
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ownerId = authProvider.user?.id;

    if (ownerId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Utilisateur non authentifié. Veuillez vous reconnecter.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (_selectedCategory == null || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une catégorie'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Construire les données selon le type
    final Map<String, dynamic> propertyData = {
      'type': _selectedType,
      'listingType': _listingType,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'pricePerDay': double.tryParse(_pricePerDayController.text) ?? 0.0,
      'categoryId': _selectedCategory,
      'address': {
        'townId': _selectedTown,
        'street': _addressController.text.trim(),
        if (_selectedType == 'apartment' || _selectedType == 'house' || _selectedType == 'event_hall')
          'number': '', // Peut être ajouté si nécessaire
      },
    };

    // Ajouter pricePerMonth si disponible (optionnel pour certains types)
    final pricePerMonth = double.tryParse(_pricePerMonthController.text);
    if (pricePerMonth != null && pricePerMonth > 0) {
      propertyData['pricePerMonth'] = pricePerMonth;
    }

    // Ajouter les champs spécifiques selon le type
    switch (_selectedType) {
      case 'apartment':
        propertyData['bedrooms'] = int.tryParse(_bedsController.text) ?? 0;
        propertyData['bathrooms'] = int.tryParse(_bathsController.text) ?? 0;
        propertyData['squareMeters'] = double.tryParse(_areaController.text) ?? 0.0;
        propertyData['floor'] = int.tryParse(_floorController.text) ?? 0;
        propertyData['hasElevator'] = _hasElevator;
        propertyData['hasBalcony'] = _hasBalcony;
        propertyData['hasParking'] = _parking;
        break;

      case 'house':
        propertyData['bedrooms'] = int.tryParse(_bedsController.text) ?? 0;
        propertyData['bathrooms'] = int.tryParse(_bathsController.text) ?? 0;
        propertyData['floors'] = int.tryParse(_floorsController.text) ?? 0;
        propertyData['houseSquareMeters'] = double.tryParse(_houseSquareMetersController.text) ?? 0.0;
        propertyData['landSquareMeters'] = double.tryParse(_landSquareMetersController.text) ?? 0.0;
        propertyData['hasGarden'] = _hasGarden;
        propertyData['hasPool'] = _hasPool;
        propertyData['hasGarage'] = _hasGarage;
        propertyData['isFurnished'] = _isFurnished;
        break;

      case 'land':
        propertyData['squareMeters'] = double.tryParse(_landSquareMetersController.text) ?? 0.0;
        propertyData['landType'] = _landType ?? 'residential';
        propertyData['hasWaterAccess'] = _hasWaterAccess;
        propertyData['hasElectricityAccess'] = _hasElectricityAccess;
        propertyData['isFenced'] = _isFenced;
        propertyData['hasBuildingPermit'] = _hasBuildingPermit;
        break;

      case 'event_hall':
        propertyData['capacity'] = int.tryParse(_capacityController.text) ?? 0;
        propertyData['hasSoundSystem'] = _hasSoundSystem;
        propertyData['hasVideoProjector'] = _hasVideoProjector;
        propertyData['hasKitchen'] = _hasKitchen;
        propertyData['hasParking'] = _parking;
        propertyData['hasOutdoorSpace'] = _hasOutdoorSpace;
        if (_selectedEventTypes.isNotEmpty) {
          propertyData['eventTypes'] = _selectedEventTypes.join(',');
        }
        break;

      case 'car':
        propertyData['brand'] = _brandController.text.trim();
        propertyData['model'] = _modelController.text.trim();
        propertyData['year'] = int.tryParse(_yearController.text) ?? DateTime.now().year;
        propertyData['licensePlate'] = _licensePlateController.text.trim();
        propertyData['seats'] = int.tryParse(_seatsController.text) ?? 0;
        propertyData['fuelType'] = _fuelType ?? 'gasoline';
        propertyData['transmission'] = _transmission ?? 'manual';
        propertyData['mileage'] = int.tryParse(_mileageController.text) ?? 0;
        propertyData['color'] = _colorController.text.trim();
        propertyData['withDriver'] = _withDriver;
        break;
    }

    // Debug: payload envoyé à l'API
    print('═══════════════════════════════════════════════════════════');
    print('📤 PAYLOAD (enregistrement propriété)');
    print('═══════════════════════════════════════════════════════════');
    for (final e in propertyData.entries) {
      print('  ${e.key}: ${e.value}');
    }
    print('═══════════════════════════════════════════════════════════');

    String? propertyId;

    if (widget.isEditMode && widget.propertyId != null) {
      propertyId = widget.propertyId!;
      // 1) Mise à jour du texte / données de la propriété
      await propertyProvider.updateProperty(propertyId, propertyData);
      // 2) Supprimer côté API les photos que l'utilisateur a retirées
      for (final photoId in _deletedPhotoIds) {
        try {
          await propertyProvider.deletePhoto(propertyId, photoId);
        } catch (_) {}
      }
      // 3) Ajouter les nouvelles photos (deuxième temps : images via l'API upload)
      if (_photoFiles.isNotEmpty) {
        try {
          final paths = _photoFiles.map((f) => f.path).toList();
          await propertyProvider.uploadImages(
            propertyId,
            paths,
            primaryIndex: _primaryPhotoIndex,
            caption: _photoCaptionController.text.trim().isEmpty
                ? null
                : _photoCaptionController.text.trim(),
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Propriété modifiée. Erreur upload photos: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } else {
      propertyId = await propertyProvider.createProperty(propertyData);
    }

    if (propertyId != null && mounted) {
      // Création : upload des photos après création
      if (!widget.isEditMode && _photoFiles.isNotEmpty) {
        try {
          final paths = _photoFiles.map((f) => f.path).toList();
          await propertyProvider.uploadImages(
            propertyId,
            paths,
            primaryIndex: _primaryPhotoIndex,
            caption: _photoCaptionController.text.trim().isEmpty
                ? null
                : _photoCaptionController.text.trim(),
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de l\'upload des photos: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditMode
              ? 'Propriété modifiée avec succès'
              : 'Propriété créée avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(propertyProvider.error ??
              (widget.isEditMode
                  ? 'Erreur de modification'
                  : 'Erreur de création')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.isEditMode
            ? 'Modifier la propriété'
            : 'Ajouter une propriété'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProperty,
            child: Text(widget.isEditMode ? 'Modifier' : 'Publier'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informations de base
                _buildSection(
                  context,
                  title: 'Informations de base',
                  children: [
                    CustomTextField(
                      controller: _titleController,
                      label: 'Titre de l\'annonce',
                      hint: 'Ex: Appartement 3 chambres avec balcon',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un titre';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Type d\'annonce',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'for_rent',
                          label: Text('À louer'),
                          icon: Icon(Icons.vpn_key_outlined, size: 18),
                        ),
                        ButtonSegment<String>(
                          value: 'for_sale',
                          label: Text('À vendre'),
                          icon: Icon(Icons.sell_outlined, size: 18),
                        ),
                      ],
                      selected: {_listingType},
                      onSelectionChanged: (Set<String> next) {
                        setState(() => _listingType = next.first);
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _pricePerDayController,
                            label: 'Prix par jour',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.attach_money),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un prix';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Prix invalide';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _pricePerMonthController,
                            label: 'Prix par mois (optionnel)',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Un seul champ : catégorie (= type de propriété)
                    Consumer<PropertyProvider>(
                      builder: (context, propertyProvider, child) {
                        final categories = propertyProvider.categories;
                        return DropdownButtonFormField<String>(
                          value: _selectedCategory != null &&
                                  categories.any((c) => c.id == _selectedCategory)
                              ? _selectedCategory
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Catégorie / Type de propriété',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category_outlined),
                            helperText: 'Appartement, Maison, Terrain, Salle d\'événement, Véhicule...',
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                              if (value != null) {
                                Category? found;
                                for (final c in categories) {
                                  if (c.id == value) {
                                    found = c;
                                    break;
                                  }
                                }
                                if (found != null) {
                                  _selectedType = _typeFromCategory(found.name) ?? _typeFromCategory(found.slug);
                                  _resetTypeSpecificFields();
                                } else {
                                  _selectedType = null;
                                }
                              } else {
                                _selectedType = null;
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner une catégorie';
                            }
                            return null;
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Sélection de la province
                    Consumer<PropertyProvider>(
                      builder: (context, propertyProvider, child) {
                        if (propertyProvider.isLoading && propertyProvider.provinces.isEmpty) {
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Province',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            items: const [],
                            hint: const Text('Chargement...'),
                            onChanged: null,
                          );
                        }
                        
                        if (propertyProvider.error != null && propertyProvider.provinces.isEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Province',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.location_on_outlined),
                                ),
                                items: const [],
                                hint: const Text('Erreur de chargement'),
                                onChanged: null,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                propertyProvider.error!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          );
                        }
                        
                        // En mode édition : afficher la province actuelle (nom seulement, pas d'id API)
                        if (widget.isEditMode && _loadedProvinceName != null && _loadedProvinceName!.isNotEmpty) {
                          return DropdownButtonFormField<String>(
                            value: '__current__',
                            decoration: const InputDecoration(
                              labelText: 'Province',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: '__current__',
                                child: Text(_loadedProvinceName!),
                              ),
                            ],
                            onChanged: null,
                          );
                        }
                        
                        return DropdownButtonFormField<String>(
                          value: _selectedProvince != null &&
                                  propertyProvider.provinces
                                      .any((p) => p.id == _selectedProvince)
                              ? _selectedProvince
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Province',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          items: propertyProvider.provinces.map((province) {
                            return DropdownMenuItem(
                              value: province.id,
                              child: Text(province.name),
                            );
                          }).toList(),
                          onChanged: _onProvinceChanged,
                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez sélectionner une province';
                            }
                            return null;
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Ville : affichée uniquement quand une province est sélectionnée
                    if (_selectedProvince != null || _selectedCity != null) ...[
                      Consumer<PropertyProvider>(
                        builder: (context, propertyProvider, child) {
                          if (_selectedProvince != null && propertyProvider.isLoading && propertyProvider.cities.isEmpty) {
                            return DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Ville',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_city_outlined),
                              ),
                              items: const [],
                              hint: const Text('Chargement...'),
                              onChanged: null,
                            );
                          }
                          if (widget.isEditMode &&
                              _selectedCity != null &&
                              _loadedCityName != null) {
                            return DropdownButtonFormField<String>(
                              value: _selectedCity,
                              decoration: const InputDecoration(
                                labelText: 'Ville',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_city_outlined),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: _selectedCity,
                                  child: Text(_loadedCityName!),
                                ),
                              ],
                              onChanged: null,
                            );
                          }
                          return DropdownButtonFormField<String>(
                            value: _selectedCity != null &&
                                    propertyProvider.cities
                                        .any((c) => c.id == _selectedCity)
                                ? _selectedCity
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Ville',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                            items: propertyProvider.cities.map((city) {
                              return DropdownMenuItem(
                                value: city.id,
                                child: Text(city.name),
                              );
                            }).toList(),
                            onChanged: _onCityChanged,
                            validator: (value) {
                              if (value == null) {
                                return 'Veuillez sélectionner une ville';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Commune : affichée uniquement quand une ville est sélectionnée
                    if (_selectedCity != null || _selectedTown != null) ...[
                      Consumer<PropertyProvider>(
                        builder: (context, propertyProvider, child) {
                          if (_selectedCity != null && propertyProvider.isLoading && propertyProvider.towns.isEmpty) {
                            return DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Commune',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.home_outlined),
                              ),
                              items: const [],
                              hint: const Text('Chargement...'),
                              onChanged: null,
                            );
                          }
                          if (widget.isEditMode &&
                              _selectedTown != null &&
                              _loadedTownName != null) {
                            return DropdownButtonFormField<String>(
                              value: _selectedTown,
                              decoration: const InputDecoration(
                                labelText: 'Commune',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.home_outlined),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: _selectedTown,
                                  child: Text(_loadedTownName!),
                                ),
                              ],
                              onChanged: null,
                            );
                          }
                          return DropdownButtonFormField<String>(
                            value: _selectedTown != null &&
                                    propertyProvider.towns
                                        .any((t) => t.id == _selectedTown)
                                ? _selectedTown
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Commune',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.home_outlined),
                            ),
                            items: propertyProvider.towns.map((town) {
                              return DropdownMenuItem(
                                value: town.id,
                                child: Text(town.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTown = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez sélectionner une commune';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _addressController,
                      label: 'Adresse détaillée',
                      hint: 'Entrez l\'adresse complète (rue, numéro, etc.)',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une adresse détaillée';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Décrivez votre propriété...',
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _keywordsController,
                      label: 'Mots-clés (optionnel)',
                      hint: 'Ex: condo, principal, moderne',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Détails spécifiques selon le type
                if (_selectedType != null) ...[
                  if (_selectedType == 'apartment') _buildApartmentDetails(context),
                  if (_selectedType == 'house') _buildHouseDetails(context),
                  if (_selectedType == 'land') _buildLandDetails(context),
                  if (_selectedType == 'event_hall') _buildEventHallDetails(context),
                  if (_selectedType == 'car') _buildCarDetails(context),
                ] else ...[
                  _buildSection(
                    context,
                    title: 'Détails de la propriété',
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Veuillez sélectionner un type de propriété pour voir les détails',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Photos (multipart: photos[], caption, isPrimary — conforme API)
                _buildSection(
                  context,
                  title: 'Photos',
                  children: [
                    Text(
                      'JPEG, PNG, GIF ou WebP. Max 10 Mo par fichier, min. 800×600 px.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (_existingPhotos.any((p) => !_deletedPhotoIds.contains(p.id))) ...[
                      Text(
                        'Photos actuelles (appuyez sur ✕ pour supprimer)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 124,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingPhotos
                              .where((p) => !_deletedPhotoIds.contains(p.id) && (p.url ?? '').isNotEmpty)
                              .length,
                          itemBuilder: (context, index) {
                            final photo = _existingPhotos
                                .where((p) => !_deletedPhotoIds.contains(p.id) && (p.url ?? '').isNotEmpty)
                                .elementAt(index);
                            final url = photo.url!;
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: CachedNetworkImage(
                                      imageUrl: url,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => const Center(
                                          child: CircularProgressIndicator()),
                                      errorWidget: (_, __, ___) => Container(
                                        color: AppColors.grey100,
                                        child: const Icon(
                                          Icons.broken_image_outlined,
                                          size: 40,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _deletedPhotoIds.add(photo.id);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_photoFiles.isNotEmpty) ...[
                      SizedBox(
                        height: 124,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _photoFiles.length,
                          itemBuilder: (context, index) {
                            final isPrimary = index == _primaryPhotoIndex;
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isPrimary
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isPrimary ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow.withOpacity(0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: Image.file(
                                      _photoFiles[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: GestureDetector(
                                      onTap: () => _setPrimaryPhoto(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: isPrimary
                                              ? AppColors.primary
                                              : Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          isPrimary
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 20,
                                          color: isPrimary
                                              ? Colors.white
                                              : AppColors.textTertiary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: GestureDetector(
                                      onTap: () => _removePhoto(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (isPrimary)
                                    Positioned(
                                      bottom: 6,
                                      left: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Principale',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _photoCaptionController,
                        label: 'Légende des photos (optionnel)',
                        hint: 'Ex: Vue extérieure de la propriété',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                    ],
                    CustomButton(
                      text: _photoFiles.isEmpty
                          ? 'Ajouter des photos'
                          : 'Ajouter d\'autres photos',
                      onPressed: _pickPhotos,
                      fullWidth: true,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      isOutlined: _photoFiles.isNotEmpty,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Bouton de sauvegarde
                Consumer<PropertyProvider>(
                  builder: (context, propertyProvider, child) {
                    return CustomButton(
                      text: widget.isEditMode
                          ? 'Modifier la propriété'
                          : 'Publier la propriété',
                      onPressed:
                          propertyProvider.isLoading ? null : _saveProperty,
                      isLoading: propertyProvider.isLoading,
                      fullWidth: true,
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Sections spécifiques selon le type de propriété
  Widget _buildApartmentDetails(BuildContext context) {
    return Column(
      children: [
        _buildSection(
          context,
          title: 'Détails de l\'appartement',
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _bedsController,
                    label: 'Chambres',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _bathsController,
                    label: 'Salles de bain',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _areaController,
                    label: 'Surface (m²)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Surface invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _floorController,
                    label: 'Étage',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Étage invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'Équipements',
          children: [
            _buildCheckboxListTile('Ascenseur', _hasElevator, (value) {
              setState(() {
                _hasElevator = value ?? false;
              });
            }),
            _buildCheckboxListTile('Balcon', _hasBalcony, (value) {
              setState(() {
                _hasBalcony = value ?? false;
              });
            }),
            _buildCheckboxListTile('Parking', _parking, (value) {
              setState(() {
                _parking = value ?? false;
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildHouseDetails(BuildContext context) {
    return Column(
      children: [
        _buildSection(
          context,
          title: 'Détails de la maison',
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _bedsController,
                    label: 'Chambres',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _bathsController,
                    label: 'Salles de bain',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _floorsController,
              label: 'Nombre d\'étages',
              hint: '0',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Obligatoire';
                }
                if (int.tryParse(value) == null) {
                  return 'Nombre invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _houseSquareMetersController,
                    label: 'Surface habitable (m²)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Surface invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _landSquareMetersController,
                    label: 'Surface terrain (m²)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Surface invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'Équipements',
          children: [
            _buildCheckboxListTile('Jardin', _hasGarden, (value) {
              setState(() {
                _hasGarden = value ?? false;
              });
            }),
            _buildCheckboxListTile('Piscine', _hasPool, (value) {
              setState(() {
                _hasPool = value ?? false;
              });
            }),
            _buildCheckboxListTile('Garage', _hasGarage, (value) {
              setState(() {
                _hasGarage = value ?? false;
              });
            }),
            _buildCheckboxListTile('Meublé', _isFurnished, (value) {
              setState(() {
                _isFurnished = value ?? false;
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildLandDetails(BuildContext context) {
    return Column(
      children: [
        _buildSection(
          context,
          title: 'Détails du terrain',
          children: [
            CustomTextField(
              controller: _landSquareMetersController,
              label: 'Surface (m²)',
              hint: '0',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Obligatoire';
                }
                if (double.tryParse(value) == null) {
                  return 'Surface invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _landType,
              decoration: const InputDecoration(
                labelText: 'Type de terrain',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.landscape_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'residential', child: Text('Résidentiel')),
                DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
                DropdownMenuItem(value: 'agricultural', child: Text('Agricole')),
                DropdownMenuItem(value: 'industrial', child: Text('Industriel')),
              ],
              onChanged: (value) {
                setState(() {
                  _landType = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner un type';
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'Caractéristiques',
          children: [
            _buildCheckboxListTile('Accès à l\'eau', _hasWaterAccess, (value) {
              setState(() {
                _hasWaterAccess = value ?? false;
              });
            }),
            _buildCheckboxListTile('Accès à l\'électricité', _hasElectricityAccess, (value) {
              setState(() {
                _hasElectricityAccess = value ?? false;
              });
            }),
            _buildCheckboxListTile('Clôturé', _isFenced, (value) {
              setState(() {
                _isFenced = value ?? false;
              });
            }),
            _buildCheckboxListTile('Permis de construire', _hasBuildingPermit, (value) {
              setState(() {
                _hasBuildingPermit = value ?? false;
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildEventHallDetails(BuildContext context) {
    return Column(
      children: [
        _buildSection(
          context,
          title: 'Détails de la salle d\'événement',
          children: [
            CustomTextField(
              controller: _capacityController,
              label: 'Capacité (personnes)',
              hint: '0',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Obligatoire';
                }
                if (int.tryParse(value) == null) {
                  return 'Nombre invalide';
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'Équipements',
          children: [
            _buildCheckboxListTile('Système sonore', _hasSoundSystem, (value) {
              setState(() {
                _hasSoundSystem = value ?? false;
              });
            }),
            _buildCheckboxListTile('Vidéoprojecteur', _hasVideoProjector, (value) {
              setState(() {
                _hasVideoProjector = value ?? false;
              });
            }),
            _buildCheckboxListTile('Cuisine', _hasKitchen, (value) {
              setState(() {
                _hasKitchen = value ?? false;
              });
            }),
            _buildCheckboxListTile('Parking', _parking, (value) {
              setState(() {
                _parking = value ?? false;
              });
            }),
            _buildCheckboxListTile('Espace extérieur', _hasOutdoorSpace, (value) {
              setState(() {
                _hasOutdoorSpace = value ?? false;
              });
            }),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'Types d\'événements',
          children: [
            _buildCheckboxListTile('Mariage', _selectedEventTypes.contains('wedding'), (value) {
              setState(() {
                if (value == true) {
                  if (!_selectedEventTypes.contains('wedding')) {
                    _selectedEventTypes.add('wedding');
                  }
                } else {
                  _selectedEventTypes.remove('wedding');
                }
              });
            }),
            _buildCheckboxListTile('Conférence', _selectedEventTypes.contains('conference'), (value) {
              setState(() {
                if (value == true) {
                  if (!_selectedEventTypes.contains('conference')) {
                    _selectedEventTypes.add('conference');
                  }
                } else {
                  _selectedEventTypes.remove('conference');
                }
              });
            }),
            _buildCheckboxListTile('Fête', _selectedEventTypes.contains('party'), (value) {
              setState(() {
                if (value == true) {
                  if (!_selectedEventTypes.contains('party')) {
                    _selectedEventTypes.add('party');
                  }
                } else {
                  _selectedEventTypes.remove('party');
                }
              });
            }),
            _buildCheckboxListTile('Entreprise', _selectedEventTypes.contains('corporate'), (value) {
              setState(() {
                if (value == true) {
                  if (!_selectedEventTypes.contains('corporate')) {
                    _selectedEventTypes.add('corporate');
                  }
                } else {
                  _selectedEventTypes.remove('corporate');
                }
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCarDetails(BuildContext context) {
    return Column(
      children: [
        _buildSection(
          context,
          title: 'Détails du véhicule',
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _brandController,
                    label: 'Marque',
                    hint: 'Ex: Toyota',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _modelController,
                    label: 'Modèle',
                    hint: 'Ex: Land Cruiser V8',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _yearController,
                    label: 'Année',
                    hint: '2023',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Année invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _licensePlateController,
                    label: 'Plaque d\'immatriculation',
                    hint: 'KIN-1234-AB',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _seatsController,
                    label: 'Nombre de places',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _mileageController,
                    label: 'Kilométrage',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoire';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Kilométrage invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _colorController,
              label: 'Couleur',
              hint: 'Ex: Blanc',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _fuelType,
              decoration: const InputDecoration(
                labelText: 'Type de carburant',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_gas_station_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
                DropdownMenuItem(value: 'gasoline', child: Text('Essence')),
                DropdownMenuItem(value: 'electric', child: Text('Électrique')),
                DropdownMenuItem(value: 'hybrid', child: Text('Hybride')),
                DropdownMenuItem(value: 'plugin_hybrid', child: Text('Hybride rechargeable')),
              ],
              onChanged: (value) {
                setState(() {
                  _fuelType = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner un type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _transmission,
              decoration: const InputDecoration(
                labelText: 'Transmission',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'automatic', child: Text('Automatique')),
                DropdownMenuItem(value: 'manual', child: Text('Manuelle')),
                DropdownMenuItem(value: 'semi_automatic', child: Text('Semi-automatique')),
              ],
              onChanged: (value) {
                setState(() {
                  _transmission = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner un type';
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          title: 'Options',
          children: [
            _buildCheckboxListTile('Avec chauffeur', _withDriver, (value) {
              setState(() {
                _withDriver = value ?? false;
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCheckboxListTile(
      String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
