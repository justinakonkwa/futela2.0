class PropertyReview {
  final String id;
  final String propertyId;
  final String? propertyTitle;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String? title;
  final String? comment;
  final bool wouldRecommend;
  final String? status;
  final DateTime createdAt;

  PropertyReview({
    required this.id,
    required this.propertyId,
    this.propertyTitle,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.title,
    this.comment,
    required this.wouldRecommend,
    this.status,
    required this.createdAt,
  });

  factory PropertyReview.fromJson(Map<String, dynamic> json) {
    return PropertyReview(
      id: json['id']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      propertyTitle: json['propertyTitle']?.toString(),
      // L'API retourne reviewerId/reviewerName
      userId: (json['reviewerId'] ?? json['userId'])?.toString() ?? '',
      userName: (json['reviewerName'] ?? json['userName'])?.toString() ?? 'Utilisateur',
      userAvatar: json['userAvatar']?.toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString(),
      comment: json['comment']?.toString(),
      wouldRecommend: json['wouldRecommend'] as bool? ?? false,
      status: json['status']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
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
    final ratingDist = json['ratingDistribution'];
    final Map<int, int> distribution = {};
    if (ratingDist is Map) {
      ratingDist.forEach((key, value) {
        final k = int.tryParse(key.toString());
        if (k != null) distribution[k] = (value as num?)?.toInt() ?? 0;
      });
    }

    return ReviewStats(
      propertyId: json['propertyId']?.toString() ?? '',
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      ratingDistribution: distribution,
      recommendationRate: (json['recommendationRate'] as num?)?.toInt() ?? 0,
      topPros: (json['topPros'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      topCons: (json['topCons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
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
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      itemsPerPage: (json['itemsPerPage'] as num?)?.toInt() ?? 30,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Depuis une liste directe (quand l'API retourne [] au lieu de {member: []})
  factory ReviewsResponse.fromList(List<dynamic> list) {
    final reviews = list
        .whereType<Map<String, dynamic>>()
        .map((e) => PropertyReview.fromJson(e))
        .toList();
    return ReviewsResponse(
      reviews: reviews,
      totalItems: reviews.length,
      page: 1,
      itemsPerPage: 30,
      totalPages: reviews.isEmpty ? 0 : 1,
      averageRating: reviews.isEmpty
          ? 0.0
          : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length,
    );
  }
}
