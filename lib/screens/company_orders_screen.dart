import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class CompanyOrdersScreen extends StatefulWidget {
  const CompanyOrdersScreen({super.key});

  @override
  State<CompanyOrdersScreen> createState() => _CompanyOrdersScreenState();
}

class _CompanyOrdersScreenState extends State<CompanyOrdersScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final orders = await _orderService.getReceivedOrders();
      
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Nuevo';
      case 1:
        return 'Enviado';
      case 2:
        return 'Entregado';
      case 3:
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateOrderStatus(Order order, int newStatus) async {
    try {
      await _orderService.updateOrderStatus(order.id!, newStatus);
      await _loadOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado actualizado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos Recibidos'),
        backgroundColor: const Color(0xFF8B4513),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrders,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? const Center(child: Text('No hay pedidos recibidos'))
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ExpansionTile(
                              title: Text('Pedido #${order.id}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fecha: ${order.createdAt?.toLocal().toString().split('.')[0] ?? 'N/A'}'),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(order.status ?? 0),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getStatusText(order.status ?? 0),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const Spacer(),
                                      // Botones de acción rápida según el estado actual
                                      if (order.status == 0) ...[
                                        // Para pedidos nuevos
                                        TextButton.icon(
                                          onPressed: () => _updateOrderStatus(order, 1),
                                          icon: const Icon(Icons.check_circle, color: Colors.green),
                                          label: const Text('Aceptar', style: TextStyle(color: Colors.green)),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => _updateOrderStatus(order, 3),
                                          icon: const Icon(Icons.cancel, color: Colors.red),
                                          label: const Text('Rechazar', style: TextStyle(color: Colors.red)),
                                        ),
                                      ] else if (order.status == 1) ...[
                                        // Para pedidos enviados
                                        TextButton.icon(
                                          onPressed: () => _updateOrderStatus(order, 2),
                                          icon: const Icon(Icons.delivery_dining, color: Colors.green),
                                          label: const Text('Marcar Entregado', style: TextStyle(color: Colors.green)),
                                        ),
                                      ],
                                      // Menú con todas las opciones
                                      IconButton(
                                        icon: const Icon(Icons.more_vert),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Cambiar Estado'),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    enabled: order.status != 0,
                                                    leading: const Icon(Icons.fiber_new),
                                                    title: const Text('Nuevo'),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _updateOrderStatus(order, 0);
                                                    },
                                                  ),
                                                  ListTile(
                                                    enabled: order.status != 1,
                                                    leading: const Icon(Icons.local_shipping),
                                                    title: const Text('Enviado'),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _updateOrderStatus(order, 1);
                                                    },
                                                  ),
                                                  ListTile(
                                                    enabled: order.status != 2,
                                                    leading: const Icon(Icons.check_circle),
                                                    title: const Text('Entregado'),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _updateOrderStatus(order, 2);
                                                    },
                                                  ),
                                                  ListTile(
                                                    enabled: order.status != 3,
                                                    leading: const Icon(Icons.cancel),
                                                    title: const Text('Cancelado'),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _updateOrderStatus(order, 3);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: order.items?.length ?? 0,
                                  itemBuilder: (context, itemIndex) {
                                    final item = order.items![itemIndex];
                                    return ListTile(
                                      title: Text(item.productName ?? 'Producto desconocido'),
                                      subtitle: Text('Cantidad: ${item.quantity}'),
                                      trailing: Text(
                                        '\$${(item.unitPrice ?? 0).toStringAsFixed(2)}',
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}