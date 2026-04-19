import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/groq_config.dart';

// ── Message model ─────────────────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}

// ── Suggested prompts ─────────────────────────────────────────────────────────
const List<Map<String, dynamic>> _suggestedPrompts = [
  {
    'icon': Icons.medical_information_rounded,
    'label': 'Explain a report',
    'text': 'Can you explain what these blood test results mean?',
    'color': Color(0xFF1565C0),
  },
  {
    'icon': Icons.medication_rounded,
    'label': 'Medication info',
    'text': 'What are the side effects of my current medications?',
    'color': Color(0xFF2E7D32),
  },
  {
    'icon': Icons.sick_rounded,
    'label': 'Symptom check',
    'text': 'I have been feeling tired and dizzy lately. What could it be?',
    'color': Color(0xFFE65100),
  },
  {
    'icon': Icons.favorite_rounded,
    'label': 'Health tips',
    'text': 'Give me personalised health tips based on my profile.',
    'color': Color(0xFFAD1457),
  },
];

// ── Main Screen ───────────────────────────────────────────────────────────────
class AiChatScreen extends StatefulWidget {
  final Map<String, dynamic>? preloadedRecord;

  const AiChatScreen({super.key, this.preloadedRecord});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  static const _blue      = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);
  static const _darkText  = Color(0xFF1A1A2E);
  static const _bgColor   = Color(0xFFF5F8FF);

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController     = ScrollController();
  final FocusNode _focusNode                   = FocusNode();

  final List<ChatMessage> _messages                     = [];
  final List<Map<String, dynamic>> _conversationHistory = [];

  bool _isTyping = false;
  Map<String, dynamic>? _userProfile;

  late AnimationController _typingDotController;

  @override
  void initState() {
    super.initState();
    _typingDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingDotController.dispose();
    super.dispose();
  }

  // ── Load user profile ─────────────────────────────────────────────────────
  Future<void> _loadUserProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() => _userProfile = doc.data());
      }
    } catch (_) {}

    if (widget.preloadedRecord != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoSendRecordPrompt(widget.preloadedRecord!);
      });
    }
  }

  // ── Auto-send record prompt — includes OCR text if available ─────────────
  void _autoSendRecordPrompt(Map<String, dynamic> record) {
    final title         = record['title']         ?? 'this medical report';
    final dept          = record['department']    ?? '';
    final doctor        = record['doctor']        ?? '';
    final hospital      = record['hospital']      ?? '';
    final extractedText = record['extractedText'] as String? ?? '';

    final prompt = StringBuffer('Please explain my medical report: "$title"');
    if (dept.isNotEmpty)     prompt.write(' from the $dept department');
    if (doctor.isNotEmpty)   prompt.write(', ordered by $doctor');
    if (hospital.isNotEmpty) prompt.write(' at $hospital');

    if (extractedText.trim().isNotEmpty) {
      // ── Has OCR text → accurate explanation based on actual document ──
      prompt.write(
        '.\n\nHere is the actual text extracted from the document:\n"""\n'
            '$extractedText\n"""\n\n'
            'Please explain this document in simple language. '
            'List all medicines, dosages, and instructions clearly. '
            'What are the key things I should know, '
            'and are there any important values I should discuss with my doctor?',
      );
    } else {
      // ── No OCR text → general explanation based on title only ──
      prompt.write(
        '. What does it mean, what are the key things I should know, '
            'and are there any important values I should discuss with my doctor?',
      );
    }

    _sendMessage(prompt.toString());
  }

  // ── System prompt ─────────────────────────────────────────────────────────
  String _buildSystemPrompt() {
    final p = _userProfile;
    String profileSection = '';
    if (p != null) {
      final name        = p['name']       ?? 'the patient';
      final age         = p['age']        ?? 'unknown';
      final gender      = p['gender']     ?? 'unknown';
      final bloodGroup  = p['bloodGroup'] ?? 'unknown';
      final allergies   = (p['allergies']   as String?)?.trim();
      final conditions  = (p['conditions']  as String?)?.trim();
      final medications = (p['medications'] as String?)?.trim();
      final surgeries   = (p['surgeries']   as String?)?.trim();

      profileSection = '''

Patient Profile:
- Name: $name
- Age: $age
- Gender: $gender
- Blood Group: $bloodGroup${allergies != null && allergies.isNotEmpty ? '\n- Allergies: $allergies' : ''}${conditions != null && conditions.isNotEmpty ? '\n- Known Conditions: $conditions' : ''}${medications != null && medications.isNotEmpty ? '\n- Current Medications: $medications' : ''}${surgeries != null && surgeries.isNotEmpty ? '\n- Past Surgeries: $surgeries' : ''}

Always personalise your responses using this profile. Flag drug interactions with their known allergies or medications, and tailor advice to their age, gender, and conditions.''';
    }

    return '''You are MediVault AI, a compassionate and knowledgeable personal health assistant embedded in the MediVault app — a secure platform for storing and managing lifelong medical records.
$profileSection

Your capabilities:
1. General health Q&A — answer health and medical questions clearly and accurately.
2. Report explanation — help users understand lab results, prescriptions, and medical documents in simple language.
3. Medication information — explain medications, dosages, side effects, and interactions.
4. Symptom checking — listen to symptoms and provide thoughtful, non-alarmist guidance.

Important guidelines:
- Always be empathetic, clear, and non-alarming.
- Speak in simple, plain English — avoid heavy medical jargon unless explaining a term.
- Always remind users to consult a qualified doctor for diagnosis or treatment decisions.
- Never diagnose conditions definitively — say "this could indicate" or "you may want to discuss X with your doctor."
- If a situation sounds like a medical emergency, immediately tell the user to call emergency services.
- Keep responses concise but complete. Use bullet points or numbered lists when listing multiple items.
- You are NOT a replacement for professional medical advice.''';
  }

  // ── Send message — Groq API ───────────────────────────────────────────────
  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isTyping) return;

    _inputController.clear();
    _focusNode.unfocus();

    setState(() {
      _messages.add(ChatMessage(
          text: trimmed, isUser: true, timestamp: DateTime.now()));
      _isTyping = true;
    });

    _conversationHistory.add({
      'role': 'user',
      'content': trimmed,
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(GroqConfig.apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${GroqConfig.apiKey}',
        },
        body: jsonEncode({
          'model': GroqConfig.model,
          'messages': [
            {'role': 'system', 'content': _buildSystemPrompt()},
            ..._conversationHistory,
          ],
          'max_tokens': 1024,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 30));

      debugPrint('GROQ STATUS: ${response.statusCode}');
      debugPrint('GROQ BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data  = jsonDecode(response.body) as Map<String, dynamic>;
        final reply = data['choices'][0]['message']['content']
            .toString()
            .trim();

        _conversationHistory.add({
          'role': 'assistant',
          'content': reply,
        });

        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
              text: reply, isUser: false, timestamp: DateTime.now()));
        });
      } else {
        debugPrint('GROQ ERROR STATUS: ${response.statusCode}');
        debugPrint('GROQ ERROR BODY: ${response.body}');
        _handleApiError('Sorry, I could not get a response. Please try again.');
      }
    } catch (e) {
      debugPrint('GROQ EXCEPTION: $e');
      _handleApiError('Connection error. Please check your internet and try again.');
    }

    _scrollToBottom();
  }

  void _handleApiError(String message) {
    if (_conversationHistory.isNotEmpty &&
        _conversationHistory.last['role'] == 'user') {
      _conversationHistory.removeLast();
    }
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
          text: message, isUser: false,
          timestamp: DateTime.now(), isError: true));
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _conversationHistory.clear();
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    final subtitle = widget.preloadedRecord != null
        ? 'Explaining: ${widget.preloadedRecord!['title'] ?? 'Report'}'
        : 'Powered by Groq';

    return AppBar(
      backgroundColor: _blue,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('MediVault AI',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.white70,
                        fontWeight: FontWeight.w300),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (_messages.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 22),
            tooltip: 'Clear chat',
            onPressed: _showClearDialog,
          ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_blue, _blueLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final name = _userProfile?['name'] as String? ?? 'there';
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_blue, _blueLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: _blue.withValues(alpha: 0.3),
                    blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.psychology_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MediVault AI',
                              style: TextStyle(color: Colors.white,
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Your personal health assistant',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Hello, $name! 👋',
                    style: const TextStyle(color: Colors.white,
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text(
                  'I\'m here to help you understand your health records, '
                      'explain medical reports, answer medication questions, '
                      'and more — all personalised for you.',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.white70, size: 14),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Not a substitute for professional medical advice. '
                              'Always consult your doctor.',
                          style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Try asking...',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _darkText)),
          const SizedBox(height: 12),
          ..._suggestedPrompts.map((p) => _buildSuggestedPrompt(p)),
        ],
      ),
    );
  }

  Widget _buildSuggestedPrompt(Map<String, dynamic> prompt) {
    final color = prompt['color'] as Color;
    return GestureDetector(
      onTap: () => _sendMessage(prompt['text'] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(prompt['icon'] as IconData, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(prompt['label'] as String,
                      style: TextStyle(color: color, fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(prompt['text'] as String,
                      style: const TextStyle(color: _darkText, fontSize: 13, height: 1.3),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  // ── Message list ──────────────────────────────────────────────────────────
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_blue, _blueLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(color: _blue.withValues(alpha: 0.25),
                        blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Text(msg.text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, height: 1.5)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Center(
                  child: Icon(Icons.person_rounded, color: _blue, size: 16)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: msg.isError
                  ? const Color(0xFFFFEBEE)
                  : const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                msg.isError
                    ? Icons.error_outline_rounded
                    : Icons.psychology_rounded,
                color: msg.isError ? const Color(0xFFD32F2F) : _blue,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(msg.text),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: msg.isError ? const Color(0xFFFFEBEE) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(18),
                  ),
                  border: Border.all(
                    color: msg.isError
                        ? const Color(0xFFEF9A9A)
                        : Colors.grey.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormattedText(msg.text, msg.isError),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 10, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(_formatTime(msg.timestamp),
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 10)),
                        if (!msg.isError) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _copyToClipboard(msg.text),
                            child: Icon(Icons.copy_rounded,
                                size: 11, color: Colors.grey.shade400),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Formatted text ────────────────────────────────────────────────────────
  Widget _buildFormattedText(String text, bool isError) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 4));
        continue;
      }

      final numberedMatch = RegExp(r'^(\d+)[.)]\s+(.+)$').firstMatch(trimmed);
      if (numberedMatch != null) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 20, height: 20,
                decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(
                  child: Text(numberedMatch.group(1)!,
                      style: const TextStyle(color: _blue, fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(numberedMatch.group(2)!,
                    style: TextStyle(
                        color: isError ? const Color(0xFFD32F2F) : _darkText,
                        fontSize: 14, height: 1.5)),
              ),
            ],
          ),
        ));
        continue;
      }

      if (trimmed.startsWith('- ') || trimmed.startsWith('• ')) {
        final content = trimmed.substring(2).trim();
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                    color: isError ? const Color(0xFFD32F2F) : _blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(content,
                    style: TextStyle(
                        color: isError ? const Color(0xFFD32F2F) : _darkText,
                        fontSize: 14, height: 1.5)),
              ),
            ],
          ),
        ));
        continue;
      }

      if (trimmed.contains('**')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildRichText(trimmed, isError),
        ));
        continue;
      }

      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(trimmed,
            style: TextStyle(
                color: isError ? const Color(0xFFD32F2F) : _darkText,
                fontSize: 14, height: 1.5)),
      ));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }

  Widget _buildRichText(String text, bool isError) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int last = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(
          text: text.substring(last, match.start),
          style: TextStyle(
              color: isError ? const Color(0xFFD32F2F) : _darkText,
              fontSize: 14, height: 1.5),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
            color: isError ? const Color(0xFFD32F2F) : _darkText,
            fontSize: 14, fontWeight: FontWeight.bold, height: 1.5),
      ));
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(
        text: text.substring(last),
        style: TextStyle(
            color: isError ? const Color(0xFFD32F2F) : _darkText,
            fontSize: 14, height: 1.5),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }

  // ── Typing indicator ──────────────────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30, height: 30,
            decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD), shape: BoxShape.circle),
            child: const Center(
                child: Icon(Icons.psychology_rounded, color: _blue, size: 16)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _typingDotController,
                  builder: (context, child) {
                    final offset =
                    ((_typingDotController.value * 3) - i).clamp(0.0, 1.0);
                    final bounce = (offset < 0.5 ? offset : 1 - offset) * 2;
                    return Transform.translate(
                      offset: Offset(0, -4 * bounce),
                      child: Container(
                        width: 7, height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: _blue.withValues(alpha: 0.5 + 0.5 * bounce),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input bar ─────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12, offset: const Offset(0, -3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _inputController,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: _darkText, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Ask anything about your health...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(_inputController.text),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_inputController.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_blue, _blueLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _blue.withValues(alpha: 0.4),
                      blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: const Center(
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatTime(DateTime dt) {
    final h      = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m      = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Copied to clipboard'),
      backgroundColor: _blue,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Chat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                color: _darkText)),
        content: const Text(
            'This will clear all messages. This action cannot be undone.',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _clearChat(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}