import '../models/room.dart';
import '../models/furniture.dart';
import '../models/ai_suggestion.dart';

/// All static dummy data used across the app.
/// Images are sourced from picsum.photos (stable seeds → consistent photos).
class DummyData {
  // ── Rooms ───────────────────────────────────────────────────────────────
  static const List<Room> rooms = [
    Room(
      id: 'living',
      name: 'Living Room',
      description: 'Create a welcoming space for family & guests',
      imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80',
      tag: 'Popular',
    ),
    Room(
      id: 'bedroom',
      name: 'Bedroom',
      description: 'Design your perfect sanctuary for rest',
      imageUrl: 'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800&q=80',
      tag: 'New',
    ),
    Room(
      id: 'kitchen',
      name: 'Kitchen',
      description: 'Make cooking a joy with smart layouts',
      imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
      tag: '',
    ),
    Room(
      id: 'office',
      name: 'Home Office',
      description: 'Boost productivity with ergonomic design',
      imageUrl: 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=800&q=80',
      tag: 'Trending',
    ),
    Room(
      id: 'bathroom',
      name: 'Bathroom',
      description: 'Spa-like vibes in your own home',
      imageUrl: 'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=800&q=80',
      tag: '',
    ),
    Room(
      id: 'dining',
      name: 'Dining Room',
      description: 'Set the stage for memorable meals',
      imageUrl: 'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=800&q=80',
      tag: '',
    ),
  ];

  // ── Furniture per room ───────────────────────────────────────────────────
  static const Map<String, List<Furniture>> furnitureByRoom = {
    'living': _livingFurniture,
    'bedroom': _bedroomFurniture,
    'kitchen': _kitchenFurniture,
    'office': _officeFurniture,
    'bathroom': _bathroomFurniture,
    'dining': _diningFurniture,
  };

  static const List<Furniture> _livingFurniture = [
    Furniture(
      id: 'f1',
      name: 'Modern Sofa',
      category: 'Seating',
      imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80',
      price: 849.99,
      rating: 4.8,
      isNew: true,
    ),
    Furniture(
      id: 'f2',
      name: 'Coffee Table',
      category: 'Tables',
      imageUrl: 'https://images.unsplash.com/photo-1567016432779-094069958ea5?w=400&q=80',
      price: 349.00,
      rating: 4.6,
    ),
    Furniture(
      id: 'f3',
      name: 'Floor Lamp',
      category: 'Lighting',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
      price: 129.99,
      rating: 4.4,
    ),
    Furniture(
      id: 'f4',
      name: 'Bookshelf',
      category: 'Storage',
      imageUrl: 'https://images.unsplash.com/photo-1481277542470-605612bd2d61?w=400&q=80',
      price: 279.00,
      rating: 4.5,
    ),
    Furniture(
      id: 'f5',
      name: 'Accent Armchair',
      category: 'Seating',
      imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&q=80',
      price: 499.00,
      rating: 4.7,
      isNew: true,
    ),
  ];

  static const List<Furniture> _bedroomFurniture = [
    Furniture(
      id: 'b1',
      name: 'Platform Bed',
      category: 'Beds',
      imageUrl: 'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=400&q=80',
      price: 1199.00,
      rating: 4.9,
      isNew: true,
    ),
    Furniture(
      id: 'b2',
      name: 'Nightstand',
      category: 'Tables',
      imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80',
      price: 189.99,
      rating: 4.3,
    ),
    Furniture(
      id: 'b3',
      name: 'Wardrobe',
      category: 'Storage',
      imageUrl: 'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=400&q=80',
      price: 899.00,
      rating: 4.6,
    ),
    Furniture(
      id: 'b4',
      name: 'Vanity Mirror',
      category: 'Decor',
      imageUrl: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=400&q=80',
      price: 249.00,
      rating: 4.5,
    ),
  ];

  static const List<Furniture> _kitchenFurniture = [
    Furniture(
      id: 'k1',
      name: 'Bar Stool Set',
      category: 'Seating',
      imageUrl: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&q=80',
      price: 299.00,
      rating: 4.5,
    ),
    Furniture(
      id: 'k2',
      name: 'Kitchen Island',
      category: 'Tables',
      imageUrl: 'https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=400&q=80',
      price: 749.00,
      rating: 4.8,
      isNew: true,
    ),
    Furniture(
      id: 'k3',
      name: 'Open Shelving',
      category: 'Storage',
      imageUrl: 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=400&q=80',
      price: 199.00,
      rating: 4.4,
    ),
  ];

  static const List<Furniture> _officeFurniture = [
    Furniture(
      id: 'o1',
      name: 'Standing Desk',
      category: 'Desks',
      imageUrl: 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400&q=80',
      price: 599.00,
      rating: 4.9,
      isNew: true,
    ),
    Furniture(
      id: 'o2',
      name: 'Ergonomic Chair',
      category: 'Seating',
      imageUrl: 'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=400&q=80',
      price: 449.00,
      rating: 4.7,
    ),
    Furniture(
      id: 'o3',
      name: 'Monitor Stand',
      category: 'Accessories',
      imageUrl: 'https://images.unsplash.com/photo-1547082299-de196ea013d6?w=400&q=80',
      price: 89.99,
      rating: 4.5,
    ),
  ];

  static const List<Furniture> _bathroomFurniture = [
    Furniture(
      id: 'bth1',
      name: 'Floating Vanity',
      category: 'Vanities',
      imageUrl: 'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=400&q=80',
      price: 699.00,
      rating: 4.7,
    ),
    Furniture(
      id: 'bth2',
      name: 'Towel Ladder',
      category: 'Accessories',
      imageUrl: 'https://images.unsplash.com/photo-1620626011761-996317702519?w=400&q=80',
      price: 79.99,
      rating: 4.3,
    ),
  ];

