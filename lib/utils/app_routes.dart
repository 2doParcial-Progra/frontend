// Rutas disponibles según el rol
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  
  // Rutas para clientes
  static const String clientProducts = '/client/products';
  static const String clientOrders = '/client/orders';
  static const String productDetail = '/client/product/detail';
  
  // Rutas para empresas
  static const String companyProducts = '/company/products';
  static const String companyOrders = '/company/orders';
  static const String productForm = '/company/product/form';
}