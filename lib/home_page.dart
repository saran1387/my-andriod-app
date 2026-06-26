import 'package:flutter/material.dart';
import 'product_model.dart';
import 'product_detail_page.dart';
import 'cart_page.dart';
import 'cart_model.dart';
import 'favourites_model.dart';
import 'auth_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';
  late List<Product> _filteredProducts;
  bool _showAllProducts = false;

  // Search
  bool _searchActive = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // Scroll-to-products
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _productsKey = GlobalKey();

  static const List<String> _categories = [
    'All', 'Living Room', 'Dining Room', 'Bedroom', 'Lighting', 'Accessories'
  ];

  final CartManager _cart = CartManager();
  final FavouritesManager _favs = FavouritesManager.instance;

  @override
  void initState() {
    super.initState();
    _filteredProducts = products;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Filtering ──────────────────────────────────────────────────────────────
  void _onCategoryChanged(String cat) {
    setState(() {
      _selectedCategory = cat;
      _showAllProducts = false;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Product> base =
    _selectedCategory == 'All' ? products : products.where((p) => p.category == _selectedCategory).toList();
    if (_searchQuery.isNotEmpty) {
      base = base.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    _filteredProducts = base;
  }

  void _refreshCartBadge() {
    if (mounted) setState(() {});
  }

  // ── Scroll to products ─────────────────────────────────────────────────────
  void _scrollToProducts() {
    final ctx = _productsKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  void _toggleSearch() {
    setState(() {
      _searchActive = !_searchActive;
      if (!_searchActive) {
        _searchQuery = '';
        _searchCtrl.clear();
        _applyFilters();
      } else {
        Future.delayed(const Duration(milliseconds: 100), () => _searchFocus.requestFocus());
      }
    });
  }

  // ── Favourites sheet ───────────────────────────────────────────────────────
  void _showFavouritesSheet() {
    if (!AuthManager.instance.isLoggedIn) {
      _showAuthSheet();
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FavouritesSheet(
        favs: _favs,
        onProductTap: (p) {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)))
              .then((_) => _refreshCartBadge());
        },
        onToggleFav: (p) => setState(() => _favs.toggle(p.id)),
      ),
    );
  }

  // ── Auth sheet ─────────────────────────────────────────────────────────────
  void _showAuthSheet({bool forceSignup = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AuthSheet(
        initialSignup: forceSignup,
        onSuccess: () {
          Navigator.pop(context);
          setState(() {});
        },
      ),
    );
  }

  // ── Profile sheet ──────────────────────────────────────────────────────────
  void _showProfileSheet() {
    if (!AuthManager.instance.isLoggedIn) {
      _showAuthSheet();
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(
        onUpdate: () => setState(() {}),
        onLogout: () {
          Navigator.pop(context);
          AuthManager.instance.logout();
          setState(() {});
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          _buildAppBar(),
          if (_searchActive) SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: RepaintBoundary(child: _buildHeroBanner())),
          SliverToBoxAdapter(child: RepaintBoundary(child: _buildServicesRow())),
          SliverToBoxAdapter(child: _buildCategoryFilter()),
          SliverToBoxAdapter(key: _productsKey, child: _buildProductsHeader()),
          _buildProductGrid(),
          SliverToBoxAdapter(child: RepaintBoundary(child: _buildFooter())),
        ],
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    final user = AuthManager.instance.user;
    return SliverAppBar(
      backgroundColor: const Color(0xFFF8F5F0),
      elevation: 0,
      floating: true,
      pinned: true,
      titleSpacing: 0,
      toolbarHeight: 56,
      title: const _AppBarTitle(),
      actions: [
        // Search toggle
        IconButton(
          icon: Icon(
            _searchActive ? Icons.search_off : Icons.search,
            color: _searchActive ? const Color(0xFF8B6914) : const Color(0xFF2C2416),
          ),
          onPressed: _toggleSearch,
        ),
        // Favourites
        Stack(
          children: [
            IconButton(
              icon: Icon(
                _favs.count > 0 ? Icons.favorite : Icons.favorite_border,
                color: _favs.count > 0 ? const Color(0xFF8B6914) : const Color(0xFF2C2416),
              ),
              onPressed: _showFavouritesSheet,
            ),
            if (_favs.count > 0)
              Positioned(
                right: 6, top: 6,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: Color(0xFF8B6914), shape: BoxShape.circle),
                  child: Center(
                    child: Text('${_favs.count}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
        // Cart
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF2C2416)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()))
                    .then((_) => _refreshCartBadge());
              },
            ),
            if (_cart.itemCount > 0)
              Positioned(
                right: 6, top: 6,
                child: Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(color: Color(0xFF8B6914), shape: BoxShape.circle),
                  child: Center(
                    child: Text('${_cart.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
        // Profile / Login avatar
        GestureDetector(
          onTap: _showProfileSheet,
          child: Container(
            margin: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AuthManager.instance.isLoggedIn ? const Color(0xFF8B6914) : const Color(0xFFEDE8E0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: user != null
                  ? Text(user.avatarInitials ?? '?',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))
                  : const Icon(Icons.person_outline, color: Color(0xFF9B8B75), size: 18),
            ),
          ),
        ),
      ],
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        focusNode: _searchFocus,
        style: const TextStyle(fontSize: 14, color: Color(0xFF2C2416)),
        decoration: InputDecoration(
          hintText: 'Search products…',
          hintStyle: const TextStyle(color: Color(0xFF9B8B75), fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF8B6914), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Color(0xFF9B8B75), size: 18),
            onPressed: () {
              setState(() {
                _searchCtrl.clear();
                _searchQuery = '';
                _applyFilters();
              });
            },
          )
              : null,
          filled: true,
          fillColor: const Color(0xFFF8F5F0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEDE8E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEDE8E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF8B6914), width: 1.5),
          ),
        ),
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
            _applyFilters();
          });
        },
      ),
    );
  }

  // ── Hero Banner ────────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      height: 420,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=800',
              fit: BoxFit.cover,
              cacheWidth: 800,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return const ColoredBox(color: Color(0xFFEDE8E0));
              },
              errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFEDE8E0)),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC2C2416)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: const Color(0xFF8B6914), borderRadius: BorderRadius.circular(20)),
                    child: const Text('NEW COLLECTION 2025',
                        style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 2)),
                  ),
                  const SizedBox(height: 12),
                  const Text('Where Luxury\nMeets Living',
                      style: TextStyle(
                          color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700, height: 1.2)),
                  const SizedBox(height: 16),
                  // FIX: Explore Collection scrolls to products section
                  ElevatedButton(
                    onPressed: _scrollToProducts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B6914),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Explore Collection', style: TextStyle(letterSpacing: 1)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Services Row ───────────────────────────────────────────────────────────
  Widget _buildServicesRow() => const _ServicesRow();

  // ── Category Filter ────────────────────────────────────────────────────────
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => _onCategoryChanged(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2C2416) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                    color: isSelected ? const Color(0xFF2C2416) : const Color(0xFFDDD5C8)),
                boxShadow: isSelected
                    ? [BoxShadow(
                    color: const Color(0xFF2C2416).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3))]
                    : const [],
              ),
              child: Text(cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6B5B45),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  )),
            ),
          );
        },
      ),
    );
  }

  // ── Products Header ────────────────────────────────────────────────────────
  Widget _buildProductsHeader() {
    final displayCount = _showAllProducts ? _filteredProducts.length : _filteredProducts.take(4).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Our Collection',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF2C2416))),
              Text(
                _searchQuery.isNotEmpty
                    ? '${_filteredProducts.length} result${_filteredProducts.length == 1 ? '' : 's'} for "$_searchQuery"'
                    : '${_filteredProducts.length} pieces available',
                style: const TextStyle(fontSize: 13, color: Color(0xFF9B8B75)),
              ),
            ],
          ),
          // FIX: View All toggles showing all products
          TextButton(
            onPressed: () => setState(() => _showAllProducts = !_showAllProducts),
            child: Text(
              _showAllProducts ? 'Show Less' : 'View All',
              style: const TextStyle(color: Color(0xFF8B6914), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Product Grid ───────────────────────────────────────────────────────────
  Widget _buildProductGrid() {
    final displayList = _showAllProducts || _searchQuery.isNotEmpty
        ? _filteredProducts
        : _filteredProducts.take(4).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
              (context, index) => RepaintBoundary(
            child: _ProductCard(
              product: displayList[index],
              isLiked: _favs.isLiked(displayList[index].id),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProductDetailPage(product: displayList[index])),
                ).then((_) => _refreshCartBadge());
              },
              onFavTap: () {
                if (!AuthManager.instance.isLoggedIn) {
                  _showAuthSheet();
                  return;
                }
                setState(() => _favs.toggle(displayList[index].id));
              },
            ),
          ),
          childCount: displayList.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.62,
        ),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() => const _Footer();
}

