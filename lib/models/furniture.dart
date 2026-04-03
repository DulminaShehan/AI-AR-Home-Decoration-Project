/// Represents a furniture item that can be placed in AR.
class Furniture {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final double price;
  final double rating;
  final bool isNew;

  const Furniture({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    this.rating = 4.5,
    this.isNew = false,
  });

  /// Formatted price string, e.g. "\$249.99"
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}
