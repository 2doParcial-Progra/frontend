// import 'order_item.dart'; // Importa el modelo de item si es necesario (definido a continuación)

class Order {
  final int? id;
  final int? clientId;
  final int? companyId;
  final DateTime? createdAt;
  final int? status; // Usando int para OrderStatus (enum 0-3)
  final List<OrderItem>? items;

  Order({
    this.id,
    this.clientId,
    this.companyId,
    this.createdAt,
    this.status,
    this.items,
  });

  // Constructor desde JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int?,
      clientId: json['clientId'] as int?,
      companyId: json['companyId'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      status: json['status'] as int?,
      items: json['items'] != null
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
          : null,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (clientId != null) 'clientId': clientId,
      if (companyId != null) 'companyId': companyId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (status != null) 'status': status,
      if (items != null) 'items': items!.map((i) => i.toJson()).toList(),
    };
  }

  // Factory para creación (OrderCreateDto)
  factory Order.create({
    required int companyId,
    required List<OrderItem> items,
  }) {
    return Order(
      companyId: companyId,
      items: items,
    );
  }
  
  // Convertir a OrderCreateDto para la API
  Map<String, dynamic> toCreateDto() {
    if (companyId == null || items == null) {
      throw Exception('companyId y items son requeridos para crear una orden');
    }
    return {
      'companyId': companyId!,
      'items': items!.map((i) => i.toJson()).toList(),
    };
  }
}

// Modelo auxiliar para OrderItem (basado en OrderItemDto y OrderItemRequestDto)
class OrderItem {
  final int? productId;
  final String? productName;
  final int? quantity;
  final double? unitPrice;

  OrderItem({
    this.productId,
    this.productName,
    this.quantity,
    this.unitPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as int?,
      productName: json['productName'] as String?,
      quantity: json['quantity'] as int?,
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (productId != null) 'productId': productId,
      if (productName != null) 'productName': productName,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unitPrice': unitPrice,
    };
  }

  // Para request (OrderItemRequestDto)
  factory OrderItem.request({
    required int productId,
    int quantity = 1,
  }) {
    return OrderItem(
      productId: productId,
      quantity: quantity,
    );
  }
}