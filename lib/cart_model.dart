import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  String selectedSize;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedSize = 'Queen',
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() => {
    'productId': product.id,
    'quantity': quantity,
    'selectedSize': selectedSize,
  };

  static CartItem? fromJson(Map<String, dynamic> json) {
    final product = products.where((p) => p.id == json['productId']).firstOrNull;
    if (product == null) return null;
    return CartItem(
      product: product,
      quantity: json['quantity'] ?? 1,
      selectedSize: json['selectedSize'] ?? 'Queen',
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get shipping => subtotal >= 500 ? 0 : 15;

  double get tax => subtotal * 0.06;

  double get total => subtotal + shipping + tax;

  double get freeShippingThreshold => 500;

  double get freeShippingProgress => (subtotal / freeShippingThreshold).clamp(0, 1);

  void addItem(Product product, {int quantity = 1, String size = 'Queen'}) {
    final existing = _items.indexWhere((i) => i.product.id == product.id);
    if (existing >= 0) {
      _items[existing].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity, selectedSize: size));
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
    }
  }

  /// Wipes cart in-memory WITHOUT persisting (used on logout after saving).
  void clear() => _items.clear();

  // ── Persistence helpers (used by AuthManager) ──────────────────────────────

  /// Serializes current cart to a JSON-safe list.
  List<Map<String, dynamic>> toJsonList() =>
      _items.map((i) => i.toJson()).toList();

  /// Replaces the entire cart with items restored from storage.
  void restoreFromJsonList(List<dynamic> jsonList) {
    _items.clear();
    for (final entry in jsonList) {
      final item = CartItem.fromJson(Map<String, dynamic>.from(entry));
      if (item != null) _items.add(item);
    }
  }
}