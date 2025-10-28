import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/order_service.dart';
import 'services/review_service.dart';
import 'models/product.dart';
import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/register_screen.dart';
import 'screens/company_product_list_screen.dart';
import 'screens/client_orders_screen.dart';
import 'screens/company_orders_screen.dart';
import 'screens/product_form_screen.dart';
import 'screens/product_detail_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => ProductService()),
        Provider(create: (_) => OrderService()),
        Provider(create: (_) => ReviewService()),
      ],
      child: const MainApp(),
    ),
  );
}

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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce App',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF8B4513),
        scaffoldBackgroundColor: const Color(0xFFFAF0E6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4513),
          primary: const Color(0xFF8B4513),
          secondary: const Color(0xFFD2691E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B4513),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false, // <- Aquí quitamos la etiqueta de debug
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Verificar autenticación para rutas protegidas
        if (settings.name != AppRoutes.login && 
            settings.name != AppRoutes.register && 
            settings.name != '/') {
          final authService = Provider.of<AuthService>(context, listen: false);
          if (!authService.isLoggedIn) {
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          }
        }
        
        // Definir rutas
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => FutureBuilder<bool>(
                future: Provider.of<AuthService>(context, listen: false).checkAuthStatus(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.data == true) {
                    final authService = Provider.of<AuthService>(context);
                    if (authService.isCompany) {
                      return const CompanyProductListScreen();
                    } else {
                      return const ProductListScreen();
                    }
                  }
                  return const LoginScreen();
                },
              ),
            );
            
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
            
          case AppRoutes.register:
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
            
          case AppRoutes.clientProducts:
            return MaterialPageRoute(builder: (_) => const ProductListScreen());
            
          case AppRoutes.clientOrders:
            return MaterialPageRoute(builder: (_) => const ClientOrdersScreen());
            
          case AppRoutes.companyProducts:
            return MaterialPageRoute(builder: (_) => const CompanyProductListScreen());
            
          case AppRoutes.companyOrders:
            return MaterialPageRoute(builder: (_) => const CompanyOrdersScreen());
            
          case AppRoutes.productForm:
            return MaterialPageRoute(builder: (_) => const ProductFormScreen());
            
          case AppRoutes.productDetail:
            if (settings.arguments is! Product) {
              return MaterialPageRoute(builder: (_) => const ProductListScreen());
            }
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                product: settings.arguments as Product,
              ),
            );
            
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
