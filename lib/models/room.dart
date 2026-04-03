/// Represents a room in the home that the user can decorate.
class Room {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String tag; // e.g. "Popular", "New", ""

  const Room({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.tag = '',
  });
}
