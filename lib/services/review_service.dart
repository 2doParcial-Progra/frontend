import '../models/review.dart';
import 'api_service.dart';

class ReviewService {
  final ApiService _apiService = ApiService();

  // Obtener reseñas de un producto
  Future<List<Review>> getProductReviews(int productId) async {
    final response = await _apiService.get('/api/Reviews/product/$productId');
    return (response as List)
        .map((json) => Review.fromJson(json))
        .toList();
  }

  // Crear una nueva reseña
  Future<void> createReview(Review review) async {
    await _apiService.post(
      '/api/Reviews',
      review.toJson(),
    );
  }
}