import 'product_model.dart';

class FavouritesManager {
  FavouritesManager._();
  static final FavouritesManager instance = FavouritesManager._();

  final Set<String> _likedIds = {};

  bool isLiked(String productId) => _likedIds.contains(productId);

  /// Toggle — returns new liked state.
  bool toggle(String productId) {
    if (_likedIds.contains(productId)) {
      _likedIds.remove(productId);
      return false;
    } else {
      _likedIds.add(productId);
      return true;
    }
  }

  List<Product> get likedProducts =>
      products.where((p) => _likedIds.contains(p.id)).toList();

  int get count => _likedIds.length;

  /// Wipes favourites in-memory WITHOUT persisting (used on logout after saving).
  void clear() => _likedIds.clear();

  // ── Persistence helpers (used by AuthManager) ──────────────────────────────

  List<String> toJsonList() => _likedIds.toList();

  void restoreFromJsonList(List<dynamic> jsonList) {
    _likedIds.clear();
    _likedIds.addAll(jsonList.map((e) => e.toString()));
  }
}