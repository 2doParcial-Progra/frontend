import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/review_service.dart';
import '../services/order_service.dart';
import '../models/order.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ReviewService _reviewService = ReviewService();
  final OrderService _orderService = OrderService();
  List<Review> _reviews = [];
  bool _isLoading = true;
  bool _isSubmittingReview = false;
  bool _isPlacingOrder = false;
  int _quantity = 1;
  final _commentController = TextEditingController();
  double _rating = 5;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    try {
      setState(() => _isLoading = true);
      final reviews = await _reviewService.getProductReviews(widget.product.id!);
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar reseñas: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitReview() async {
    if (_isSubmittingReview) return;

    setState(() => _isSubmittingReview = true);
    try {
      final review = Review(
        productId: widget.product.id!,
        rating: _rating.round(),
        comment: _commentController.text,
      );

      await _reviewService.createReview(review);
      _commentController.clear();
      await _loadReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reseña enviada con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar reseña: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;

    setState(() => _isPlacingOrder = true);
    try {
      final order = Order(
        companyId: widget.product.companyId!,
        items: [
          OrderItem(
            productId: widget.product.id!,
            quantity: _quantity,
          ),
        ],
      );

      await _orderService.createOrder(order);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orden realizada con éxito')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al realizar orden: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final isCompany = authService.isCompany;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF0E6),
      appBar: AppBar(
        title: Text(widget.product.name ?? ''),
        backgroundColor: const Color(0xFF8B4513),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name ?? '',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${widget.product.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: const Color(0xFF8B4513),
                              ),
                        ),
                        if (widget.product.avgRating != null)
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              Text(
                                '${widget.product.avgRating!.toStringAsFixed(1)} (${widget.product.reviewsCount})',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (!isCompany) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Realizar Pedido',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Text(
                            _quantity.toString(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isPlacingOrder ? null : _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                          ),
                          child: _isPlacingOrder
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Ordenar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Reseñas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (!isCompany) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Realizar Pedido',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _rating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              setState(() => _rating = index + 1.0);
                            },
                          );
                        }),
                      ),
                      TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Escribe tu comentario...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmittingReview ? null : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B4513),
                          ),
                          child: _isSubmittingReview
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Enviar Reseña'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                    ? const Center(
                        child: Text('No hay reseñas todavía'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          return Card(
                            child: ListTile(
                              title: Row(
                                children: [
                                  ...List.generate(
                                    review.rating ?? 0,
                                    (index) => const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (review.comment != null) ...[
                                    const SizedBox(height: 4),
                                    Text(review.comment!),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cliente ID: ${review.clientId}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}