import 'property.dart';

class FavoriteRequest {
  final String property;
  final String list;

  FavoriteRequest({
    required this.property,
    required this.list,
  });

  Map<String, dynamic> toJson() {
    return {
      'property': property,
      'list': list,
    };
  }
}

class ListProperty {
  final Property property;
  final FavoriteList list;

  ListProperty({
    required this.property,
    required this.list,
  });

  factory ListProperty.fromJson(Map<String, dynamic> json) {
    return ListProperty(
      property: Property.fromJson(json['property']),
      list: FavoriteList.fromJson(json['list']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property': property.toJson(),
      'list': list.toJson(),
    };
  }
}

class FavoriteList {
  final String id;
  final DateTime createdTimestamp;
  final DateTime updatedTimestamp;
  final String name;
  final FavoriteUser user;

  FavoriteList({
    required this.id,
    required this.createdTimestamp,
    required this.updatedTimestamp,
    required this.name,
    required this.user,
  });

  factory FavoriteList.fromJson(Map<String, dynamic> json) {
    return FavoriteList(
      id: json['id'] ?? '',
      createdTimestamp: DateTime.parse(json['createdTimestamp']),
      updatedTimestamp: DateTime.parse(json['updatedTimestamp']),
      name: json['name'] ?? '',
      user: FavoriteUser.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdTimestamp': createdTimestamp.toIso8601String(),
      'updatedTimestamp': updatedTimestamp.toIso8601String(),
      'name': name,
      'user': user.toJson(),
    };
  }
}

class FavoriteUser {
  final String id;

  FavoriteUser({
    required this.id,
  });

  factory FavoriteUser.fromJson(Map<String, dynamic> json) {
    return FavoriteUser(
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class FavoritesResponse {
  final Map<String, dynamic> metaData;
  final List<ListProperty> listProperties;

  FavoritesResponse({
    required this.metaData,
    required this.listProperties,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse(
      metaData: json['metaData'] ?? {},
      listProperties: (json['listProperties'] as List?)
          ?.map((item) => ListProperty.fromJson(item))
          .toList() ?? [],
    );
  }
}
