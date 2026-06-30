// chatbot_widget.dart ─────────────────────────────────────────────────────
// Rule-based customer support chatbot. Floating action button opens a
// bottom sheet chat UI. Swap _generateReply() with an API call later to
// upgrade to a real AI backend without touching the UI.

import 'dart:async';
import 'package:flutter/material.dart';

const _bg = Color(0xFFF8F5F0);
const _dark = Color(0xFF2C2416);
const _gold = Color(0xFF8B6914);
const _muted = Color(0xFF9B8B75);

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, this.isUser);
}

/// Floating chat button — drop this into a Stack at the root of HomePage
/// (or any screen) to give users persistent access to support.
class ChatbotLauncher extends StatefulWidget {
  const ChatbotLauncher({super.key});

  @override
  State<ChatbotLauncher> createState() => _ChatbotLauncherState();
}

class _ChatbotLauncherState extends State<ChatbotLauncher> {
  void _openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChatSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openChat(context),
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: _dark,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: _dark.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: const Icon(Icons.support_agent_outlined, color: Colors.white, size: 26),
      ),
    );
  }
}

class _ChatSheet extends StatefulWidget {
  const _ChatSheet();

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isTyping = false;

  static const _quickReplies = [
    'Track my order',
    'Return policy',
    'Shipping info',
    'Talk to a human',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
        "🦊 Hi! I'm Kiro, your AI shopping assistant. How can I assist you?",
        false));
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text.trim(), true));
      _isTyping = true;
    });
    _inputCtrl.clear();
    _scrollToBottom();

    // Simulated "thinking" delay before bot replies.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(_generateReply(text), false));
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  /// Rule-based reply engine. Swap this with an API call to upgrade later:
  ///   final reply = await MyAiApi.ask(userText);
  String _generateReply(String userText) {
    final t = userText.toLowerCase();

    if (t.contains('track') || t.contains('order status') || t.contains('where is my')) {
      return 'You can track your order from My Account → Order History. '
          'You\'ll receive an email with tracking details once your order ships.';
    }
    if (t.contains('return') || t.contains('refund') || t.contains('exchange')) {
      return 'We offer free returns within 30 days of delivery for items in original '
          'condition. Refunds are processed within 5-7 business days after we receive '
          'the item.';
    }
    if (t.contains('shipping') || t.contains('delivery') || t.contains('deliver')) {
      return 'Standard shipping takes 5-10 business days. Orders over \$500 qualify '
          'for free shipping. White-glove delivery is available at checkout for '
          'large furniture pieces.';
    }
    if (t.contains('payment') || t.contains('pay') || t.contains('card')) {
      return 'We accept all major credit cards, PayPal, and Apple Pay. All transactions '
          'are encrypted and processed securely at checkout.';
    }
    if (t.contains('cancel')) {
      return 'Orders can be cancelled within 24 hours of purchase from My Account → '
          'Order History → Cancel Order. After that, please contact support for '
          'assistance.';
    }
    if (t.contains('size') || t.contains('dimension') || t.contains('measurement')) {
      return 'Each product page lists exact dimensions under the "Material & Dimensions" '
          'section. If you need help choosing the right size for your space, our design '
          'team is happy to assist.';
    }
    if (t.contains('warranty')) {
      return 'All Maison Elite furniture comes with a 5-year warranty against '
          'manufacturing defects. Extended warranty plans are available at checkout.';
    }
    if (t.contains('human') || t.contains('agent') || t.contains('representative') || t.contains('person')) {
      return 'I\'ll connect you with a member of our support team. You can also reach '
          'us directly at hello@maisonelite.com or +1 (800) 555-1234, available '
          'Monday-Saturday, 9am-7pm EST.';
    }
    if (t.contains('hi') || t.contains('hello') || t.contains('hey')) {
      return 'Hello! How can I help you with your order or our collection today?';
    }
    if (t.contains('thank')) {
      return 'You\'re welcome! Is there anything else I can help with?';
    }

    return 'I\'m not totally sure about that one. You can reach our support team '
        'directly at hello@maisonelite.com, or try asking about orders, shipping, '
        'returns, or payments.';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          _buildHeader(context),
          Expanded(child: _buildMessageList()),
          if (_messages.length <= 1) _buildQuickReplies(),
          _buildInputBar(),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: const BoxDecoration(
        color: _dark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle),
          child: const Icon(Icons.support_agent_outlined, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Kiro',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            Text('Usually replies instantly',
                style: TextStyle(color: Colors.white60, fontSize: 11)),
          ]),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, color: Colors.white70, size: 22),
        ),
      ]),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == _messages.length && _isTyping) {
          return _buildTypingBubble();
        }
        return _buildBubble(_messages[i]);
      },
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isUser ? _gold : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(msg.isUser ? 14 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 14),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontSize: 13.5,
            color: msg.isUser ? Colors.white : _dark,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const _TypingDots(),
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _quickReplies.map((q) {
          return GestureDetector(
            onTap: () => _send(q),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDDD5C8)),
              ),
              child: Text(q, style: const TextStyle(fontSize: 12, color: _dark)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: _dark.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _inputCtrl,
            style: const TextStyle(fontSize: 13.5, color: _dark),
            decoration: InputDecoration(
              hintText: 'Type a message…',
              hintStyle: const TextStyle(color: _muted, fontSize: 13),
              filled: true,
              fillColor: _bg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            ),
            onSubmitted: _send,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _send(_inputCtrl.text),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_ctrl.value - (i * 0.2)) % 1.0;
            final scale = t < 0.5 ? 1.0 + (t * 0.8) : 1.4 - ((t - 0.5) * 0.8);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale.clamp(1.0, 1.4),
                child: Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(color: _muted, shape: BoxShape.circle),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
