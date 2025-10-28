import '../models/product.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  // Obtener lista de productos (con filtros opcionales)
  Future<List<Product>> getProducts({
    int? companyId,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, String>{};
    if (companyId != null) queryParams['companyId'] = companyId.toString();
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();

    final endpoint = '/api/Products?${Uri(queryParameters: queryParams).query}';
    final response = await _apiService.get(endpoint);
    return (response as List).map((json) => Product.fromJson(json)).toList();
  }

  // Obtener producto por ID
  Future<Product> getProductById(int id) async {
    final endpoint = '/api/Products/$id';
    final response = await _apiService.get(endpoint);
    return Product.fromJson(response);
  }

  // Crear producto
  Future<Product> createProduct(Product product) async {
    try {
      print('Creating product with data: ${product.toCreateJson()}'); // Debug
      final body = product.toCreateJson();
      final response = await _apiService.post('/api/Products', body);
      print('API Response: $response'); // Debug
      return Product.fromJson(response);
    } catch (e) {
      print('Error creating product: $e'); // Debug
      rethrow;
    }
  }

  // Actualizar producto
  Future<void> updateProduct(int id, Product product) async {
    final endpoint = '/api/Products/$id';
    final body = product.toCreateJson(); // Usar el formato de ProductCreateDto
    await _apiService.put(endpoint, body);
  }

  // Eliminar producto
  Future<void> deleteProduct(int id) async {
    final endpoint = '${Constants.products}/$id';
    await _apiService.delete(endpoint);
  }
}