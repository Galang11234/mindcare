import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../services/chatbot_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<_Msg> _messages = [];
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _typing = false;
  bool _useAI = false;
  String? _apiKey;
  List<String> _suggestions = [];
  String? _currentTopic;

  static const _systemPrompt =
    'Kamu adalah MindCare Assistant, sahabat kesehatan mental yang empatik dan natural dalam Bahasa Indonesia sehari-hari.\n\n'
    'KEPRIBADIAN: Hangat seperti sahabat peduli, bukan terapis kaku. Gunakan "kamu" dan "aku". '
    'Sesekali pakai bahasa natural: "banget", "lho", "ya", "dong". '
    'Empati DULU sebelum saran. Tanya satu follow-up di setiap respons.\n\n'
    'ATURAN: Respons 2-4 kalimat, fokus. Gunakan 1-2 emoji natural. '
    'JANGAN langsung kasih solusi — dengarkan dan validasi dulu. '
    'Tanda bahaya → berikan hotline 119 ext 8. '
    'Akhiri dengan pertanyaan atau undangan bercerita.';

  @override
  void initState() {
    super.initState();
    ChatbotService.resetContext();
    _suggestions = ChatbotService.getSuggestions(null);
    _loadApiKey();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _addBotMsg(_welcomeMsg());
    });
  }

  String _welcomeMsg() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat pagi! ☀️ Senang kamu mampir ke sini. Aku MindCare Assistant — teman curhatmu.\n\nBagaimana perasaanmu pagi ini?';
    if (h < 17) return 'Halo! 🌿 Semoga harimu menyenangkan. Ada yang ingin kamu ceritakan hari ini?';
    if (h < 20) return 'Selamat sore! 🌅 Waktunya istirahat sejenak. Aku di sini kalau kamu mau ngobrol.\n\nGimana harimu tadi?';
    return 'Selamat malam 🌙 Aku di sini kalau kamu butuh melepaskan penat.\n\nBagaimana harimu hari ini?';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('claude_api_key');
    if (mounted && key != null && key.isNotEmpty) {
      setState(() { _apiKey = key; _useAI = true; });
    }
  }

  void _addBotMsg(String text) {
    if (!mounted) return;
    setState(() {
      _messages.add(_Msg(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        text: text, isUser: false, time: DateTime.now()));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
      }
    });
  }

  Future<void> _send([String? text]) async {
    final msg = (text ?? _ctrl.text).trim();
    if (msg.isEmpty || _typing) return;
    _ctrl.clear();
    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(_Msg(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        text: msg, isUser: true, time: DateTime.now()));
      _typing = true;
      _suggestions = [];
    });
    _scrollToBottom();

    final delay = (600 + msg.length * 12).clamp(500, 1800);
    await Future.delayed(Duration(milliseconds: delay));

    String response;
    if (_useAI && _apiKey != null) {
      response = await _callClaude(msg);
    } else {
      final history = _messages
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();
      response = ChatbotService.respond(msg, history);
    }

    _currentTopic = _detectTopic(msg);
    if (!mounted) return;
    setState(() {
      _typing = false;
      _messages.add(_Msg(
        id: '${DateTime.now().millisecondsSinceEpoch}b',
        text: response, isUser: false, time: DateTime.now()));
      _suggestions = ChatbotService.getSuggestions(_currentTopic);
    });
    _scrollToBottom();
  }

  String? _detectTopic(String m) {
    final ml = m.toLowerCase();
    if (['stres','tertekan','burnout','capek'].any((k) => ml.contains(k))) return 'stress';
    if (['cemas','khawatir','takut','panik'].any((k) => ml.contains(k))) return 'anxiety';
    if (['sedih','nangis','kesepian'].any((k) => ml.contains(k))) return 'sadness';
    if (['tidur','insomnia','begadang'].any((k) => ml.contains(k))) return 'sleep';
    return null;
  }

  Future<String> _callClaude(String userMsg) async {
    try {
      // Build history (max 16 turns)
      final history = <Map<String,String>>[];
      for (final m in _messages.reversed.take(16).toList().reversed) {
        if (history.isEmpty && !m.isUser) continue;
        history.add({'role': m.isUser ? 'user' : 'assistant', 'content': m.text});
      }
      if (history.isEmpty || history.last['role'] == 'assistant') {
        history.add({'role': 'user', 'content': userMsg});
      }

      final res = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey!,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 350,
          'system': _systemPrompt,
          'messages': history,
        }),
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        return jsonDecode(res.body)['content'][0]['text'] as String;
      }
      return ChatbotService.respond(userMsg, []);
    } catch (_) {
      return ChatbotService.respond(userMsg, []);
    }
  }

  void _showApiDialog() async {
    final ctrl = TextEditingController(text: _apiKey ?? '');
    bool obscure = true;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppTheme.card(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('Claude AI', style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, fontSize: 17, color: AppTheme.text(context))),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Aktifkan Claude AI untuk chatbot yang lebih natural, empatik, dan cerdas.',
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6C5CE7))),
            ),
            const SizedBox(height: 16),
            Text('Anthropic API Key', style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.text(context))),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl, obscureText: obscure,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'sk-ant-api03-...',
                prefixIcon: const Icon(Icons.key_outlined),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setS(() => obscure = !obscure)),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.shield_outlined, size: 13, color: AppTheme.success),
              const SizedBox(width: 6),
              Text('Tersimpan lokal di perangkat ini',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.success)),
            ]),
            if (_apiKey != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('claude_api_key');
                  setState(() { _apiKey = null; _useAI = false; });
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                  ),
                  child: Text('Hapus API Key', textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: AppTheme.danger, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ],
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome, size: 14),
              label: const Text('Aktifkan'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
              onPressed: () async {
                final key = ctrl.text.trim();
                if (key.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('claude_api_key', key);
                  setState(() { _apiKey = key; _useAI = true; });
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF0F4F8),
      appBar: _appBar(isDark),
      body: Column(children: [
        Expanded(child: _msgList()),
        if (_suggestions.isNotEmpty) _suggestionsBar(),
        _inputBar(isDark),
      ]),
    );
  }

  AppBar _appBar(bool isDark) => AppBar(
    backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.text(context), size: 18),
      onPressed: () => Navigator.pop(context),
    ),
    title: Row(children: [
      Stack(children: [
        Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Text('🌿', style: TextStyle(fontSize: 18))),
        ),
        Positioned(right: 0, bottom: 0,
          child: Container(width: 11, height: 11,
            decoration: BoxDecoration(
              color: AppTheme.success, shape: BoxShape.circle,
              border: Border.all(color: isDark ? const Color(0xFF111111) : Colors.white, width: 2),
            ),
          ),
        ),
      ]),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('MindCare Assistant', style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.text(context))),
        Text(
          _typing ? 'sedang mengetik...' : _useAI ? '✨ Claude AI' : '🤖 Mode offline',
          style: GoogleFonts.poppins(fontSize: 10,
              color: _typing ? AppTheme.primary : _useAI ? AppTheme.success : AppTheme.textLt(context)),
        ),
      ]),
    ]),
    actions: [
      GestureDetector(
        onTap: _showApiDialog,
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 12, 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: _useAI ? const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)]) : null,
            color: _useAI ? null : AppTheme.card2(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.auto_awesome, size: 13,
                color: _useAI ? Colors.white : AppTheme.textLt(context)),
            const SizedBox(width: 4),
            Text('AI', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700,
                color: _useAI ? Colors.white : AppTheme.textLt(context))),
          ]),
        ),
      ),
    ],
  );

  Widget _msgList() => ListView.builder(
    controller: _scrollCtrl,
    padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
    itemCount: _messages.length + (_typing ? 1 : 0),
    itemBuilder: (ctx, i) {
      if (_typing && i == _messages.length) return const _TypingBubble();
      final m = _messages[i];
      final prev = i > 0 ? _messages[i-1] : null;
      final showTime = prev == null || m.time.difference(prev.time).inMinutes > 5;
      return Column(children: [
        if (showTime) _timestamp(m.time),
        _bubble(m, i),
      ]);
    },
  );

  Widget _timestamp(DateTime t) {
    final now = DateTime.now();
    final isToday = t.year == now.year && t.month == now.month && t.day == now.day;
    final label = isToday ? DateFormat('HH:mm').format(t) : DateFormat('d MMM, HH:mm', 'id').format(t);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.card2(context), borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: GoogleFonts.poppins(
            fontSize: 10, color: AppTheme.textLt(context))),
      )),
    );
  }

  Widget _bubble(_Msg msg, int idx) {
    final isUser = msg.isUser;
    final isDark = AppTheme.isDark(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(
        left: isUser ? 54 : 0, right: isUser ? 0 : 54, bottom: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(width: 30, height: 30,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                shape: BoxShape.circle),
              child: const Center(child: Text('🌿', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: msg.text));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Disalin!', style: GoogleFonts.poppins(fontSize: 13)),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  gradient: isUser ? const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                  color: isUser ? null : (isDark ? const Color(0xFF1C1C1E) : Colors.white),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  boxShadow: [BoxShadow(
                    color: isUser ? AppTheme.primary.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                    blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: _richText(msg.text, isUser),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _richText(String text, bool isUser) {
    final color = isUser ? Colors.white : AppTheme.text(context);
    final boldColor = isUser ? Colors.white : AppTheme.primary;
    final parts = text.split('**');
    if (parts.length == 1) {
      return Text(text, style: GoogleFonts.poppins(
          fontSize: 14, color: color, height: 1.55));
    }
    return RichText(text: TextSpan(
      children: parts.asMap().entries.map((e) => TextSpan(
        text: e.value,
        style: GoogleFonts.poppins(
          fontSize: 14, height: 1.55,
          fontWeight: e.key.isOdd ? FontWeight.w700 : FontWeight.w400,
          color: e.key.isOdd ? boldColor : color),
      )).toList(),
    ));
  }

  Widget _suggestionsBar() {
    return Container(
      color: AppTheme.isDark(context) ? const Color(0xFF111111) : Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('  Balas cepat:', style: GoogleFonts.poppins(
            fontSize: 10, color: AppTheme.textLt(context))),
        const SizedBox(height: 5),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _suggestions.map((s) => GestureDetector(
            onTap: () => _send(s),
            child: Container(
              margin: const EdgeInsets.only(right: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
              ),
              child: Text(s, style: GoogleFonts.poppins(
                  fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w500)),
            ),
          )).toList()),
        ),
      ]),
    );
  }

  Widget _inputBar(bool isDark) => Container(
    padding: EdgeInsets.fromLTRB(12, 8, 12,
        MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 14),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF111111) : Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
          blurRadius: 12, offset: const Offset(0, -4))],
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 110),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.divider(context)),
          ),
          child: TextField(
            controller: _ctrl, maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.text(context)),
            decoration: InputDecoration(
              hintText: 'Ceritakan perasaanmu...',
              hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textLt(context)),
              border: InputBorder.none, enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none, filled: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            ),
            onChanged: (v) => setState(() {}),
          ),
        ),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: _typing ? null : _send,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46, height: 46,
          decoration: BoxDecoration(
            gradient: (_ctrl.text.isNotEmpty && !_typing) ? const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
            color: (_ctrl.text.isEmpty || _typing) ? AppTheme.card2(context) : null,
            shape: BoxShape.circle,
            boxShadow: (_ctrl.text.isNotEmpty && !_typing) ? [
              BoxShadow(color: AppTheme.primary.withOpacity(0.4),
                  blurRadius: 8, offset: const Offset(0, 3))
            ] : [],
          ),
          child: Icon(Icons.send_rounded,
            color: (_ctrl.text.isNotEmpty && !_typing) ? Colors.white : AppTheme.textLt(context),
            size: 20),
        ),
      ),
    ]),
  );
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(width: 30, height: 30,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
            shape: BoxShape.circle),
          child: const Center(child: Text('🌿', style: TextStyle(fontSize: 14))),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.isDark(context) ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18), topRight: Radius.circular(18),
              bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Row(mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final phase = (_c.value + i / 3) % 1.0;
                final y = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
                return Transform.translate(
                  offset: Offset(0, -6 * y),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.35 + 0.65 * y),
                      shape: BoxShape.circle),
                  ),
                );
              }),
            ),
          ),
        ),
      ]),
    );
  }
}

class _Msg {
  final String id, text; final bool isUser; final DateTime time;
  _Msg({required this.id, required this.text, required this.isUser, required this.time});
}