// =============================================================================
// Favourites Bottom Sheet
// =============================================================================
class _FavouritesSheet extends StatefulWidget {
  final FavouritesManager favs;
  final void Function(Product) onProductTap;
  final void Function(Product) onToggleFav;
  const _FavouritesSheet({required this.favs, required this.onProductTap, required this.onToggleFav});

  @override
  State<_FavouritesSheet> createState() => _FavouritesSheetState();
}

class _FavouritesSheetState extends State<_FavouritesSheet> {
  @override
  Widget build(BuildContext context) {
    final liked = widget.favs.likedProducts;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F5F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: const Color(0xFFDDD5C8), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(children: [
            const Icon(Icons.favorite, color: Color(0xFF8B6914), size: 20),
            const SizedBox(width: 8),
            Text('My Favourites (${liked.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2C2416))),
          ]),
          const SizedBox(height: 16),
          if (liked.isEmpty)
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.favorite_border, size: 56, color: Color(0xFFDDD5C8)),
                  const SizedBox(height: 12),
                  const Text('No favourites yet',
                      style: TextStyle(fontSize: 15, color: Color(0xFF9B8B75), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  const Text('Tap the heart on any product to save it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF9B8B75))),
                ]),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                itemCount: liked.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.68,
                ),
                itemBuilder: (_, i) => _ProductCard(
                  product: liked[i],
                  isLiked: true,
                  onTap: () => widget.onProductTap(liked[i]),
                  onFavTap: () {
                    setState(() => widget.onToggleFav(liked[i]));
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Auth Bottom Sheet (Login / Signup)
// =============================================================================
class _AuthSheet extends StatefulWidget {
  final bool initialSignup;
  final VoidCallback onSuccess;
  const _AuthSheet({this.initialSignup = false, required this.onSuccess});

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet> {
  late bool _isSignup;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isSignup = widget.initialSignup;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final auth = AuthManager.instance;
    final err = _isSignup
        ? auth.signup(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text)
        : auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (err != null) {
      setState(() => _error = err);
    } else {
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F5F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: const Color(0xFFDDD5C8), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text(_isSignup ? 'Create Account' : 'Welcome Back',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2C2416))),
              Text(_isSignup ? 'Sign up to save favourites & track orders' : 'Sign in to your account',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF9B8B75))),
              const SizedBox(height: 20),
              if (_isSignup) ...[
                _field(_nameCtrl, 'Full Name', Icons.person_outline),
                const SizedBox(height: 12),
              ],
              _field(_emailCtrl, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_passCtrl, 'Password', Icons.lock_outline,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF9B8B75), size: 18),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B6914),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(_isSignup ? 'Create Account' : 'Sign In',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isSignup = !_isSignup;
                    _error = null;
                  }),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6B5B45)),
                      children: [
                        TextSpan(text: _isSignup ? 'Already have an account? ' : "Don't have an account? "),
                        TextSpan(
                          text: _isSignup ? 'Sign In' : 'Sign Up',
                          style: const TextStyle(
                              color: Color(0xFF8B6914), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        TextInputType type = TextInputType.text,
        bool obscure = false,
        Widget? suffix,
      }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2C2416)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF9B8B75)),
        prefixIcon: Icon(icon, color: const Color(0xFF8B6914), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEDE8E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEDE8E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF8B6914), width: 1.5)),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}

