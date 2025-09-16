import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/property_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _keywordsController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedType = 'for-rent';
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedTown;
  
  // Images
  List<File> _selectedImages = [];
  File? _coverImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Détails appartement
  final _bedsController = TextEditingController();
  final _bathsController = TextEditingController();
  final _areaController = TextEditingController();
  final _floorController = TextEditingController();
  
  bool _kitchen = false;
  bool _equippedKitchen = false;
  bool _catsAllowed = false;
  bool _dogsAllowed = false;
  bool _pool = false;
  bool _balcony = false;
  bool _parking = false;
  bool _laundry = false;
  bool _airConditioning = false;
  bool _chimney = false;
  bool _heating = false;
  bool _barbecue = false;
  bool _isFurnished = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _keywordsController.dispose();
    _bedsController.dispose();
    _bathsController.dispose();
    _areaController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    
    propertyProvider.loadCategories();
    propertyProvider.loadProvinces();
  }

  void _onProvinceChanged(String? provinceId) {
    setState(() {
      _selectedProvince = provinceId;
      _selectedCity = null; // Reset city when province changes
      _selectedTown = null; // Reset town when province changes
    });
    
    if (provinceId != null) {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      propertyProvider.loadCities(province: provinceId);
    }
  }

  void _onCityChanged(String? cityId) {
    setState(() {
      _selectedCity = cityId;
      _selectedTown = null; // Reset town when city changes
    });
    
    if (cityId != null) {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      propertyProvider.loadTowns(city: cityId);
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 70, // compresser
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images.map((image) => File(image.path)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection des images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (image != null) {
        setState(() {
          _coverImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image de couverture: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeCoverImage() {
    setState(() {
      _coverImage = null;
    });
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ownerId = authProvider.user?.id;

    if (ownerId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur non authentifié. Veuillez vous reconnecter.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    
    // Essayer d'abord avec les IDs simples
    final propertyData = {
      'title': _titleController.text.trim(),
      'price': double.parse(_priceController.text),
      'category': _selectedCategory,
      'address': _addressController.text.trim(),
      'owner': ownerId,
      'town': _selectedTown,
      'type': _selectedType,
      'description': _descriptionController.text.trim(),
      'keywords': _keywordsController.text.trim(),
      'apartment': {
        'beds': int.parse(_bedsController.text),
        'baths': int.parse(_bathsController.text),
        'kitchen': _kitchen,
        'equippedKitchen': _equippedKitchen,
        'catsAllowed': _catsAllowed,
        'dogsAllowed': _dogsAllowed,
        'petsLimit': 0,
        'pool': _pool,
        'balcony': _balcony,
        'parking': _parking,
        'laundry': _laundry,
        'airConditioning': _airConditioning,
        'chimney': _chimney,
        'heating': _heating,
        'barbecue': _barbecue,
        'isFurnished': _isFurnished,
        'area': double.parse(_areaController.text),
        'areaUnit': 'square meter',
        'floor': int.parse(_floorController.text),
      },
    };

    // Debug: Afficher les données avant envoi
    print('🔍 PROPERTY DATA TO SEND:');
    print('Title: ${propertyData['title']}');
    print('Price: ${propertyData['price']}');
    print('Category: ${propertyData['category']}');
    print('Town: ${propertyData['town']}');
    print('Type: ${propertyData['type']}');
    print('Address: ${propertyData['address']}');
    print('Description: ${propertyData['description']}');
    print('Keywords: ${propertyData['keywords']}');
    print('Apartment: ${propertyData['apartment']}');

    final propertyId = await propertyProvider.createProperty(propertyData);
    
    if (propertyId != null && mounted) {
      // Upload des images si elles existent
      if (_selectedImages.isNotEmpty) {
        try {
          final imagePaths = _selectedImages.map((image) => image.path).toList();
          await propertyProvider.uploadImages(propertyId, imagePaths);
        } catch (e) {
          print('Erreur upload images: $e');
        }
      }
      
      // Upload de l'image de couverture si elle existe
      if (_coverImage != null) {
        try {
          await propertyProvider.uploadCoverImage(propertyId, _coverImage!.path);
        } catch (e) {
          print('Erreur upload image de couverture: $e');
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Propriété créée avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(propertyProvider.error ?? 'Erreur de création'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ajouter une propriété'),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProperty,
            child: const Text('Publier'),
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
                    
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _priceController,
                            label: 'Prix',
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
                          child: Consumer<PropertyProvider>(
                            builder: (context, propertyProvider, child) {
                              return DropdownButtonFormField<String>(
                                value: _selectedType,
                                decoration: const InputDecoration(
                                  labelText: 'Type',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'for-rent',
                                    child: Text('À louer'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'for-sale',
                                    child: Text('À vendre'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Consumer<PropertyProvider>(
                      builder: (context, propertyProvider, child) {
                        return DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Catégorie',
                            border: OutlineInputBorder(),
                          ),
                          items: propertyProvider.categories.map((category) {
                            return DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
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
                        return DropdownButtonFormField<String>(
                          value: _selectedProvince,
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
                    
                    // Sélection de la ville
                    Consumer<PropertyProvider>(
                      builder: (context, propertyProvider, child) {
                        return DropdownButtonFormField<String>(
                          value: _selectedCity,
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
                    
                    // Sélection de la commune
                    Consumer<PropertyProvider>(
                      builder: (context, propertyProvider, child) {
                        return DropdownButtonFormField<String>(
                          value: _selectedTown,
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
                            if (value == null) {
                              return 'Veuillez sélectionner une commune';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    
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
                
                // Détails de la propriété
                _buildSection(
                  context,
                  title: 'Détails de la propriété',
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
                
                // Équipements
                _buildSection(
                  context,
                  title: 'Équipements',
                  children: [
                    _buildCheckboxListTile('Cuisine', _kitchen, (value) {
                      setState(() {
                        _kitchen = value ?? false;
                      });
                    }),
                    _buildCheckboxListTile('Cuisine équipée', _equippedKitchen, (value) {
                      setState(() {
                        _equippedKitchen = value ?? false;
                      });
                    }),
                    _buildCheckboxListTile('Piscine', _pool, (value) {
                      setState(() {
                        _pool = value ?? false;
                      });
                    }),
                    _buildCheckboxListTile('Balcon', _balcony, (value) {
                      setState(() {
                        _balcony = value ?? false;
                      });
                    }),
                    _buildCheckboxListTile('Parking', _parking, (value) {
                      setState(() {
                        _parking = value ?? false;
                      });
                    }),
                    _buildCheckboxListTile('Lave-linge', _laundry, (value) {
                      setState(() {
                        _laundry = value ?? false;
                      });
                    }),
                    _buildCheckboxListTile('Climatisation', _airConditioning, (value) {
                      setState(() {
                        _airConditioning = value ?? false;
                      });
                    }),
                    _buildCheckboxListTile('Cheminée', _chimney, (value) {
                      setState(() {
                        _chimney = value ?? false;
                      });
                    }),
                    _buildCheckboxListTile('Chauffage', _heating, (value) {
                      setState(() {
                        _heating = value ?? false;
                      });
                    }),
                    _buildCheckboxListTile('Barbecue', _barbecue, (value) {
                      setState(() {
                        _barbecue = value ?? false;
                      });
                    }),
                    _buildCheckboxListTile('Meublé', _isFurnished, (value) {
                      setState(() {
                        _isFurnished = value ?? false;
                      });
                    }),
                    _buildCheckboxListTile('Chats autorisés', _catsAllowed, (value) {
                      setState(() {
                        _catsAllowed = value ?? false;
                      });
                    }),
                    _buildCheckboxListTile('Chiens autorisés', _dogsAllowed, (value) {
                      setState(() {
                        _dogsAllowed = value ?? false;
                      });
                    }),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Images
                _buildSection(
                  context,
                  title: 'Images',
                  children: [
                    // Image de couverture
                    if (_coverImage != null) ...[
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                _coverImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.white),
                                  onPressed: _removeCoverImage,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Image de couverture',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Bouton pour sélectionner l'image de couverture
                    if (_coverImage == null)
                      CustomButton(
                        text: 'Sélectionner une image de couverture',
                        onPressed: _pickCoverImage,
                        fullWidth: true,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Images supplémentaires
                    if (_selectedImages.isNotEmpty) ...[
                      Text(
                        'Images supplémentaires (${_selectedImages.length})',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(
                                      _selectedImages[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: AppColors.white, size: 16),
                                        onPressed: () => _removeImage(index),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 24,
                                          minHeight: 24,
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
                      const SizedBox(height: 16),
                    ],
                    
                    // Bouton pour ajouter des images supplémentaires
                    CustomButton(
                      text: 'Ajouter des images supplémentaires',
                      onPressed: _pickImages,
                      fullWidth: true,
                      icon: const Icon(Icons.photo_library_outlined),
                      isOutlined: true,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Bouton de sauvegarde
                Consumer<PropertyProvider>(
                  builder: (context, propertyProvider, child) {
                    return CustomButton(
                      text: 'Publier la propriété',
                      onPressed: propertyProvider.isLoading ? null : _saveProperty,
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

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
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

  Widget _buildCheckboxListTile(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
