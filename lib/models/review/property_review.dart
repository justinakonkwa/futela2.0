class PropertyReview {
  final String id;
  final String propertyId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String? comment;
  final List<String> pros;
  final List<String> cons;
  final bool wouldRecommend;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PropertyReview({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    required this.pros,
    required this.cons,
    required this.wouldRecommend,
    required this.createdAt,
    this.updatedAt,
  });

  factory PropertyReview.fromJson(Map<String, dynamic> json) {
    return PropertyReview(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? 'Utilisateur',
      userAvatar: json['userAvatar'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      pros: (json['pros'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      cons: (json['cons'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      wouldRecommend: json['wouldRecommend'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'pros': pros,
      'cons': cons,
      'wouldRecommend': wouldRecommend,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ReviewStats {
  final String propertyId;
  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingDistribution;
  final int recommendationRate;
  final List<String> topPros;
  final List<String> topCons;

  ReviewStats({
    required this.propertyId,
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.recommendationRate,
    required this.topPros,
    required this.topCons,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    final ratingDist = json['ratingDistribution'] as Map<String, dynamic>? ?? {};
    final Map<int, int> distribution = {};
    ratingDist.forEach((key, value) {
      distribution[int.parse(key)] = value as int;
    });

    return ReviewStats(
      propertyId: json['propertyId'] as String,
      totalReviews: json['totalReviews'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingDistribution: distribution,
      recommendationRate: json['recommendationRate'] as int? ?? 0,
      topPros: (json['topPros'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      topCons: (json['topCons'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class ReviewsResponse {
  final List<PropertyReview> reviews;
  final int totalItems;
  final int page;
  final int itemsPerPage;
  final int totalPages;
  final double averageRating;

  ReviewsResponse({
    required this.reviews,
    required this.totalItems,
    required this.page,
    required this.itemsPerPage,
    required this.totalPages,
    required this.averageRating,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    final member = json['member'] as List<dynamic>? ?? [];
    return ReviewsResponse(
      reviews: member.map((e) => PropertyReview.fromJson(e as Map<String, dynamic>)).toList(),
      totalItems: json['totalItems'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      itemsPerPage: json['itemsPerPage'] as int? ?? 30,
      totalPages: json['totalPages'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