// =============================================================================
// Profile Bottom Sheet
// =============================================================================
class _ProfileSheet extends StatefulWidget {
  final VoidCallback onUpdate;
  final VoidCallback onLogout;
  const _ProfileSheet({required this.onUpdate, required this.onLogout});

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  bool _editing = false;
  String? _saved;

  @override
  void initState() {
    super.initState();
    final u = AuthManager.instance.user!;
    _nameCtrl = TextEditingController(text: u.name);
    _emailCtrl = TextEditingController(text: u.email);
    _phoneCtrl = TextEditingController(text: u.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() {
    AuthManager.instance.updateProfile(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim());
    setState(() {
      _editing = false;
      _saved = 'Profile updated!';
    });
    widget.onUpdate();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthManager.instance.user!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F5F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: const Color(0xFFDDD5C8), borderRadius: BorderRadius.circular(2)),
            ),
            // Avatar
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(color: Color(0xFF8B6914), shape: BoxShape.circle),
              child: Center(
                child: Text(user.avatarInitials ?? '?',
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            Text(user.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2C2416))),
            Text(user.email,
                style: const TextStyle(fontSize: 13, color: Color(0xFF9B8B75))),
            const SizedBox(height: 20),
            if (_editing) ...[
              _profileField(_nameCtrl, 'Full Name', Icons.person_outline),
              const SizedBox(height: 10),
              _profileField(_emailCtrl, 'Email', Icons.email_outlined),
              const SizedBox(height: 10),
              _profileField(_phoneCtrl, 'Phone', Icons.phone_outlined,
                  type: TextInputType.phone),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _editing = false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B5B45),
                      side: const BorderSide(color: Color(0xFFDDD5C8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B6914),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ]),
            ] else ...[
              if (_saved != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 16),
                    const SizedBox(width: 6),
                    Text(_saved!, style: const TextStyle(color: Color(0xFF27AE60), fontSize: 13)),
                  ]),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B6914),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _profileField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2C2416)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF9B8B75)),
        prefixIcon: Icon(icon, color: const Color(0xFF8B6914), size: 18),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEDE8E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFEDE8E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF8B6914), width: 1.5)),
      ),
    );
  }
}

