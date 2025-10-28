class Product {
  final int? id;
  final int? companyId;
  final String? name;
  final String? description;
  final double? price;
  final int? stock;
  final double? avgRating;
  final int? reviewsCount;

  Product({
    this.id,
    this.companyId,
    this.name,
    this.description,
    this.price,
    this.stock,
    this.avgRating,
    this.reviewsCount,
  });

  // Constructor para crear desde JSON (respuesta de API)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      companyId: json['companyId'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      stock: json['stock'] as int?,
      avgRating: (json['avgRating'] as num?)?.toDouble(),
      reviewsCount: json['reviewsCount'] as int?,
    );
  }

  // Método para convertir a JSON (ProductDto - para respuestas)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (companyId != null) 'companyId': companyId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (stock != null) 'stock': stock,
      if (avgRating != null) 'avgRating': avgRating,
      if (reviewsCount != null) 'reviewsCount': reviewsCount,
    };
  }

  // Método para crear/actualizar producto (ProductCreateDto)
  Map<String, dynamic> toCreateJson() {
    if (name == null || description == null) {
      throw Exception('Name and description are required for ProductCreateDto');
    }
    return {
      'name': name!,
      'description': description!,
      if (price != null) 'price': price!,
      if (stock != null) 'stock': stock!,
    };
  }

  // Método para crear un Product para creación (solo campos requeridos)
  factory Product.create({
    required String name,
    required String description,
    double? price,
    int? stock,
  }) {
    return Product(
      name: name,
      description: description,
      price: price,
      stock: stock,
    );
  }
}