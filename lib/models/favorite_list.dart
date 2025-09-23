class FavoriteList {
  final String id;
  final DateTime updatedTimestamp;
  final DateTime createdTimestamp;
  final String name;
  final String userId;

  FavoriteList({
    required this.id,
    required this.updatedTimestamp,
    required this.createdTimestamp,
    required this.name,
    required this.userId,
  });

  factory FavoriteList.fromJson(Map<String, dynamic> json) {
    return FavoriteList(
      id: json['id'] ?? '',
      updatedTimestamp: DateTime.parse(json['updatedTimestamp'] ?? DateTime.now().toIso8601String()),
      createdTimestamp: DateTime.parse(json['createdTimestamp'] ?? DateTime.now().toIso8601String()),
      name: json['name'] ?? '',
      userId: json['user']?['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'updatedTimestamp': updatedTimestamp.toIso8601String(),
      'createdTimestamp': createdTimestamp.toIso8601String(),
      'name': name,
      'user': {
        'id': userId,
      },
    };
  }
}

class FavoriteListResponse {
  final List<FavoriteList> lists;
  final FavoriteListMetaData metaData;

  FavoriteListResponse({
    required this.lists,
    required this.metaData,
  });

  factory FavoriteListResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteListResponse(
      lists: (json['lists'] as List?)
          ?.map((item) => FavoriteList.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      metaData: FavoriteListMetaData.fromJson(json['metaData'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lists': lists.map((list) => list.toJson()).toList(),
      'metaData': metaData.toJson(),
    };
  }
}

class FavoriteListMetaData {
  final String? nextCursor;
  final String? prevCursor;
  final int total;
  final int limit;

  FavoriteListMetaData({
    this.nextCursor,
    this.prevCursor,
    required this.total,
    required this.limit,
  });

  factory FavoriteListMetaData.fromJson(Map<String, dynamic> json) {
    return FavoriteListMetaData(
      nextCursor: json['nextCursor'],
      prevCursor: json['prevCursor'],
      total: json['total'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nextCursor': nextCursor,
      'prevCursor': prevCursor,
      'total': total,
      'limit': limit,
    };
  }
}

class SavePropertyToFavoriteRequest {
  final String property;
  final String list;

  SavePropertyToFavoriteRequest({
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