// =============================================================================
// Extracted sub-widgets
// =============================================================================

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: const Color(0xFF2C2416), borderRadius: BorderRadius.circular(4)),
          child: const Center(
            child: Text('M', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'MAISON ELITE',
          style: TextStyle(
              color: Color(0xFF2C2416), fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 2),
        ),
      ],
    );
  }
}

class _ServicesRow extends StatelessWidget {
  const _ServicesRow();

  static const _services = [
    (icon: Icons.design_services_outlined, label: 'Custom Design'),
    (icon: Icons.local_shipping_outlined, label: 'White Glove Delivery'),
    (icon: Icons.handyman_outlined, label: 'Installation'),
    (icon: Icons.support_agent_outlined, label: '24/7 Support'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          color: const Color(0xFF2C2416), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _services
            .map((s) => Column(children: [
          Icon(s.icon, color: const Color(0xFFD4AF37), size: 26),
          const SizedBox(height: 6),
          Text(s.label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 10, letterSpacing: 0.5),
              textAlign: TextAlign.center),
        ]))
            .toList(),
      ),
    );
  }
}

// =============================================================================
// Product Card  — now accepts isLiked + onFavTap
// =============================================================================
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.isLiked,
    required this.onFavTap,
  });

  final Product product;
  final VoidCallback onTap;
  final bool isLiked;
  final VoidCallback onFavTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF2C2416).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              child: Stack(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 160,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 400,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const ColoredBox(
                          color: Color(0xFFEDE8E0),
                          child: Center(
                            child: CircularProgressIndicator(color: Color(0xFF8B6914), strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFFEDE8E0),
                        child: Center(
                            child: Icon(Icons.image_not_supported_outlined, color: Color(0xFF9B8B75))),
                      ),
                    ),
                  ),
                ),
                // Favourite button — tappable
                Positioned(
                  top: 10, right: 10,
                  child: GestureDetector(
                    onTap: onFavTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: const Color(0xFF8B6914),
                      ),
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: const Color(0xFF8B6914), borderRadius: BorderRadius.circular(10)),
                    child: Text(product.category,
                        style: const TextStyle(color: Colors.white, fontSize: 9, letterSpacing: 0.5)),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2C2416), height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(product.description,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF9B8B75), height: 1.2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF8B6914))),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: const Color(0xFF2C2416), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF2C2416), borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        const Text('MAISON ELITE',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 4)),
        const SizedBox(height: 8),
        const Text('Curating exceptional interiors since 2010',
            style: TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['About', 'Services', 'Portfolio', 'Contact']
              .map((item) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(item, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
          ))
              .toList(),
        ),
        const SizedBox(height: 16),
        const Text('© 2025 Maison Elite. All rights reserved.',
            style: TextStyle(color: Colors.white30, fontSize: 10)),
      ]),
    );
  }
}