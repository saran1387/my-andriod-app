import 'package:flutter/material.dart';
import 'cart_model.dart';
import 'checkout_page.dart';
import 'auth_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartManager _cart = CartManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5F0),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Color(0xFF2C2416), size: 20),
          ),
        ),
        title: Text(
          'My Cart (${_cart.itemCount})',
          style: const TextStyle(color: Color(0xFF2C2416), fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _cart.clear());
              AuthManager.instance.autoSaveIfLoggedIn();
            },
            child: const Text('Edit', style: TextStyle(color: Color(0xFF8B6914), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _cart.items.isEmpty ? _buildEmptyCart(context) : _buildCartContent(context),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 20),
        const Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2C2416))),
        const SizedBox(height: 8),
        const Text('Add some beautiful pieces to get started', style: TextStyle(fontSize: 14, color: Color(0xFF9B8B75))),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            // Pops back to the first route in the stack (HomePage),
            // avoiding a circular import with home_page.dart.
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C2416),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Continue Shopping'),
        ),
      ]),
    );
  }

  Widget _buildCartContent(BuildContext context) {
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFreeShippingBanner(),
            const SizedBox(height: 16),
            ..._cart.items.map((item) => _buildCartItem(item)),
            const SizedBox(height: 8),
            _buildAddFromWishlist(),
            const SizedBox(height: 16),
            _buildPriceDetails(),
            const SizedBox(height: 16),
            _buildTrustBadges(),
          ],
        ),
      ),
      _buildBottomBar(context),
    ]);
  }

  Widget _buildFreeShippingBanner() {
    final remaining = _cart.freeShippingThreshold - _cart.subtotal;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFF2C2416).withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.local_shipping_outlined, color: Color(0xFF8B6914), size: 20),
          const SizedBox(width: 8),
          Text(
            remaining > 0
                ? 'You are \$${remaining.toStringAsFixed(0)} away from free shipping!'
                : '🎉 You have free shipping!',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2C2416)),
          ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _cart.freeShippingProgress,
            backgroundColor: const Color(0xFFEDE8E0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B6914)),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${_cart.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Color(0xFF9B8B75))),
            Text('\$${_cart.freeShippingThreshold.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Color(0xFF9B8B75))),
          ],
        ),
      ]),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFF2C2416).withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            item.product.imageUrl,
            width: 80, height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 80, height: 80,
              color: const Color(0xFFEDE8E0),
              child: const Icon(Icons.image_outlined, color: Color(0xFF9B8B75)),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Product info
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.product.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2C2416)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(item.selectedSize, style: const TextStyle(fontSize: 12, color: Color(0xFF9B8B75))),
            const SizedBox(height: 6),
            Text('\$${item.totalPrice.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2C2416))),
            const SizedBox(height: 8),
            Row(children: [
              _smallQtyBtn(Icons.remove, () {
                setState(() => _cart.updateQuantity(item.product.id, item.quantity - 1));
                AuthManager.instance.autoSaveIfLoggedIn();
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('${item.quantity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2C2416))),
              ),
              _smallQtyBtn(Icons.add, () {
                setState(() => _cart.updateQuantity(item.product.id, item.quantity + 1));
                AuthManager.instance.autoSaveIfLoggedIn();
              }),
            ]),
          ]),
        ),
        // Delete button
        GestureDetector(
          onTap: () {
            setState(() => _cart.removeItem(item.product.id));
            AuthManager.instance.autoSaveIfLoggedIn();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.delete_outline, color: Color(0xFF9B8B75), size: 22),
          ),
        ),
      ]),
    );
  }

  Widget _smallQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDD5C8)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: const Color(0xFF2C2416)),
      ),
    );
  }

  Widget _buildAddFromWishlist() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE8E0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(children: [
            Icon(Icons.favorite_border, color: Color(0xFF8B6914), size: 20),
            SizedBox(width: 10),
            Text('Add more from wishlist', style: TextStyle(fontSize: 13, color: Color(0xFF2C2416), fontWeight: FontWeight.w500)),
          ]),
          const Icon(Icons.chevron_right, color: Color(0xFF9B8B75)),
        ],
      ),
    );
  }

  Widget _buildPriceDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFF2C2416).withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Price Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2C2416))),
        const SizedBox(height: 14),
        _priceRow('Subtotal (${_cart.items.length} items)', '\$${_cart.subtotal.toStringAsFixed(1)}', isNormal: true),
        const SizedBox(height: 8),
        _priceRow('Shipping', _cart.shipping == 0 ? '\$0.00' : '\$${_cart.shipping.toStringAsFixed(2)}',
            isGreen: _cart.shipping == 0),
        const SizedBox(height: 8),
        _priceRow('Estimated Tax', '\$${_cart.tax.toStringAsFixed(0)}', isNormal: true),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFFEDE8E0)),
        ),
        _priceRow('Total', '\$${_cart.total.toStringAsFixed(1)}', isBold: true),
      ]),
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false, bool isGreen = false, bool isNormal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: isBold ? 15 : 13,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
          color: isBold ? const Color(0xFF2C2416) : const Color(0xFF6B5B45),
        )),
        Text(value, style: TextStyle(
          fontSize: isBold ? 16 : 13,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          color: isGreen ? const Color(0xFF27AE60) : const Color(0xFF2C2416),
        )),
      ],
    );
  }

  Widget _buildTrustBadges() {
    final badges = [
      {'icon': Icons.security_outlined, 'label': 'Secure Payment'},
      {'icon': Icons.replay_outlined, 'label': 'Easy Returns'},
      {'icon': Icons.headset_mic_outlined, 'label': '7 Days Support'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: badges.map((b) => Column(children: [
        Icon(b['icon'] as IconData, color: const Color(0xFF8B6914), size: 24),
        const SizedBox(height: 6),
        Text(b['label'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF9B8B75))),
      ])).toList(),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: const Color(0xFF2C2416).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage()));
            },
            icon: const Icon(Icons.lock_outline, size: 18),
            label: Text('Proceed to Checkout · \$${_cart.total.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B6914),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF6B5B45)),
          label: const Text('Continue Shopping', style: TextStyle(color: Color(0xFF6B5B45), fontSize: 13)),
        ),
      ]),
    );
  }
}