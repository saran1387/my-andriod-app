import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'product_model.dart';
import 'cart_model.dart';
import 'cart_page.dart';
import 'auth_model.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isFavorited = false;
  int quantity = 1;
  String selectedSize = 'Queen';
  final CartManager _cart = CartManager();
  final List<String> sizes = ['Queen', 'King', 'California King'];

  // ── Image gallery state ────────────────────────────────────────────────────
  int _currentImageIndex = 0;
  late PageController _pageController;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _images = _buildGalleryImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Builds a 4-image gallery per product.
  /// Uses imageUrls from the model if available, otherwise derives
  /// varied Unsplash crops from the single imageUrl.
  List<String> _buildGalleryImages() {
    // If the product already ships with multiple images, use them.
    if (widget.product.imageUrls.isNotEmpty) {
      return widget.product.imageUrls;
    }

    // Fallback: build 4 gallery images from Unsplash photo ID.
    // Unsplash supports ?w, ?h, ?fit, ?crop and ?q params.
    final base = widget.product.imageUrl.split('?').first;
    return [
      '$base?w=800&h=800&fit=crop&q=85',              // hero / full
      '$base?w=800&h=800&fit=crop&crop=top&q=85',     // top detail
      '$base?w=800&h=800&fit=crop&crop=bottom&q=85',  // bottom detail
      '$base?w=800&h=800&fit=crop&crop=right&q=85',   // side view
    ];
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void _addToCart() {
    _cart.addItem(widget.product, quantity: quantity, size: selectedSize);
    AuthManager.instance.autoSaveIfLoggedIn();
    _CartToast.show(
      context,
      message: '${widget.product.name} added to cart!',
      onViewCart: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const CartPage())),
    );
    setState(() {});
  }

  void _buyNow() {
    _cart.addItem(widget.product, quantity: quantity, size: selectedSize);
    AuthManager.instance.autoSaveIfLoggedIn();
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const CartPage()));
  }

  void _share() {
    final text =
        '🛋️ Check out ${widget.product.name} from Maison Elite!\n'
        '${widget.product.description}\n'
        'Price: \$${widget.product.price.toStringAsFixed(0)}\n\n'
        'Shop at: https://maisonelite.com/product/${widget.product.id}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.copy, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text('Product link copied to clipboard!'),
        ]),
        backgroundColor: const Color(0xFF2C2416),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Column(children: [
                  _buildThumbnailStrip(),   // ← new thumbnail row
                  _buildProductInfo(),
                  _buildDivider(),
                  _buildSizeSelector(),
                  _buildDivider(),
                  _buildMaterialDimensions(),
                  _buildDivider(),
                  _buildFeatures(),
                  _buildDivider(),
                  _buildDescription(),
                  const SizedBox(height: 160),
                ]),
              ),
            ],
          ),
          Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildBottomBar(context)),
        ],
      ),
    );
  }

  // ── Sliver App Bar with swipeable PageView gallery ─────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      backgroundColor: const Color(0xFFF8F5F0),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back,
              color: Color(0xFF2C2416), size: 20),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _share,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.share_outlined,
                color: Color(0xFF2C2416), size: 20),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => isFavorited = !isFavorited),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : const Color(0xFF2C2416),
              size: 20,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ── Swipeable image PageView ─────────────────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (_, index) => Image.network(
                _images[index],
                fit: BoxFit.cover,
                cacheWidth: 800,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFFEDE8E0),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF8B6914), strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEDE8E0),
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        color: Color(0xFF9B8B75), size: 48),
                  ),
                ),
              ),
            ),

            // Gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x33F8F5F0)],
                ),
              ),
            ),

            // ── Dot indicators ───────────────────────────────────────────
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_images.length, (i) {
                  final isActive = i == _currentImageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF8B6914)
                          : Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // ── Image counter badge (top-right) ──────────────────────────
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '${_currentImageIndex + 1}/${_images.length}',
                  style:
                  const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

            // ── Left / Right tap zones for quick navigation ──────────────
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_currentImageIndex > 0) {
                          _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        }
                      },
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_currentImageIndex < _images.length - 1) {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        }
                      },
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Thumbnail strip below the main image ──────────────────────────────────
  Widget _buildThumbnailStrip() {
    return Container(
      height: 72,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (_, i) {
          final isActive = i == _currentImageIndex;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF8B6914)
                      : const Color(0xFFEDE8E0),
                  width: isActive ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(
                  _images[i],
                  fit: BoxFit.cover,
                  cacheWidth: 120,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFEDE8E0),
                    child: const Icon(Icons.image_outlined,
                        color: Color(0xFF9B8B75), size: 20),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Rest of the page (unchanged) ───────────────────────────────────────────
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.star, color: Color(0xFFD4AF37), size: 16),
          const SizedBox(width: 4),
          const Text('4.8',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF2C2416))),
          const Text(' (120 Reviews)',
              style:
              TextStyle(color: Color(0xFF9B8B75), fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        Text(widget.product.name,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C2416),
                height: 1.2)),
        const SizedBox(height: 10),
        Text('\$${widget.product.price.toStringAsFixed(1)}',
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C2416))),
        const SizedBox(height: 12),
        Text(widget.product.fullDescription,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF6B5B45), height: 1.6)),
      ]),
    );
  }

  Widget _buildSizeSelector() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Size',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C2416))),
        const SizedBox(height: 12),
        Row(
          children: sizes.map((size) {
            final isSelected = size == selectedSize;
            return GestureDetector(
              onTap: () => setState(() => selectedSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8B6914)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8B6914)
                          : const Color(0xFFDDD5C8)),
                ),
                child: Text(size,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B5B45),
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Quantity',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2416))),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF2C2416).withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(children: [
                _qtyButton(Icons.remove, () {
                  if (quantity > 1) setState(() => quantity--);
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('$quantity',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C2416))),
                ),
                _qtyButton(
                    Icons.add, () => setState(() => quantity++)),
              ]),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color(0xFF2C2416),
            borderRadius: BorderRadius.circular(30)),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        color: const Color(0xFFE8E0D5));
  }

  Widget _buildMaterialDimensions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Expanded(
            child: _infoBox(Icons.texture_outlined, 'Material',
                widget.product.material)),
        const SizedBox(width: 12),
        Expanded(
            child: _infoBox(Icons.straighten_outlined, 'Dimensions',
                widget.product.dimensions)),
      ]),
    );
  }

  Widget _infoBox(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2C2416).withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFF8B6914), size: 20),
        const SizedBox(height: 8),
        Text(title,
            style:
            const TextStyle(color: Color(0xFF9B8B75), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Color(0xFF2C2416),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4)),
      ]),
    );
  }

  Widget _buildFeatures() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Key Features',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2416))),
            const SizedBox(height: 14),
            ...widget.product.features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                      color: const Color(0xFF8B6914).withOpacity(0.12),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.check,
                      color: Color(0xFF8B6914), size: 13),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(f,
                        style: const TextStyle(
                            color: Color(0xFF4A3728),
                            fontSize: 14,
                            height: 1.4))),
              ]),
            )),
          ]),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('About this Piece',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2416))),
            const SizedBox(height: 12),
            Text(widget.product.fullDescription,
                style: const TextStyle(
                    color: Color(0xFF6B5B45),
                    fontSize: 14,
                    height: 1.7)),
          ]),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2C2416).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartPage())),
              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: const Text('View Cart'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2C2416),
                side: const BorderSide(color: Color(0xFF2C2416)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _buyNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B6914),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Buy Now',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C2416),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Add To Cart · \$${(widget.product.price * quantity).toStringAsFixed(1)}',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ]),
    );
  }
}

