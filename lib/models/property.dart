import 'user.dart';

class Property {
  final String id;
  final DateTime updatedTimestamp;
  final DateTime createdTimestamp;
  final String title;
  final double price;
  final String? cover;
  final List<String>? images;
  final PropertyCategory category;
  final String address;
  final Map<String, dynamic>? location;
  final bool isValidated;
  final User owner;
  final Town town;
  final String type; // 'for-rent' or 'for-sale'
  final String description;
  final Map<String, dynamic>? attributes;
  final String keywords;
  final ApartmentDetails? apartment;
  final HouseDetails? house;

  Property({
    required this.id,
    required this.updatedTimestamp,
    required this.createdTimestamp,
    required this.title,
    required this.price,
    this.cover,
    this.images,
    required this.category,
    required this.address,
    this.location,
    required this.isValidated,
    required this.owner,
    required this.town,
    required this.type,
    required this.description,
    this.attributes,
    required this.keywords,
    this.apartment,
    this.house,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      updatedTimestamp: DateTime.parse(json['updatedTimestamp'] ?? DateTime.now().toIso8601String()),
      createdTimestamp: DateTime.parse(json['createdTimestamp'] ?? DateTime.now().toIso8601String()),
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      cover: json['cover'],
      images: (json['images'] is List)
          ? (json['images'] as List).whereType<String>().toList()
          : null,
      category: PropertyCategory.fromJson(json['category'] ?? {}),
      address: json['address'] ?? '',
      location: json['location'],
      isValidated: json['isValidated'] ?? false,
      owner: User.fromJson(json['owner'] ?? {}),
      town: Town.fromJson(json['town'] ?? {}),
      type: json['type'] ?? 'for-rent',
      description: json['description'] ?? '',
      attributes: json['attributes'],
      keywords: json['keywords'] ?? '',
      apartment: json['apartment'] != null ? ApartmentDetails.fromJson(json['apartment']) : null,
      house: json['house'] != null ? HouseDetails.fromJson(json['house']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'updatedTimestamp': updatedTimestamp.toIso8601String(),
      'createdTimestamp': createdTimestamp.toIso8601String(),
      'title': title,
      'price': price,
      'cover': cover,
      'images': images,
      'category': category.toJson(),
      'address': address,
      'location': location,
      'isValidated': isValidated,
      'owner': owner.toJson(),
      'town': town.toJson(),
      'type': type,
      'description': description,
      'attributes': attributes,
      'keywords': keywords,
      'apartment': apartment?.toJson(),
      'house': house?.toJson(),
    };
  }

  String get formattedPrice {
    return '${price.toStringAsFixed(0)} \$';
  }

  String get typeDisplayName {
    return type == 'for-rent' ? 'À louer' : 'À vendre';
  }

  String get fullAddress {
    // Si l'adresse est vide ou ne contient que "string", construire l'adresse à partir de la localisation
    if (address.isEmpty || address.toLowerCase() == 'string') {
      // Vérifier si les noms sont disponibles, sinon utiliser les IDs
      final townName = town.name.isNotEmpty ? town.name : 'Ville inconnue';
      final cityName = town.city.name.isNotEmpty ? town.city.name : 'Ville inconnue';
      final provinceName = town.city.province.name.isNotEmpty ? town.city.province.name : 'Province inconnue';
      
      return '$townName, $cityName, $provinceName';
    }
    return address;
  }

}

class PropertyCategory {
  final String id;
  final DateTime updatedTimestamp;
  final DateTime createdTimestamp;
  final String name;

  PropertyCategory({
    required this.id,
    required this.updatedTimestamp,
    required this.createdTimestamp,
    required this.name,
  });

  factory PropertyCategory.fromJson(Map<String, dynamic> json) {
    return PropertyCategory(
      id: json['id'] ?? '',
      updatedTimestamp: DateTime.parse(json['updatedTimestamp'] ?? DateTime.now().toIso8601String()),
      createdTimestamp: DateTime.parse(json['createdTimestamp'] ?? DateTime.now().toIso8601String()),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'updatedTimestamp': updatedTimestamp.toIso8601String(),
      'createdTimestamp': createdTimestamp.toIso8601String(),
      'name': name,
    };
  }
}

class Town {
  final String id;
  final City city;
  final String name;

  Town({
    required this.id,
    required this.city,
    required this.name,
  });

  factory Town.fromJson(Map<String, dynamic> json) {
    return Town(
      id: json['id'] ?? '',
      city: City.fromJson(json['city'] ?? {}),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city.toJson(),
      'name': name,
    };
  }
}

class City {
  final String id;
  final Province province;
  final String name;

  City({
    required this.id,
    required this.province,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? '',
      province: Province.fromJson(json['province'] ?? {}),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'province': province.toJson(),
      'name': name,
    };
  }
}

class Province {
  final String id;
  final String name;

