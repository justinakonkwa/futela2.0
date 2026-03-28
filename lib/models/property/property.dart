import '../location/address.dart';
import '../location/town.dart';
import '../location/city.dart';
import '../location/province.dart';
import '../location/country.dart';
import 'property_photo.dart';

class Property {
  final String id;
  final String type;
  /// Annonce : `for_rent` ou `for_sale` (enum backend, une seule valeur).
  final String? listingType;
  final String title;
  final String description;
  final double? pricePerDay;
  final double? pricePerMonth;
  final bool isPublished;
  final bool isActive;
  final bool isAvailable;

  // Owner info
  final String ownerId;
  final String ownerName;

  // Category info
  final String categoryId;
  final String categoryName;

  // Address
  final String addressId;
  final Address? address;

  // Usage stats
  final int viewCount;
  final double? rating;
  final int reviewCount;

  // Media
  final List<PropertyPhoto> photos;
  final int? primaryPhotoIndex;

  // Features communes (apartment)
  final int? bedrooms;
  final int? bathrooms;
  final int? floor;
  final bool hasElevator;
  final bool hasBalcony;
  final bool hasParking;
  final double? squareMeters;

  // Features spécifiques House
  final int? floors; // Pour les maisons (différent de floor pour apartment)
  final bool? hasGarden;
  final bool? hasPool;
  final bool? hasGarage;
  final double? landSquareMeters;
  final double? houseSquareMeters;
  final bool? isFurnished;

  // Features spécifiques Car
  final String? brand;
  final String? model;
  final int? year;
  final int? seats;
  final String? fuelType;
  final String? transmission;
  final int? mileage;
  final String? color;
  final bool? withDriver;

  // Features spécifiques Event Hall
  final int? capacity;
  final bool? hasSoundSystem;
  final bool? hasVideoProjector;
  final bool? hasKitchen;
  final bool? hasOutdoorSpace;
  final List<String>? eventTypes;