  static const List<Furniture> _diningFurniture = [
    Furniture(
      id: 'd1',
      name: 'Dining Table',
      category: 'Tables',
      imageUrl: 'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=400&q=80',
      price: 899.00,
      rating: 4.8,
      isNew: true,
    ),
    Furniture(
      id: 'd2',
      name: 'Dining Chairs ×4',
      category: 'Seating',
      imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80',
      price: 599.00,
      rating: 4.6,
    ),
    Furniture(
      id: 'd3',
      name: 'Sideboard',
      category: 'Storage',
      imageUrl: 'https://images.unsplash.com/photo-1567016432779-094069958ea5?w=400&q=80',
      price: 479.00,
      rating: 4.5,
    ),
  ];

  // ── All furniture (flat list for Furniture / Cart / Budget screens) ─────────
  static List<Furniture> get allFurniture => [
    ..._livingFurniture,
    ..._bedroomFurniture,
    ..._kitchenFurniture,
    ..._officeFurniture,
    ..._bathroomFurniture,
    ..._diningFurniture,
  ];

  // ── AI Chat quick suggestion chips ───────────────────────────────────────────
  static const List<String> chatSuggestions = [
    'Use light colors for small rooms',
    'Place sofa near the window',
    'Best furniture for a home office?',
    'How to add warmth to a bedroom?',
    'Minimalist living room ideas',
    'Budget-friendly kitchen upgrades',
    'Create a cozy reading nook',
    'Best plants for interior decor',
  ];

  // ── Initial AI chat seed messages ─────────────────────────────────────────
  static const List<(bool isUser, String text)> initialMessages = [
    (false, 'Hi! I\'m your AI Design Assistant 👋\nAsk me anything about interior design — I can help with furniture placement, colour palettes, lighting, and much more!'),
    (true, 'What colours work best for a small living room?'),
    (false, 'Great question! For small living rooms, opt for **light and airy tones** like off-white, soft grey, or pale sage.\n\n• Light colours reflect natural light, making the room feel larger\n• Use one accent wall in a slightly deeper shade for depth\n• Keep furniture colours in the same tonal family\n• Add mirrors to double the sense of space'),
    (true, 'Where should I place the sofa?'),
    (false, 'The golden rule: **float your sofa away from the wall** rather than pushing it back.\n\n• Position it facing the room\'s focal point (fireplace, TV, or window)\n• Leave at least 45 cm of walkway behind\n• Anchor it with a rug — the front legs at minimum should sit on it'),
  ];

  // ── AI Suggestions per room ───────────────────────────────────────────────
  static const Map<String, List<AiSuggestion>> suggestionsByRoom = {
    'living': [
      AiSuggestion(
        icon: '💡',
        title: 'Maximise natural light',
        body: 'Place your sofa near the window to make the room feel larger and brighter.',
      ),
      AiSuggestion(
        icon: '🎨',
        title: 'Light colour palette',
        body: 'Use soft neutrals — cream, beige, or light grey — for a spacious, airy feel.',
      ),
      AiSuggestion(
        icon: '📐',
        title: 'Rule of three',
        body: 'Group décor items in odd numbers (3 or 5) for a visually balanced look.',
      ),
      AiSuggestion(
        icon: '🌿',
        title: 'Add greenery',
        body: 'A large fiddle-leaf fig or pothos plant adds life and improves air quality.',
      ),
    ],
    'bedroom': [
      AiSuggestion(
        icon: '🌙',
        title: 'Warm, dim lighting',
        body: 'Layer lighting with bedside lamps and dimmer switches for a cosy atmosphere.',
      ),
      AiSuggestion(
        icon: '🛏️',
        title: 'Centre the bed',
        body: 'Place the bed on the wall opposite the door to create a strong focal point.',
      ),
      AiSuggestion(
        icon: '🪞',
        title: 'Mirror magic',
        body: 'A full-length mirror on the wardrobe door visually doubles the space.',
      ),
    ],
    'kitchen': [
      AiSuggestion(
        icon: '🍳',
        title: 'Work triangle',
        body: 'Keep sink, stove, and fridge within a compact triangle for efficient cooking.',
      ),
      AiSuggestion(
        icon: '💎',
        title: 'Contrast accents',
        body: 'Dark hardware on light cabinets adds depth without overwhelming the space.',
      ),
      AiSuggestion(
        icon: '💡',
        title: 'Under-cabinet lighting',
        body: 'LED strips under upper cabinets eliminate shadows on your work surfaces.',
      ),
    ],
    'office': [
      AiSuggestion(
        icon: '🖥️',
        title: 'Monitor at eye level',
        body: 'Position your screen so the top edge is at eye height to prevent neck strain.',
      ),
      AiSuggestion(
        icon: '🌿',
        title: 'Biophilic boost',
        body: 'A small plant on your desk reduces stress and improves focus by up to 15 %.',
      ),
    ],
    'bathroom': [
      AiSuggestion(
        icon: '🚿',
        title: 'Large format tiles',
        body: 'Fewer grout lines make a small bathroom look bigger and cleaner.',
      ),
      AiSuggestion(
        icon: '💡',
        title: 'Side lighting',
        body: 'Mount lights on either side of the mirror rather than above to eliminate shadows.',
      ),
    ],
    'dining': [
      AiSuggestion(
        icon: '🕯️',
        title: 'Statement pendant',
        body: 'Hang a pendant light 75–85 cm above the table surface for perfect ambience.',
      ),
      AiSuggestion(
        icon: '🪑',
        title: 'Chair clearance',
        body: 'Allow 90 cm between the table edge and the wall so chairs can slide out freely.',
      ),
    ],
  };
}
