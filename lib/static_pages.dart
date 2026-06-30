// info_pages.dart ─────────────────────────────────────────────────────────
// About Us, Services, Portfolio, Contact Us pages — linked from the footer.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _bg = Color(0xFFF8F5F0);
const _dark = Color(0xFF2C2416);
const _gold = Color(0xFF8B6914);
const _muted = Color(0xFF9B8B75);
const _text = Color(0xFF6B5B45);

class _InfoScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  const _InfoScaffold({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: _dark, size: 20),
          ),
        ),
        title: Text(title,
            style: const TextStyle(color: _dark, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(child: body),
    );
  }
}

// =============================================================================
// About Us
// =============================================================================
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoScaffold(
      title: 'About Us',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=800',
              height: 200, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 200, color: const Color(0xFFEDE8E0)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Crafting timeless interiors since 2010',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _dark)),
          const SizedBox(height: 12),
          const Text(
            'Maison Elite was founded with a singular vision: to bring museum-quality '
            'craftsmanship into everyday living spaces. What began as a small atelier in '
            'New York has grown into a destination for discerning collectors of fine '
            'furniture and decor.\n\n'
            'Every piece in our collection is sourced from artisans who share our '
            'obsession with material, form, and longevity. We believe furniture should '
            'be inherited, not replaced — a philosophy that guides every design decision '
            'we make.',
            style: TextStyle(fontSize: 14, color: _text, height: 1.7),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _statCard('15+', 'Years of craft')),
              const SizedBox(width: 12),
              Expanded(child: _statCard('2,400+', 'Pieces delivered')),
              const SizedBox(width: 12),
              Expanded(child: _statCard('98%', 'Client satisfaction')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _gold)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: _muted)),
      ]),
    );
  }
}

// =============================================================================
// Services
// =============================================================================
class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  static const _services = [
    (icon: Icons.design_services_outlined, title: 'Custom Design', desc: 'Bespoke furniture tailored to your space, designed in collaboration with our in-house team.'),
    (icon: Icons.local_shipping_outlined, title: 'White Glove Delivery', desc: 'Careful, insured delivery and placement directly into your room of choice.'),
    (icon: Icons.handyman_outlined, title: 'Installation', desc: 'Full assembly and installation handled by trained specialists at no extra hassle to you.'),
    (icon: Icons.support_agent_outlined, title: '24/7 Support', desc: 'Our concierge team is available around the clock for any questions or concerns.'),
    (icon: Icons.architecture_outlined, title: 'Interior Consultation', desc: 'One-on-one sessions with our designers to plan your space from the ground up.'),
    (icon: Icons.verified_outlined, title: 'Extended Warranty', desc: 'Every piece is covered with a multi-year warranty against manufacturing defects.'),
  ];

  @override
  Widget build(BuildContext context) {
    return _InfoScaffold(
      title: 'Services',
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final s = _services[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _gold.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(s.icon, color: _gold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _dark)),
                  const SizedBox(height: 4),
                  Text(s.desc, style: const TextStyle(fontSize: 13, color: _text, height: 1.5)),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Portfolio
// =============================================================================
class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  static const _images = [
    'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=600',
    'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=600',
    'https://images.unsplash.com/photo-1540574163026-643ea20ade25?w=600',
    'https://images.unsplash.com/photo-1615066390971-03e4e1c36ddf?w=600',
    'https://images.unsplash.com/photo-1604578762246-41134e37f9cc?w=600',
    'https://images.unsplash.com/photo-1577140917170-285929fb55b7?w=600',
  ];

  @override
  Widget build(BuildContext context) {
    return _InfoScaffold(
      title: 'Portfolio',
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
        ),
        itemCount: _images.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            _images[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFFEDE8E0)),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Contact Us
// =============================================================================
class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sent = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _sent = false);
    });
    _nameCtrl.clear();
    _emailCtrl.clear();
    _msgCtrl.clear();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return _InfoScaffold(
      title: 'Contact Us',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Location card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.location_on_outlined, color: _gold, size: 20),
                const SizedBox(width: 8),
                const Text('Our Showroom', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
              ]),
              const SizedBox(height: 8),
              const Text('245 Madison Avenue, Suite 12\nNew York, NY 10016, USA',
                  style: TextStyle(fontSize: 13, color: _text, height: 1.5)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _launch('tel:+18005551234'),
                child: Row(children: [
                  const Icon(Icons.phone_outlined, color: _gold, size: 18),
                  const SizedBox(width: 8),
                  const Text('+1 (800) 555-1234', style: TextStyle(fontSize: 13, color: _gold, fontWeight: FontWeight.w500)),
                ]),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _launch('mailto:hello@maisonelite.com'),
                child: Row(children: [
                  const Icon(Icons.email_outlined, color: _gold, size: 18),
                  const SizedBox(width: 8),
                  const Text('hello@maisonelite.com', style: TextStyle(fontSize: 13, color: _gold, fontWeight: FontWeight.w500)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Send us a message',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _dark)),
          const SizedBox(height: 14),
          Form(
            key: _formKey,
            child: Column(children: [
              _field(_nameCtrl, 'Your Name', Icons.person_outline),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_msgCtrl, 'Message', Icons.message_outlined, maxLines: 4),
              const SizedBox(height: 16),
              if (_sent)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                    child: Text('Message sent! We\'ll get back to you soon.',
                        style: TextStyle(color: Color(0xFF27AE60), fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Send Message', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: _dark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: _muted),
        prefixIcon: maxLines == 1 ? Icon(icon, color: _gold, size: 20) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEDE8E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEDE8E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _gold, width: 1.5)),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}
