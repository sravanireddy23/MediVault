import 'package:flutter/material.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  // ── Colors ───────────────────────────────────────────────────────────────────
  static const _blue      = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFFE3F2FD);
  static const _lightBg   = Color(0xFFF5F8FF);
  static const _darkText  = Color(0xFF1A1A2E);

  // ── Chat state ───────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'ai',
      'text': 'Hello! I\'m your personal health assistant powered by Claude AI.\n\nI can help you:\n• Explain your medical reports\n• Answer health questions\n• Suggest diet tips\n• Discuss your medications\n\nHow can I help you today?',
      'time': '10:00 AM',
    },
  ];

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController     = ScrollController();
  bool _isTyping = false;

  // ── Suggestion chips ─────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _suggestions = [
    {'text': 'Explain my CBC report',     'icon': Icons.science_rounded},
    {'text': 'What is HbA1c?',            'icon': Icons.help_outline_rounded},
    {'text': 'Diet tips for diabetes',    'icon': Icons.restaurant_rounded},
    {'text': 'Side effects of Metformin', 'icon': Icons.medication_rounded},
    {'text': 'What does ECG measure?',    'icon': Icons.favorite_rounded},
    {'text': 'Normal blood pressure?',    'icon': Icons.monitor_heart_rounded},
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll to bottom ─────────────────────────────────────────────────────────
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

  // ── Send message ─────────────────────────────────────────────────────────────
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = text.trim();
    _inputController.clear();

    setState(() {
      _messages.add({
        'role': 'user',
        'text': userMsg,
        'time': _currentTime(),
      });
      _isTyping = true;
    });
    _scrollToBottom();

    // TODO: Replace with real Claude API call
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add({
        'role': 'ai',
        'text': _getSimulatedResponse(userMsg),
        'time': _currentTime(),
      });
    });
    _scrollToBottom();
  }

  // ── Simulated response ───────────────────────────────────────────────────────
  String _getSimulatedResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('cbc') || q.contains('blood test')) {
      return 'A CBC (Complete Blood Count) measures:\n\n• Hemoglobin — checks for anemia\n• WBC count — shows infection levels\n• Platelets — blood clotting ability\n• RBC count — oxygen carrying capacity\n\nOnce Claude API is connected, I will give you a detailed explanation of your specific report values!';
    } else if (q.contains('hba1c')) {
      return 'HbA1c (Glycated Hemoglobin) measures your average blood sugar over the past 2-3 months.\n\n• Normal: Below 5.7%\n• Pre-diabetes: 5.7% - 6.4%\n• Diabetes: 6.5% or higher\n\nIt is the gold standard test for monitoring diabetes management.';
    } else if (q.contains('diet') || q.contains('diabetes')) {
      return 'For diabetes management, focus on:\n\n• Low glycemic index foods\n• Whole grains over refined carbs\n• Plenty of vegetables and fiber\n• Lean proteins\n• Limit sugary drinks and sweets\n\nAlways consult your doctor for a personalized diet plan!';
    } else if (q.contains('metformin')) {
      return 'Common side effects of Metformin:\n\n• Nausea or upset stomach\n• Diarrhea\n• Loss of appetite\n\nThese usually improve after a few weeks. Take with food to reduce stomach issues.\n\nAlways consult your doctor before making any changes to your medication.';
    } else if (q.contains('ecg')) {
      return 'An ECG (Electrocardiogram) measures the electrical activity of your heart.\n\nIt can detect:\n• Heart rate and rhythm\n• Signs of a heart attack\n• Enlarged heart\n• Abnormal electrical pathways\n\nUpload your ECG report and I will explain your specific results once Claude API is connected!';
    } else if (q.contains('blood pressure')) {
      return 'Normal blood pressure ranges:\n\n• Normal: Less than 120/80 mmHg\n• Elevated: 120-129 / less than 80\n• High Stage 1: 130-139 / 80-89\n• High Stage 2: 140+ / 90+\n\nRegular monitoring and a healthy lifestyle are key to maintaining normal blood pressure.';
    } else {
      return 'Thank you for your question about "$query".\n\nI am currently running in demo mode. Once the Claude API is connected, I will be able to give you detailed, accurate health information and explain your medical reports.\n\nRemember: Always consult a licensed medical professional for medical advice.';
    }
  }

  String _currentTime() {
    final now    = DateTime.now();
    final hour   = now.hour > 12 ? now.hour - 12 : now.hour == 0 ? 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: Column(
        children: [
          _buildAppBar(),
          _buildSuggestions(),
          Expanded(child: _buildMessageList()),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_blue, _blueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5),
                ),
                child: const Center(
                  child: Icon(Icons.psychology_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Health Assistant',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        CircleAvatar(
                            radius: 4,
                            backgroundColor: Color(0xFF69F0AE)),
                        SizedBox(width: 5),
                        Text(
                          'Online · Powered by Claude',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Suggestion chips ─────────────────────────────────────────────────────────
  Widget _buildSuggestions() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _suggestions.map((s) {
            return GestureDetector(
              onTap: () => _sendMessage(s['text'] as String),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _lightBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(s['icon'] as IconData,
                        size: 14, color: _blue),
                    const SizedBox(width: 6),
                    Text(
                      s['text'] as String,
                      style: const TextStyle(
                          color: _blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Message list ─────────────────────────────────────────────────────────────
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isAi = msg['role'] == 'ai';
        return isAi
            ? _buildAiMessage(msg)
            : _buildUserMessage(msg);
      },
    );
  }

  // ── AI message bubble ────────────────────────────────────────────────────────
  Widget _buildAiMessage(Map<String, dynamic> msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.psychology_rounded,
                  color: _blue, size: 17),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 2),
                  child: Text(
                    'Health Assistant',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg['text'] as String,
                    style: const TextStyle(
                        color: _darkText,
                        fontSize: 13,
                        height: 1.6),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 2),
                  child: Text(
                    msg['time'] as String,
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ── User message bubble ──────────────────────────────────────────────────────
  Widget _buildUserMessage(Map<String, dynamic> msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 60),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_blue, _blueLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    msg['text'] as String,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg['time'] as String,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade400),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.done_all_rounded,
                          size: 12, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Typing indicator ─────────────────────────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.psychology_rounded,
                  color: _blue, size: 17),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                _typingDot(0),
                const SizedBox(width: 4),
                _typingDot(1),
                const SizedBox(width: 4),
                _typingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  // ── Input bar ────────────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.15)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _lightBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _inputController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                    color: _darkText, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ask about your health...',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  border: InputBorder.none,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.health_and_safety_rounded,
                      color: Colors.grey.shade300,
                      size: 18,
                    ),
                  ),
                ),
                onSubmitted: (v) => _sendMessage(v),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(_inputController.text),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_blue, _blueLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _blue.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