// =============================================================================
// Self-managed "Added to cart" toast.
//
// Bypasses ScaffoldMessenger entirely — inserted directly into the root
// Overlay and removed by its OWN Timer, so it can never get stuck if the
// hosting Scaffold/page changes, navigates, or rebuilds while it's showing.
// Guaranteed to auto-dismiss after [duration], with a fade in/out.
// =============================================================================
class _CartToast {
  static OverlayEntry? _current;
  static Timer? _timer;

  static void show(
      BuildContext context, {
        required String message,
        required VoidCallback onViewCart,
        Duration duration = const Duration(seconds: 5),
      }) {
    // Remove any toast already showing, and cancel its pending timer,
    // so toasts never stack or fight over dismissal.
    _dismiss();

    final overlay = Overlay.of(context, rootOverlay: true);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CartToastWidget(
        message: message,
        duration: duration,
        onViewCart: () {
          _dismiss();
          onViewCart();
        },
        onExpired: _dismiss,
      ),
    );

    _current = entry;
    overlay.insert(entry);

    // Hard backstop: even if the widget's own animation/callback somehow
    // fails to fire, this guarantees removal.
    _timer = Timer(duration + const Duration(milliseconds: 400), _dismiss);
  }

  static void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }
}

class _CartToastWidget extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onViewCart;
  final VoidCallback onExpired;

  const _CartToastWidget({
    required this.message,
    required this.duration,
    required this.onViewCart,
    required this.onExpired,
  });

  @override
  State<_CartToastWidget> createState() => _CartToastWidgetState();
}

class _CartToastWidgetState extends State<_CartToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    // Start fading out shortly before `duration` elapses, then expire.
    _dismissTimer = Timer(widget.duration, _fadeOutAndExpire);
  }

  void _fadeOutAndExpire() async {
    if (!mounted) return;
    await _ctrl.reverse();
    if (!mounted) return;
    widget.onExpired();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomInset + 16,
      child: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2416),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onViewCart,
                      child: const Text(
                        'View Cart',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}