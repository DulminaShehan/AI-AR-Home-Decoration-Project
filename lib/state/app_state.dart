import 'package:flutter/foundation.dart';

import '../models/furniture.dart';

/// App-wide singleton state for cart and favourites.
/// No external packages required — uses plain [ValueNotifier].
class AppState {
  static final AppState instance = AppState._();
  AppState._();

  final ValueNotifier<List<Furniture>> favorites = ValueNotifier([]);
  final ValueNotifier<Map<String, int>> cart = ValueNotifier({});

  // ── Favourites ─────────────────────────────────────────────────────────────

  bool isFavorite(String id) =>
      favorites.value.any((f) => f.id == id);

  void toggleFavorite(Furniture item) {
    final list = List<Furniture>.from(favorites.value);
    final idx = list.indexWhere((f) => f.id == item.id);
    if (idx >= 0) {
      list.removeAt(idx);
    } else {
      list.add(item);
    }
    favorites.value = list;
  }

  // ── Cart ────────────────────────────────────────────────────────────────────

  int cartQuantity(String id) => cart.value[id] ?? 0;

  int get cartItemCount =>
      cart.value.values.fold(0, (sum, qty) => sum + qty);

  void addToCart(String id) {
    final map = Map<String, int>.from(cart.value);
    map[id] = (map[id] ?? 0) + 1;
    cart.value = map;
  }

  void decreaseCart(String id) {
    final map = Map<String, int>.from(cart.value);
    final current = map[id] ?? 0;
    if (current <= 1) {
      map.remove(id);
    } else {
      map[id] = current - 1;
    }
    cart.value = map;
  }

  void removeFromCart(String id) {
    final map = Map<String, int>.from(cart.value);
    map.remove(id);
    cart.value = map;
  }

  double cartTotal(List<Furniture> allFurniture) {
    double total = 0;
    for (final entry in cart.value.entries) {
      final f = allFurniture.firstWhere(
        (f) => f.id == entry.key,
        orElse: () => const Furniture(
          id: '', name: '', category: '', imageUrl: '', price: 0,
        ),
      );
      total += f.price * entry.value;
    }
    return total;
  }
}
