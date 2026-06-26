import 'package:flutter/material.dart';
import 'cart_model.dart';
import 'home_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartManager _cart = CartManager();

  // ── Step state ──────────────────────────────────────────────────────────────
  int _currentStep = 0; // 0 = Address, 1 = Payment, 2 = Review
  bool _orderPlaced = false;

  static const List<String> _stepLabels = ['Address', 'Payment', 'Review'];

  // ── Address / Delivery state ─────────────────────────────────────────────
  String _selectedDelivery = 'standard';

  // ── Address state ────────────────────────────────────────────────────────
  String _addressName = 'John Doe';
  String _addressLine1 = '123, Green Street, Apartment 4B';
  String _addressLine2 = 'New York, NY 10001, USA';
  String _addressPhone = '+1 987 654 3210';

  // ── Payment state ────────────────────────────────────────────────────────
  // Payment method types
  String _paymentType = 'card'; // 'card' | 'upi' | 'cod'

  // Card sub-selection
  String _selectedCard = 'visa';

  // UPI sub-selection
  String _selectedUpi = 'gpay';

  // UPI ID typed by user
  final TextEditingController _upiController = TextEditingController();
  bool _upiIdMode = false; // toggle between UPI app list and manual UPI ID

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  // ── Navigation helpers ───────────────────────────────────────────────────
  void _goNext() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Final step — place order
      setState(() {
        _orderPlaced = true;
        _cart.clear();
      });
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  String get _buttonLabel {
    switch (_currentStep) {
      case 0:
        return 'Continue to Payment';
      case 1:
        return 'Continue to Review';
      case 2:
        return 'Place Order · \$${_cart.total.toStringAsFixed(1)}';
      default:
        return 'Continue';
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_orderPlaced) return _buildOrderSuccess(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5F0),
        elevation: 0,
        leading: GestureDetector(
          onTap: _goBack,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Color(0xFF2C2416), size: 20),
          ),
        ),
        title: const Text('Checkout',
            style: TextStyle(
                color: Color(0xFF2C2416),
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ),
      body: Column(children: [
        _buildStepIndicator(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: ListView(
              key: ValueKey(_currentStep), // triggers AnimatedSwitcher
              padding: const EdgeInsets.all(16),
              children: [
                // Show only the relevant section per step
                if (_currentStep == 0) ...[
                  _buildShippingAddress(),
                  const SizedBox(height: 16),
                  _buildDeliveryOptions(),
                ],
                if (_currentStep == 1) ...[
                  _buildPaymentMethod(),
                ],
                if (_currentStep == 2) ...[
                  _buildShippingAddress(readOnly: true),
                  const SizedBox(height: 16),
                  _buildSelectedPaymentSummary(),
                  const SizedBox(height: 16),
                  _buildOrderSummary(),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _buildBottomBar(),
      ]),
    );
  }

  // ── Step Indicator ───────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_stepLabels.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                // Circle + label centered in its slot
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted || isActive
                              ? const Color(0xFF8B6914)
                              : const Color(0xFFEDE8E0),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : Text('${index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : const Color(0xFF9B8B75),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(_stepLabels[index],
                          style: TextStyle(
                            fontSize: 11,
                            color: isActive
                                ? const Color(0xFF8B6914)
                                : const Color(0xFF9B8B75),
                            fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                          )),
                    ],
                  ),
                ),
                // Connector line between steps
                if (index < _stepLabels.length - 1)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: isCompleted
                        ? const Color(0xFF8B6914)
                        : const Color(0xFFEDE8E0),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Step 0 : Shipping Address ────────────────────────────────────────────
  Widget _buildShippingAddress({bool readOnly = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Shipping Address',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2416))),
          if (!readOnly)
            TextButton(
              onPressed: _showChangeAddressSheet,
              child: const Text('Change',
                  style: TextStyle(color: Color(0xFF8B6914), fontSize: 13)),
            ),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B6914).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_outlined,
                color: Color(0xFF8B6914), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_addressName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C2416))),
                  const SizedBox(height: 4),
                  Text(_addressLine1,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B5B45), height: 1.4)),
                  Text(_addressLine2,
                      style:
                      const TextStyle(fontSize: 13, color: Color(0xFF6B5B45))),
                  const SizedBox(height: 4),
                  Text(_addressPhone,
                      style:
                      const TextStyle(fontSize: 13, color: Color(0xFF6B5B45))),
                ]),
          ),
        ]),
      ]),
    );
  }

  // ── Change Address Bottom Sheet ──────────────────────────────────────────
  void _showChangeAddressSheet() {
    final nameCtrl = TextEditingController(text: _addressName);
    final line1Ctrl = TextEditingController(text: _addressLine1);
    final line2Ctrl = TextEditingController(text: _addressLine2);
    final phoneCtrl = TextEditingController(text: _addressPhone);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F5F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDD5C8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text('Change Shipping Address',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2416))),
                const SizedBox(height: 20),
                _addressField(nameCtrl, 'Full Name', Icons.person_outline),
                const SizedBox(height: 12),
                _addressField(line1Ctrl, 'Address Line 1', Icons.home_outlined),
                const SizedBox(height: 12),
                _addressField(line2Ctrl, 'City, State, ZIP, Country', Icons.location_city_outlined),
                const SizedBox(height: 12),
                _addressField(phoneCtrl, 'Phone Number', Icons.phone_outlined,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          _addressName = nameCtrl.text.trim();
                          _addressLine1 = line1Ctrl.text.trim();
                          _addressLine2 = line2Ctrl.text.trim();
                          _addressPhone = phoneCtrl.text.trim();
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B6914),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Save Address',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _addressField(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF2C2416)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF9B8B75)),
        prefixIcon: Icon(icon, color: const Color(0xFF8B6914), size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEDE8E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEDE8E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
          const BorderSide(color: Color(0xFF8B6914), width: 1.5),
        ),
      ),
      validator: (v) =>
      (v == null || v.trim().isEmpty) ? 'Please enter $label' : null,
    );
  }

  Widget _buildDeliveryOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Delivery Options',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C2416))),
        const SizedBox(height: 14),
        _deliveryOption('standard', 'Standard Delivery (3–5 days)', 'FREE'),
        const SizedBox(height: 10),
        _deliveryOption(
            'express', 'Express Delivery (1–2 days)', '\$15.00'),
      ]),
    );
  }

  Widget _deliveryOption(String value, String label, String price) {
    final isSelected = _selectedDelivery == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedDelivery = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B6914).withOpacity(0.05)
              : const Color(0xFFF8F5F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF8B6914)
                  : const Color(0xFFEDE8E0)),
        ),
        child: Row(children: [
          _radioCircle(isSelected),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? const Color(0xFF2C2416)
                        : const Color(0xFF6B5B45),
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal)),
          ),
          Text(price,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: price == 'FREE'
                      ? const Color(0xFF27AE60)
                      : const Color(0xFF2C2416))),
        ]),
      ),
    );
  }

  // ── Step 1 : Payment ─────────────────────────────────────────────────────
  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Payment Method',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C2416))),
        const SizedBox(height: 16),

        // ── Payment type tabs ──
        Row(children: [
          _paymentTypeTab('card', Icons.credit_card, 'Card'),
          const SizedBox(width: 10),
          _paymentTypeTab('upi', Icons.account_balance_wallet_outlined, 'UPI'),
          const SizedBox(width: 10),
          _paymentTypeTab('cod', Icons.local_shipping_outlined, 'COD'),
        ]),

        const SizedBox(height: 20),
        const Divider(color: Color(0xFFEDE8E0)),
        const SizedBox(height: 16),

        // ── Content per tab ──
        if (_paymentType == 'card') _buildCardOptions(),
        if (_paymentType == 'upi') _buildUpiOptions(),
        if (_paymentType == 'cod') _buildCodOption(),
      ]),
    );
  }

  Widget _paymentTypeTab(String type, IconData icon, String label) {
    final isSelected = _paymentType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2C2416) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isSelected
                    ? const Color(0xFF2C2416)
                    : const Color(0xFFDDD5C8)),
          ),
          child: Column(children: [
            Icon(icon,
                size: 22,
                color: isSelected ? Colors.white : const Color(0xFF9B8B75)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF6B5B45))),
          ]),
        ),
      ),
    );
  }

  // Card options
  Widget _buildCardOptions() {
    return Column(children: [
      _paymentCard('visa', 'VISA', 'Visa •••• 4242',
          Icons.credit_card, const Color(0xFF1A1F71)),
      const SizedBox(height: 10),
      _paymentCard('master', 'MC', 'Mastercard •••• 8888',
          Icons.credit_card, const Color(0xFFEB001B)),
      const SizedBox(height: 14),
      GestureDetector(
        onTap: () {},
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDDD5C8)),
                borderRadius: BorderRadius.circular(8)),
            child:
            const Icon(Icons.add, color: Color(0xFF8B6914), size: 18),
          ),
          const SizedBox(width: 12),
          const Text('Add New Card',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C2416),
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Color(0xFF9B8B75)),
        ]),
      ),
    ]);
  }

  Widget _paymentCard(
      String value, String brand, String label, IconData icon, Color brandColor) {
    final isSelected = _selectedCard == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedCard = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B6914).withOpacity(0.05)
              : const Color(0xFFF8F5F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF8B6914)
                  : const Color(0xFFEDE8E0),
              width: isSelected ? 2 : 1),
        ),
        child: Row(children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: brandColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6)),
            child: Text(brand,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: brandColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2C2416),
                    fontWeight: FontWeight.w500)),
          ),
          if (isSelected)
            const Icon(Icons.check_circle,
                color: Color(0xFF8B6914), size: 20),
        ]),
      ),
    );
  }

  // UPI options
  static const _upiApps = [
    (value: 'gpay', label: 'Google Pay', icon: Icons.g_mobiledata),
    (value: 'phonepe', label: 'PhonePe', icon: Icons.phone_android),
    (value: 'paytm', label: 'Paytm', icon: Icons.account_balance_wallet),
    (value: 'bhim', label: 'BHIM UPI', icon: Icons.account_balance),
  ];

  Widget _buildUpiOptions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Toggle: apps vs manual ID
      Row(children: [
        _upiToggleChip('Pay via App', !_upiIdMode),
        const SizedBox(width: 10),
        _upiToggleChip('Enter UPI ID', _upiIdMode),
      ]),
      const SizedBox(height: 16),

      if (!_upiIdMode) ...[
        // UPI app grid
        ...(_upiApps.map((app) {
          final isSelected = _selectedUpi == app.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedUpi = app.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8B6914).withOpacity(0.05)
                      : const Color(0xFFF8F5F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8B6914)
                          : const Color(0xFFEDE8E0),
                      width: isSelected ? 2 : 1),
                ),
                child: Row(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: const Color(0xFF8B6914).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(app.icon,
                        color: const Color(0xFF8B6914), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(app.label,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2C2416),
                            fontWeight: FontWeight.w500)),
                  ),
                  _radioCircle(isSelected),
                ]),
              ),
            ),
          );
        })),
      ] else ...[
        // Manual UPI ID input
        TextField(
          controller: _upiController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'yourname@upi',
            hintStyle: const TextStyle(color: Color(0xFF9B8B75)),
            prefixIcon: const Icon(Icons.alternate_email,
                color: Color(0xFF8B6914), size: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDD5C8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Color(0xFF8B6914), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F5F0),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enter your UPI ID in the format: name@bank',
          style: TextStyle(fontSize: 11, color: Color(0xFF9B8B75)),
        ),
      ],
    ]);
  }

  Widget _upiToggleChip(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _upiIdMode = label == 'Enter UPI ID'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
          isActive ? const Color(0xFF2C2416) : const Color(0xFFF8F5F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive
                  ? const Color(0xFF2C2416)
                  : const Color(0xFFDDD5C8)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF6B5B45))),
      ),
    );
  }

  // COD option
  Widget _buildCodOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF27AE60).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27AE60).withOpacity(0.3)),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.payments_outlined,
                color: Color(0xFF27AE60), size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cash on Delivery',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C2416))),
                  SizedBox(height: 2),
                  Text('Pay when your order arrives',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF6B5B45))),
                ]),
          ),
          const Icon(Icons.check_circle,
              color: Color(0xFF27AE60), size: 22),
        ]),
        const SizedBox(height: 14),
        const Divider(color: Color(0xFFEDE8E0)),
        const SizedBox(height: 10),
        const Row(children: [
          Icon(Icons.info_outline, size: 14, color: Color(0xFF9B8B75)),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'A ₹40 handling fee applies for COD orders.',
              style: TextStyle(fontSize: 11, color: Color(0xFF9B8B75)),
            ),
          ),
        ]),
      ]),
    );
  }

  // ── Step 2 : Review — selected payment summary ───────────────────────────
  Widget _buildSelectedPaymentSummary() {
    String methodLabel;
    IconData methodIcon;

    if (_paymentType == 'card') {
      methodLabel = _selectedCard == 'visa'
          ? 'Visa •••• 4242'
          : 'Mastercard •••• 8888';
      methodIcon = Icons.credit_card;
    } else if (_paymentType == 'upi') {
      if (_upiIdMode && _upiController.text.trim().isNotEmpty) {
        methodLabel = _upiController.text.trim();
      } else {
        final app = _upiApps
            .firstWhere((a) => a.value == _selectedUpi,
            orElse: () => _upiApps.first);
        methodLabel = app.label;
      }
      methodIcon = Icons.account_balance_wallet_outlined;
    } else {
      methodLabel = 'Cash on Delivery';
      methodIcon = Icons.payments_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF8B6914).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(methodIcon, color: const Color(0xFF8B6914), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Payment',
                style: TextStyle(fontSize: 12, color: Color(0xFF9B8B75))),
            Text(methodLabel,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2416))),
          ]),
        ),
        GestureDetector(
          onTap: () => setState(() => _currentStep = 1),
          child: const Text('Edit',
              style:
              TextStyle(color: Color(0xFF8B6914), fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  // ── Order Summary ────────────────────────────────────────────────────────
  Widget _buildOrderSummary() {
    final deliveryFee =
    _selectedDelivery == 'express' ? 15.0 : _cart.shipping.toDouble();
    final codFee = _paymentType == 'cod' ? 40.0 : 0.0;
    final total = _cart.subtotal + deliveryFee + _cart.tax + codFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Order Summary',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C2416))),
        const SizedBox(height: 14),
        _summaryRow('Subtotal (${_cart.items.length} items)',
            '\$${_cart.subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        _summaryRow(
            'Shipping',
            deliveryFee == 0
                ? 'FREE'
                : '\$${deliveryFee.toStringAsFixed(2)}',
            isGreen: deliveryFee == 0),
        const SizedBox(height: 8),
        _summaryRow(
            'Estimated Tax', '\$${_cart.tax.toStringAsFixed(2)}'),
        if (codFee > 0) ...[
          const SizedBox(height: 8),
          _summaryRow('COD Handling Fee', '₹${codFee.toStringAsFixed(0)}',
              isGreen: false),
        ],
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFEDE8E0))),
        _summaryRow('Total', '\$${total.toStringAsFixed(2)}',
            isBold: true),
      ]),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isBold ? 15 : 13,
                fontWeight:
                isBold ? FontWeight.w700 : FontWeight.normal,
                color: isBold
                    ? const Color(0xFF2C2416)
                    : const Color(0xFF6B5B45))),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 16 : 13,
                fontWeight:
                isBold ? FontWeight.w700 : FontWeight.w500,
                color: isGreen
                    ? const Color(0xFF27AE60)
                    : const Color(0xFF2C2416))),
      ],
    );
  }

  // ── Bottom Bar ───────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2C2416).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _goNext,
          icon: Icon(
            _currentStep == 2 ? Icons.lock_outline : Icons.arrow_forward,
            size: 18,
          ),
          label: Text(_buttonLabel,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B6914),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  // ── Order Success ────────────────────────────────────────────────────────
  Widget _buildOrderSuccess(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child:
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  color: const Color(0xFF8B6914).withOpacity(0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.check_circle,
                  color: Color(0xFF8B6914), size: 60),
            ),
            const SizedBox(height: 24),
            const Text('Order Placed!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2416))),
            const SizedBox(height: 12),
            const Text(
                'Thank you for your purchase.\nYour order will be delivered soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B5B45),
                    height: 1.6)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HomePage()),
                          (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2416),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Continue Shopping',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
            color: const Color(0xFF2C2416).withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2))
      ],
    );
  }

  Widget _radioCircle(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: isSelected
                ? const Color(0xFF8B6914)
                : const Color(0xFFDDD5C8),
            width: 2),
      ),
      child: isSelected
          ? Center(
          child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF8B6914))))
          : null,
    );
  }
}