  // Features spécifiques Land / Terrain / Parcelle
  final String? landType; // residential, commercial, agricultural, industrial
  final bool? hasWaterAccess;
  final bool? hasElectricityAccess;
  final bool? isFenced;
  final bool? hasBuildingPermit;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.type,
    this.listingType,
    required this.title,
    required this.description,
    this.pricePerDay,
    this.pricePerMonth,
    required this.isPublished,
    required this.isActive,
    required this.isAvailable,
    required this.ownerId,
    required this.ownerName,
    required this.categoryId,
    required this.categoryName,
    required this.addressId,
    this.address,
    required this.viewCount,
    this.rating,
    required this.reviewCount,
    required this.photos,
    this.primaryPhotoIndex,
    this.bedrooms,
    this.bathrooms,
    this.floor,
    required this.hasElevator,
    required this.hasBalcony,
    required this.hasParking,
    this.squareMeters,
    // House specific
    this.floors,
    this.hasGarden,
    this.hasPool,
    this.hasGarage,
    this.landSquareMeters,
    this.houseSquareMeters,
    this.isFurnished,
    // Car specific
    this.brand,
    this.model,
    this.year,
    this.seats,
    this.fuelType,
    this.transmission,
    this.mileage,
    this.color,
    this.withDriver,
    // Event Hall specific
    this.capacity,
    this.hasSoundSystem,
    this.hasVideoProjector,
    this.hasKitchen,
    this.hasOutdoorSpace,
    this.eventTypes,
    // Land specific
    this.landType,
    this.hasWaterAccess,
    this.hasElectricityAccess,
    this.isFenced,
    this.hasBuildingPermit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      listingType: json['listingType']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble(),
      pricePerMonth: (json['pricePerMonth'] as num?)?.toDouble(),
      isPublished: json['isPublished'] is bool
          ? json['isPublished'] as bool
          : (json['isPublished']?.toString().toLowerCase() == 'true'),
      isActive: json['isActive'] is bool
          ? json['isActive'] as bool
          : (json['isActive']?.toString().toLowerCase() == 'true'),
      isAvailable: json['isAvailable'] is bool
          ? json['isAvailable'] as bool
          : (json['isAvailable']?.toString().toLowerCase() == 'true'),
      ownerId: json['ownerId']?.toString() ?? '',
      ownerName: json['ownerName']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      addressId: json['addressId']?.toString() ?? '',
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      viewCount: json['viewCount'] is int
          ? json['viewCount'] as int
          : (json['viewCount'] != null
              ? int.tryParse(json['viewCount'].toString()) ?? 0
              : 0),
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] is int
          ? json['reviewCount'] as int
          : (json['reviewCount'] != null
              ? int.tryParse(json['reviewCount'].toString()) ?? 0
              : 0),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => PropertyPhoto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      primaryPhotoIndex: json['primaryPhotoIndex'] != null
          ? (json['primaryPhotoIndex'] is int
              ? json['primaryPhotoIndex'] as int
              : (json['primaryPhotoIndex'] is String
                  ? int.tryParse(json['primaryPhotoIndex'] as String)
                  : (json['primaryPhotoIndex'] is num
                      ? (json['primaryPhotoIndex'] as num).toInt()
                      : int.tryParse(json['primaryPhotoIndex'].toString()))))
          : null,
      bedrooms: json['bedrooms'] is int
          ? json['bedrooms'] as int
          : (json['bedrooms'] != null ? int.tryParse(json['bedrooms'].toString()) : null),
      bathrooms: json['bathrooms'] is int
          ? json['bathrooms'] as int
          : (json['bathrooms'] != null ? int.tryParse(json['bathrooms'].toString()) : null),
      floor: json['floor'] is int
          ? json['floor'] as int
          : (json['floor'] != null ? int.tryParse(json['floor'].toString()) : null),
      hasElevator: json['hasElevator'] ?? false,
      hasBalcony: json['hasBalcony'] ?? false,
      hasParking: json['hasParking'] ?? false,
      squareMeters: (json['squareMeters'] as num?)?.toDouble(),
      // House specific
      floors: json['floors'] is int
          ? json['floors'] as int
          : (json['floors'] != null ? int.tryParse(json['floors'].toString()) : null),
      hasGarden: json['hasGarden'] is bool
          ? json['hasGarden'] as bool
          : (json['hasGarden']?.toString().toLowerCase() == 'true'),
      hasPool: json['hasPool'] is bool
          ? json['hasPool'] as bool
          : (json['hasPool']?.toString().toLowerCase() == 'true'),
      hasGarage: json['hasGarage'] is bool
          ? json['hasGarage'] as bool
          : (json['hasGarage']?.toString().toLowerCase() == 'true'),
      landSquareMeters: (json['landSquareMeters'] as num?)?.toDouble(),
      houseSquareMeters: (json['houseSquareMeters'] as num?)?.toDouble(),
      isFurnished: json['isFurnished'] is bool
          ? json['isFurnished'] as bool
          : (json['isFurnished']?.toString().toLowerCase() == 'true'),
      // Car specific
      brand: json['brand']?.toString(),
      model: json['model']?.toString(),
      year: json['year'] is int
          ? json['year'] as int
          : (json['year'] != null ? int.tryParse(json['year'].toString()) : null),
      seats: json['seats'] is int
          ? json['seats'] as int
          : (json['seats'] != null ? int.tryParse(json['seats'].toString()) : null),
      fuelType: json['fuelType']?.toString(),
      transmission: json['transmission']?.toString(),
      mileage: json['mileage'] is int
          ? json['mileage'] as int
          : (json['mileage'] != null ? int.tryParse(json['mileage'].toString()) : null),
      color: json['color']?.toString(),
      withDriver: json['withDriver'] is bool
          ? json['withDriver'] as bool
          : (json['withDriver']?.toString().toLowerCase() == 'true'),
      // Event Hall specific
      capacity: json['capacity'] is int
          ? json['capacity'] as int
          : (json['capacity'] != null ? int.tryParse(json['capacity'].toString()) : null),
      hasSoundSystem: json['hasSoundSystem'] is bool
          ? json['hasSoundSystem'] as bool
          : (json['hasSoundSystem']?.toString().toLowerCase() == 'true'),
      hasVideoProjector: json['hasVideoProjector'] is bool
          ? json['hasVideoProjector'] as bool
          : (json['hasVideoProjector']?.toString().toLowerCase() == 'true'),
      hasKitchen: json['hasKitchen'] is bool
          ? json['hasKitchen'] as bool
          : (json['hasKitchen']?.toString().toLowerCase() == 'true'),
      hasOutdoorSpace: json['hasOutdoorSpace'] is bool
          ? json['hasOutdoorSpace'] as bool
          : (json['hasOutdoorSpace']?.toString().toLowerCase() == 'true'),
      eventTypes: json['eventTypes'] is List
          ? (json['eventTypes'] as List).map((e) => e.toString()).toList()
          : null,
      // Land specific
      landType: json['landType']?.toString(),
      hasWaterAccess: json['hasWaterAccess'] is bool
          ? json['hasWaterAccess'] as bool
          : (json['hasWaterAccess']?.toString().toLowerCase() == 'true'),
      hasElectricityAccess: json['hasElectricityAccess'] is bool
          ? json['hasElectricityAccess'] as bool
          : (json['hasElectricityAccess']?.toString().toLowerCase() == 'true'),
      isFenced: json['isFenced'] is bool
          ? json['isFenced'] as bool
          : (json['isFenced']?.toString().toLowerCase() == 'true'),
      hasBuildingPermit: json['hasBuildingPermit'] is bool
          ? json['hasBuildingPermit'] as bool
          : (json['hasBuildingPermit']?.toString().toLowerCase() == 'true'),
      createdAt: DateTime.parse(json['createdAt'].toString()),
      updatedAt: DateTime.parse(json['updatedAt'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      if (listingType != null && listingType!.isNotEmpty) 'listingType': listingType,
      'title': title,
      'description': description,
      'pricePerDay': pricePerDay,
      'pricePerMonth': pricePerMonth,
      'isPublished': isPublished,
      'isActive': isActive,
      'isAvailable': isAvailable,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'addressId': addressId,
      'address': address?.toJson(),
      'viewCount': viewCount,
      'rating': rating,
      'reviewCount': reviewCount,
      'photos': photos.map((e) => e.toJson()).toList(),
      'primaryPhotoIndex': primaryPhotoIndex,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'floor': floor,
      'hasElevator': hasElevator,
      'hasBalcony': hasBalcony,
      'hasParking': hasParking,
      'squareMeters': squareMeters,
      'floors': floors,
      'hasGarden': hasGarden,
      'hasPool': hasPool,
      'hasGarage': hasGarage,
      'landSquareMeters': landSquareMeters,
      'houseSquareMeters': houseSquareMeters,
      'isFurnished': isFurnished,
      'brand': brand,
      'model': model,
      'year': year,
      'seats': seats,
      'fuelType': fuelType,
      'transmission': transmission,
      'mileage': mileage,
      'color': color,
      'withDriver': withDriver,
      'capacity': capacity,
      'hasSoundSystem': hasSoundSystem,
      'hasVideoProjector': hasVideoProjector,
      'hasKitchen': hasKitchen,
      'hasOutdoorSpace': hasOutdoorSpace,
      'eventTypes': eventTypes,
      'landType': landType,
      'hasWaterAccess': hasWaterAccess,
      'hasElectricityAccess': hasElectricityAccess,
      'isFenced': isFenced,
      'hasBuildingPermit': hasBuildingPermit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Compatibility Getters & Methods

  String get formattedPrice {
    final price = pricePerDay ?? pricePerMonth ?? 0;
    // Simple formatting, can use NumberFormat if dependency exists
    return '\$${price.toStringAsFixed(0)}';
  }

  String get fullAddress =>
      address?.formattedAddress ?? 'Adresse non disponible';
  String get simpleAddress =>
      address?.townName ?? address?.cityName ?? 'Ville non disponible';
  String get addressString => fullAddress; // Alias

  String get typeDisplayName {
    switch (type) {
      case 'apartment':
        return 'Appartement';
      case 'house':
        return 'Maison';
      case 'land':
        return 'Terrain';
      case 'event_hall':
        return 'Salle d\'événement';
      case 'car':
        return 'Véhicule';
      case 'for-rent':
        return 'À Louer';
      case 'for-sale':
        return 'À Vendre';
      default:
        return type;
    }
  }

  static String _normListingKey(String? s) =>
      s?.toLowerCase().replaceAll('-', '_').trim() ?? '';

  /// Valeur API pour formulaires (`for_rent` / `for_sale`).
  String get listingTypeApiValue {
    final n = _normListingKey(listingType);
    if (n == 'for_rent' || n == 'forrent') return 'for_rent';
    if (n == 'for_sale' || n == 'forsale') return 'for_sale';
    if (type == 'for-rent') return 'for_rent';
    if (type == 'for-sale') return 'for_sale';
    return 'for_rent';
  }

  bool get isListingForRent {
    final n = _normListingKey(listingType);
    if (n == 'for_rent') return true;
    if (n == 'for_sale') return false;
    return type == 'for-rent';
  }

  /// Libellé badge image carte / fiche : priorité à [listingType], sinon catégorie bâtiment.
  String get listingBadgeLabel {
    final n = _normListingKey(listingType);
    if (n == 'for_rent') return 'À louer';
    if (n == 'for_sale') return 'À vendre';
    return typeDisplayName;
  }

  /// Couleur badge : vert « à louer », sinon secondaire pour « à vendre » / autres.
  bool get listingBadgeUseRentColors {
    final n = _normListingKey(listingType);
    if (n == 'for_rent') return true;
    if (n == 'for_sale') return false;
    return type == 'for-rent';
  }

  bool get isValidated => isPublished && isActive;

  String? get cover {
    if (photos.isEmpty) return null;
    
    PropertyPhoto photo;
    // Utiliser primaryPhotoIndex si valide, sinon chercher la photo primaire, sinon la première
    if (primaryPhotoIndex != null) {
      // primaryPhotoIndex est déjà un int? après le parsing dans fromJson
      final index = primaryPhotoIndex;
      
      if (index != null && index >= 0 && index < photos.length) {
        try {
          photo = photos[index];
        } catch (e) {
          // En cas d'erreur d'index, utiliser la première photo primaire ou la première
          photo = photos.firstWhere((p) => p.isPrimary, orElse: () => photos.first);
        }
      } else {
        // Index invalide, chercher la photo primaire
        photo = photos.firstWhere((p) => p.isPrimary, orElse: () => photos.first);
      }
    } else {
      // Chercher la photo primaire, sinon prendre la première
      photo = photos.firstWhere((p) => p.isPrimary, orElse: () => photos.first);
    }
    
    // Retourner l'URL si disponible
    // Si url est null, on ne construit pas d'URL car le CDN n'est pas disponible
    // Les images doivent être servies par l'API avec une URL complète
    return photo.url?.isNotEmpty == true ? photo.url : null;
  }
  
  List<String> get images {
    // Retourner uniquement les URLs valides (non null et non vides)
    // Ne pas construire d'URLs à partir de filename car le CDN n'est pas disponible
    return photos
        .map((p) => p.url)
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .toList();
  }

  double get price => pricePerDay ?? pricePerMonth ?? 0.0;
  String get keywords => ''; // Placeholder
  Town? get town => address != null
      ? Town(
          id: address!.townId,
          name: address!.townName,
          zipCode: null,
          isActive: true,
          cityId: address!.townId, // Using townId as proxy, ideally address should have cityId
          cityName: address!.cityName,
          provinceName: address!.provinceName,
          countryName: address!.countryName,
          fullName: address!.formattedAddress,
          createdAt: address!.createdAt,
          city: City(
              id: address!.townId, // Hack: using townId as city proxy
              name: address!.cityName,
              zipCode: null,
              isActive: true,
              provinceId: 'dummy',
              provinceName: address!.provinceName,
              countryName: address!.countryName,
              createdAt: address!.createdAt,
              province: Province(
                  id: 'dummy',
                  name: address!.provinceName,
                  code: '',
                  isActive: true,
                  countryId: 'dummy',
                  countryName: address!.countryName,
                  createdAt: address!.createdAt,
                  country: Country(
                      id: 'dummy',
                      name: address!.countryName,
                      code: 'CD',
                      phoneCode: '+243',
                      isActive: true,
                      createdAt: address!.createdAt))),
        )
      : null;

  // Compatibility for apartment/house details (flattened in new model)
  PropertyDetails? get apartment => PropertyDetails(
        beds: bedrooms ?? 0,
        baths: bathrooms ?? 0,
        area: squareMeters ?? 0,
        floor: floor ?? 0,
        // Map booleans
        isFurnished: false, // Not in main fields?
        kitchen: true, // defaults
        equippedKitchen: false,
        catsAllowed: false,
        dogsAllowed: false,
        pool: false,
        balcony: hasBalcony,
        parking: hasParking,
        laundry: false,
        airConditioning: false,
        chimney: false,
        heating: false,
        barbecue: false,
      );

  PropertyDetails? get house =>
      null; // Treat as apt for simplicity or check categories

  Map<String, dynamic> get category => {
        'id': categoryId,
        'name': categoryName,
      };
}

// Helper class for compatibility
class PropertyDetails {
  final int beds;
  final int baths;
  final double area;
  final int floor;
  final bool isFurnished;
  final bool kitchen;
  final bool equippedKitchen;
  final bool catsAllowed;
  final bool dogsAllowed;
  final bool pool;
  final bool balcony;
  final bool parking;
  final bool laundry;
  final bool airConditioning;
  final bool chimney;
  final bool heating;
  final bool barbecue;
  final String areaUnit = 'm²';

  PropertyDetails({
    this.beds = 0,
    this.baths = 0,
    this.area = 0,
    this.floor = 0,
    this.isFurnished = false,
    this.kitchen = false,
    this.equippedKitchen = false,
    this.catsAllowed = false,
    this.dogsAllowed = false,
    this.pool = false,
    this.balcony = false,
    this.parking = false,
    this.laundry = false,
    this.airConditioning = false,
    this.chimney = false,
    this.heating = false,
    this.barbecue = false,
  });
}