  Province({
    required this.id,
    required this.name,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ApartmentDetails {
  final int beds;
  final int baths;
  final bool kitchen;
  final bool equippedKitchen;
  final bool catsAllowed;
  final bool dogsAllowed;
  final int petsLimit;
  final bool pool;
  final bool balcony;
  final bool parking;
  final bool laundry;
  final bool airConditioning;
  final bool chimney;
  final bool heating;
  final bool barbecue;
  final bool isFurnished;
  final double area;
  final String areaUnit;
  final int floor;

  ApartmentDetails({
    required this.beds,
    required this.baths,
    required this.kitchen,
    required this.equippedKitchen,
    required this.catsAllowed,
    required this.dogsAllowed,
    required this.petsLimit,
    required this.pool,
    required this.balcony,
    required this.parking,
    required this.laundry,
    required this.airConditioning,
    required this.chimney,
    required this.heating,
    required this.barbecue,
    required this.isFurnished,
    required this.area,
    required this.areaUnit,
    required this.floor,
  });

  factory ApartmentDetails.fromJson(Map<String, dynamic> json) {
    return ApartmentDetails(
      beds: json['beds'] ?? 0,
      baths: json['baths'] ?? 0,
      kitchen: json['kitchen'] ?? false,
      equippedKitchen: json['equippedKitchen'] ?? false,
      catsAllowed: json['catsAllowed'] ?? false,
      dogsAllowed: json['dogsAllowed'] ?? false,
      petsLimit: json['petsLimit'] ?? 0,
      pool: json['pool'] ?? false,
      balcony: json['balcony'] ?? false,
      parking: json['parking'] ?? false,
      laundry: json['laundry'] ?? false,
      airConditioning: json['airConditioning'] ?? false,
      chimney: json['chimney'] ?? false,
      heating: json['heating'] ?? false,
      barbecue: json['barbecue'] ?? false,
      isFurnished: json['isFurnished'] ?? false,
      area: (json['area'] ?? 0).toDouble(),
      areaUnit: json['areaUnit'] ?? 'm²',
      floor: json['floor'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beds': beds,
      'baths': baths,
      'kitchen': kitchen,
      'equippedKitchen': equippedKitchen,
      'catsAllowed': catsAllowed,
      'dogsAllowed': dogsAllowed,
      'petsLimit': petsLimit,
      'pool': pool,
      'balcony': balcony,
      'parking': parking,
      'laundry': laundry,
      'airConditioning': airConditioning,
      'chimney': chimney,
      'heating': heating,
      'barbecue': barbecue,
      'isFurnished': isFurnished,
      'area': area,
      'areaUnit': areaUnit,
      'floor': floor,
    };
  }
}

class HouseDetails {
  final int beds;
  final int baths;
  final bool kitchen;
  final bool equippedKitchen;
  final bool pool;
  final bool parking;
  final bool laundry;
  final bool airConditioning;
  final bool chimney;
  final bool heating;
  final bool barbecue;
  final bool isFurnished;
  final double area;
  final String areaUnit;
  final int floor;

  HouseDetails({
    required this.beds,
    required this.baths,
    required this.kitchen,
    required this.equippedKitchen,
    required this.pool,
    required this.parking,
    required this.laundry,
    required this.airConditioning,
    required this.chimney,
    required this.heating,
    required this.barbecue,
    required this.isFurnished,
    required this.area,
    required this.areaUnit,
    required this.floor,
  });

  factory HouseDetails.fromJson(Map<String, dynamic> json) {
    return HouseDetails(
      beds: json['beds'] ?? 0,
      baths: json['baths'] ?? 0,
      kitchen: json['kitchen'] ?? false,
      equippedKitchen: json['equippedKitchen'] ?? false,
      pool: json['pool'] ?? false,
      parking: json['parking'] ?? false,
      laundry: json['laundry'] ?? false,
      airConditioning: json['airConditioning'] ?? false,
      chimney: json['chimney'] ?? false,
      heating: json['heating'] ?? false,
      barbecue: json['barbecue'] ?? false,
      isFurnished: json['isFurnished'] ?? false,
      area: (json['area'] ?? 0).toDouble(),
      areaUnit: json['areaUnit'] ?? 'm²',
      floor: json['floor'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beds': beds,
      'baths': baths,
      'kitchen': kitchen,
      'equippedKitchen': equippedKitchen,
      'pool': pool,
      'parking': parking,
      'laundry': laundry,
      'airConditioning': airConditioning,
      'chimney': chimney,
      'heating': heating,
      'barbecue': barbecue,
      'isFurnished': isFurnished,
      'area': area,
      'areaUnit': areaUnit,
      'floor': floor,
    };
  }
}
