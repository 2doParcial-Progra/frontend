class Review {
  final int? id;
  final int? productId;
  final int? clientId;
  final int? rating; // 1-5
  final String? comment;
  final DateTime? createdAt;

  Review({
    this.id,
    this.productId,
    this.clientId,
    this.rating,
    this.comment,
    this.createdAt,
  });

  // Constructor desde JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int?,
      productId: json['productId'] as int?,
      clientId: json['clientId'] as int?,
      rating: json['rating'] as int?,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (productId != null) 'productId': productId,
      if (clientId != null) 'clientId': clientId,
      if (rating != null) 'rating': rating,
      if (comment != null) 'comment': comment,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  // Factory para creación (ReviewCreateDto)
  factory Review.create({
    required int productId,
    int? rating,
    String? comment,
  }) {
    return Review(
      productId: productId,
      rating: rating,
      comment: comment,
    );
  }
}