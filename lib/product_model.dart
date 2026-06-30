class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final String fullDescription;
  final double price;
  final String imageUrl;
  final List<String> imageUrls; // ← added: multi-image gallery
  final List<String> features;
  final String material;
  final String dimensions;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.fullDescription,
    required this.price,
    required this.imageUrl,
    required this.imageUrls,
    required this.features,
    required this.material,
    required this.dimensions,
  });
}

final List<Product> products = [
  Product(
    id: '1',
    name: 'Velvet Empress Sofa',
    category: 'Living Room',
    description: 'Luxurious deep velvet sofa with gold-tipped legs',
    fullDescription:
    'The Velvet Empress Sofa redefines luxury living. Crafted with hand-stitched deep emerald velvet and supported by solid brass-tipped walnut legs, this piece is a statement of refined taste.',
    price: 320.00,
    imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
      'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=800',
      'https://images.unsplash.com/photo-1540574163026-643ea20ade25?w=800',
      'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=800',
    ],
    features: ['Hand-stitched velvet', 'Solid brass legs', 'Down-fill cushions', '5-year warranty'],
    material: 'Emerald Velvet, Walnut Wood, Brass',
    dimensions: 'W 220cm × D 90cm × H 85cm',
  ),
  Product(
    id: '2',
    name: 'Marble Arch Dining Table',
    category: 'Dining Room',
    description: 'Italian Carrara marble top with sculptural base',
    fullDescription:
    'Sourced from the quarries of Carrara, Italy, this dining table features a book-matched marble top with dramatic veining. The sculptural arched base in powder-coated steel creates a perfect tension between raw material and refined form.',
    price: 650.00,
    imageUrl: 'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=800',
      'https://images.unsplash.com/photo-1615066390971-03e4e1c36ddf?w=800',
      'https://images.unsplash.com/photo-1604578762246-41134e37f9cc?w=800',
      'https://images.unsplash.com/photo-1577140917170-285929fb55b7?w=800',
    ],
    features: ['Carrara marble top', 'Book-matched veining', 'Powder-coated steel base', 'Seats 8'],
    material: 'Carrara Marble, Powder-coated Steel',
    dimensions: 'W 240cm × D 100cm × H 75cm',
  ),
  Product(
    id: '3',
    name: 'Floating Walnut Bed',
    category: 'Bedroom',
    description: 'Minimalist platform bed with integrated lighting',
    fullDescription:
    'The Floating Walnut Bed creates an illusion of weightlessness with its cantilevered design. Integrated LED strip lighting beneath the platform casts a warm ambient glow, transforming your bedroom into a serene retreat.',
    price: 480.00,
    imageUrl: 'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800',
      'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800',
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800',
      'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
    ],
    features: ['Integrated LED lighting', 'Floating platform design', 'Solid walnut frame', 'USB charging ports'],
    material: 'Solid American Walnut, LED Strip',
    dimensions: 'W 180cm × D 210cm × H 40cm',
  ),
  Product(
    id: '4',
    name: 'Onyx & Brass Chandelier',
    category: 'Lighting',
    description: 'Hand-carved black onyx with brushed brass fittings',
    fullDescription:
    'Each piece of black onyx is individually hand-carved and translucent when illuminated, revealing unique patterns within the stone. Set in brushed brass arms, this chandelier transforms any room into an extraordinary experience.',
    price: 150.00,
    imageUrl: 'https://images.unsplash.com/photo-1524484485831-a92ffc0de03f?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1524484485831-a92ffc0de03f?w=800',
      'https://images.unsplash.com/photo-1565814329452-e1efa11c5b89?w=800',
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
    ],
    features: ['Hand-carved onyx', 'Brushed brass fittings', 'Dimmable LED', 'Custom sizing available'],
    material: 'Black Onyx, Brushed Brass, LED',
    dimensions: 'Diameter 80cm × H 60cm',
  ),
  Product(
    id: '5',
    name: 'Boucle Accent Chair',
    category: 'Living Room',
    description: 'Cloud-like boucle fabric on sculptural oak frame',
    fullDescription:
    'Sink into the cloud-like embrace of our Boucle Accent Chair. The ivory boucle fabric wraps a generously padded seat and back, while the organic sculptural frame in oiled oak adds warmth and character to any corner.',
    price: 200.00,
    imageUrl: 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=800',
      'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=800',
      'https://images.unsplash.com/photo-1592078615290-033ee584e267?w=800',
      'https://images.unsplash.com/photo-1519947486511-46149fa0a254?w=800',
    ],
    features: ['Premium boucle fabric', 'Oiled oak frame', 'High-density foam', 'Stain-resistant coating'],
    material: 'Ivory Boucle, Oiled Oak',
    dimensions: 'W 75cm × D 80cm × H 90cm',
  ),
  Product(
    id: '6',
    name: 'Travertine Side Table',
    category: 'Accessories',
    description: 'Natural travertine stone with geometric cutouts',
    fullDescription:
    'Hewn from a single block of Roman travertine, this side table celebrates the natural beauty of stone. Geometric cutouts reduce visual weight while revealing the layered texture within.',
    price: 130.00,
    imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
    imageUrls: [
      'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800',
      'https://images.unsplash.com/photo-1499933374294-4584851291f0?w=800',
      'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?w=800',
    ],
    features: ['Single-block travertine', 'Geometric cutouts', 'Natural sealer applied', 'Indoor/outdoor use'],
    material: 'Roman Travertine',
    dimensions: 'W 45cm × D 45cm × H 55cm',
  ),
];