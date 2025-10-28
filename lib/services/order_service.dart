import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  // Crear orden
  Future<void> createOrder(Order order) async {
    final body = order.toCreateDto();
    await _apiService.post('/api/Orders', body);
  }

  // Obtener mis órdenes (cliente)
  Future<List<Order>> getMyOrders() async {
    const endpoint = '/api/Orders/my';
    final response = await _apiService.get(endpoint);
    return (response as List).map((json) => Order.fromJson(json)).toList();
  }

  // Obtener órdenes recibidas (empresa)
  Future<List<Order>> getReceivedOrders() async {
    const endpoint = '/api/Orders/received';
    final response = await _apiService.get(endpoint);
    return (response as List).map((json) => Order.fromJson(json)).toList();
  }

  // Actualizar status de orden
  Future<void> updateOrderStatus(int id, int status) async {
    final endpoint = '/api/Orders/$id/status';
    final body = {'status': status};
    await _apiService.patch(endpoint, body);
  }
}