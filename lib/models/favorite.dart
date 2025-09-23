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
    final dynamic rawProperty = json['property'];
    final dynamic rawList = json['list'];
    return ListProperty(
      property: Property.fromJson(
        (rawProperty is Map<String, dynamic>) ? rawProperty : <String, dynamic>{},
      ),
      list: FavoriteList.fromJson(
        (rawList is Map<String, dynamic>) ? rawList : <String, dynamic>{},
      ),
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
    final String id = json['id'] ?? '';
    final String? createdStr = json['createdTimestamp'];
    final String? updatedStr = json['updatedTimestamp'];
    final DateTime createdTs = _tryParseDate(createdStr) ?? DateTime.now();
    final DateTime updatedTs = _tryParseDate(updatedStr) ?? createdTs;
    final dynamic rawUser = json['user'];
    return FavoriteList(
      id: id,
      createdTimestamp: createdTs,
      updatedTimestamp: updatedTs,
      name: json['name'] ?? '',
      user: FavoriteUser.fromJson(
        (rawUser is Map<String, dynamic>) ? rawUser : <String, dynamic>{},
      ),
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

DateTime? _tryParseDate(String? value) {
  if (value == null) return null;
  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
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
    final dynamic rawMeta = json['metaData'];
    final Map<String, dynamic> safeMeta =
        (rawMeta is Map<String, dynamic>) ? rawMeta : <String, dynamic>{};

    final dynamic rawList = json['listProperties'];
    final List<dynamic> safeList = (rawList is List) ? rawList : const <dynamic>[];

    return FavoritesResponse(
      metaData: safeMeta,
      listProperties: safeList
          .whereType<Map<String, dynamic>>()
          .map((item) => ListProperty.fromJson(item))
          .toList(),
    );
  }
}


