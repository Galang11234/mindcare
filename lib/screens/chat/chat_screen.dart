import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../utils/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _typing = false;
  bool _useAI = false;
  String? _apiKey;

  static const _systemPrompt =
      'Kamu adalah MindCare Assistant, pendamping kesehatan mental yang empatik dan hangat dalam Bahasa Indonesia. '
      'Tugasmu: mendengarkan dengan empati, memberikan dukungan emosional, saran praktis berbasis evidence, '
      'merekomendasikan fitur MindCare (Mood Tracker, Jurnal, Relaksasi, Tes DASS-21), dan mengarahkan ke profesional jika serius. '
      'Aturan: gunakan Bahasa Indonesia hangat, jangan diagnosis medis, jika ada tanda bahaya berikan hotline 119 ext 8, '
      'respons 2-4 kalimat dengan emoji secukupnya, tanyakan follow-up.';

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _messages.add(ChatMessage(
      id: '0', isUser: false, time: DateTime.now(),
      text: 'Halo! Saya MindCare Assistant 🌿\n\nSaya di sini untuk mendengarkan dan menemanimu. Bagaimana perasaanmu hari ini?',
    ));
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('claude_api_key');
    if (mounted && key != null && key.isNotEmpty) {
      setState(() { _apiKey = key; _useAI = true; });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() => Future.delayed(const Duration(milliseconds: 150), () {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  });

  Future<void> _send([String? text]) async {
    final msg = (text ?? _ctrl.text).trim();
    if (msg.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: msg, isUser: true, time: DateTime.now()));
      _typing = true;
    });
    _scrollToBottom();
    if (_useAI && _apiKey != null) {
      await _aiResponse(msg);
    } else {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _rule(msg), isUser: false, time: DateTime.now()));
      });
    }
    _scrollToBottom();
  }

  Future<void> _aiResponse(String userMsg) async {
    try {
      final history = _messages.where((m) => m.id != '0')
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();
      final res = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey!,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-3-5-sonnet-20240620',
          'max_tokens': 500,
          'system': _systemPrompt,
          'messages': history,
        }),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _typing = false;
          _messages.add(ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: data['content'][0]['text'] as String,
            isUser: false, time: DateTime.now()));
        });
      } else {
        final fallback = _rule(userMsg);
        setState(() {
          _typing = false;
          _messages.add(ChatMessage(
            id: 'err', text: 'Gagal konek AI. Pakai mode offline.',
            isUser: false, time: DateTime.now()));
        });
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: fallback, isUser: false, time: DateTime.now()));
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _typing = false; });
    }
  }

  String _rule(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('stres') || m.contains('tertekan') || m.contains('lelah') || m.contains('burnout'))
      return 'Saya mengerti kamu sedang merasa tertekan 😔 Itu sangat wajar. Coba tarik napas dalam-dalam — hirup 4 detik, tahan 4, hembuskan 4. Apa yang paling menjadi bebanmu saat ini?';
    if (m.contains('cemas') || m.contains('khawatir') || m.contains('takut') || m.contains('panik'))
      return 'Kecemasan itu sangat melelahkan 💙 Tapi ingat, ini akan berlalu. Coba teknik grounding: perhatikan 5 hal yang kamu lihat, 4 yang bisa kamu sentuh, 3 yang kamu dengar. Apa yang membuatmu cemas?';
    if (m.contains('sedih') || m.contains('depresi') || m.contains('menangis') || m.contains('putus asa'))
      return 'Terima kasih sudah percaya berbagi denganku 🌸 Merasa sedih itu manusiawi. Jika perasaan ini berlangsung lebih dari 2 minggu, pertimbangkan berbicara dengan profesional. Ada yang ingin kamu ceritakan?';
    if (m.contains('tidur') || m.contains('insomnia') || m.contains('begadang'))
      return 'Gangguan tidur sangat berpengaruh pada kesehatan mental 🌙 Coba matikan layar 1 jam sebelum tidur dan gunakan fitur Relaksasi di MindCare untuk membantu tidur lebih nyenyak.';
    if (m.contains('baik') || m.contains('senang') || m.contains('bahagia'))
      return 'Senang sekali mendengar itu! 🌟 Momen positif ini layak dirayakan. Yuk catat di Mood Tracker supaya kamu bisa melihat polanya nanti!';
    if (m.contains('terima kasih') || m.contains('makasih'))
      return 'Sama-sama! 😊 Ingat, merawat kesehatan mental adalah bentuk cinta pada dirimu sendiri. Semangat ya! 💚';
    if (m.contains('meditasi') || m.contains('relaksasi'))
      return 'Pilihan yang bagus! 🧘 Cek menu Relaksasi di MindCare — ada 6 latihan pernapasan dan meditasi terpandu yang bisa kamu coba kapan saja.';
    if (m.contains('jurnal') || m.contains('nulis'))
      return 'Menulis jurnal sangat membantu memproses perasaan ✍️ Coba fitur Jurnal Harian di MindCare — tidak perlu panjang, cukup 5-10 menit saja!';
    return 'Saya mendengarmu 💙 Ceritakan lebih lanjut apa yang kamu rasakan. Saya di sini bersamamu, tidak ke mana-mana.';
  }

  void _showApiDialog() async {
    final ctrl = TextEditingController(text: _apiKey ?? '');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Text('✨', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text('Aktifkan Claude AI', style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700, color: AppTheme.text(context))),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Masukkan Anthropic API key untuk mendapatkan respons AI yang lebih cerdas dan empatik.',
              style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMed(context))),
          const SizedBox(height: 16),
          TextField(controller: ctrl,
            decoration: const InputDecoration(
                hintText: 'sk-ant-api03-...', prefixIcon: Icon(Icons.key_outlined)),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.lock_outline, size: 12, color: AppTheme.success),
            const SizedBox(width: 4),
            Expanded(child: Text('Key hanya tersimpan di perangkat ini.',
                style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.success))),
          ]),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(onPressed: () async {
            final key = ctrl.text.trim();
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('claude_api_key', key);
            setState(() { _apiKey = key.isEmpty ? null : key; _useAI = key.isNotEmpty; });
            if (ctx.mounted) Navigator.pop(ctx);
          }, child: const Text('Aktifkan')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final suggestions = [
      'Saya sedang stres 😓', 'Saya merasa cemas 😰',
      'Saya tidak bisa tidur 😴', 'Rekomendasikan relaksasi 🧘',
    ];
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.card(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.text(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark]),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('🌿', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MindCare Assistant', style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, fontSize: 15,
                color: AppTheme.text(context))),
            Text(_useAI ? '✨ Claude AI aktif' : '🤖 Mode offline',
                style: GoogleFonts.poppins(fontSize: 10,
                    color: _useAI ? AppTheme.primary : AppTheme.textLt(context))),
          ]),
        ]),
        actions: [
          GestureDetector(
            onTap: _showApiDialog,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _useAI
                    ? AppTheme.primary.withOpacity(0.15)
                    : (isDark ? AppTheme.bgCard2Dark : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _useAI ? AppTheme.primary : Colors.transparent),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.psychology_outlined,
                    size: 16, color: _useAI ? AppTheme.primary : AppTheme.textLt(context)),
                const SizedBox(width: 4),
                Text('AI', style: GoogleFonts.poppins(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: _useAI ? AppTheme.primary : AppTheme.textLt(context))),
              ]),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_typing ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (_typing && i == _messages.length) return const _TypingBubble();
              return _Bubble(msg: _messages[i]);
            },
          ),
        ),

        // Suggestions strip
        if (_messages.length <= 2)
          Container(
            color: AppTheme.card(context),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('  Mulai dengan:', style: GoogleFonts.poppins(
                  fontSize: 10, color: AppTheme.textLt(context))),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: suggestions.map((s) => GestureDetector(
                  onTap: () => _send(s),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Text(s, style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w500)),
                  ),
                )).toList()),
              ),
              const SizedBox(height: 6),
            ]),
          ),

        // Input bar
        Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20,
              MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.card(context),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20, offset: const Offset(0, 5))],
            ),
            child: Row(children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: TextField(
                  controller: _ctrl,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.text(context)),
                  decoration: InputDecoration(
                    hintText: 'Ceritakan perasaanmu...',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 14, color: AppTheme.textLt(context)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: _typing ? null : _send,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: _typing
                        ? null
                        : const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryDark]),
                    color: _typing ? AppTheme.textLt(context) : null,
                    shape: BoxShape.circle,
                    boxShadow: _typing ? [] : [BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ), const SizedBox(width: 4),
          ]),
        ),),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage msg;
  const _Bubble({required this.msg});
  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    final isDark = AppTheme.isDark(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark]),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🌿', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [AppTheme.primary, Color(0xFF38B2AC)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight)
                        : null,
                    color: isUser ? null : (isDark ? AppTheme.bgCardDark : Colors.white),
                    borderRadius: BorderRadius.circular(22).copyWith(
                      bottomLeft: isUser ? null : const Radius.circular(6),
                      bottomRight: isUser ? const Radius.circular(6) : null,
                    ),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(isUser ? 0.1 : 0.04),
                      blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Text(msg.text,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isUser ? Colors.white : AppTheme.text(context),
                          height: 1.55)),
                ),
                const SizedBox(height: 3),
                Text(
                  '${msg.time.hour.toString().padLeft(2,'0')}:${msg.time.minute.toString().padLeft(2,'0')}',
                  style: GoogleFonts.poppins(fontSize: 9, color: AppTheme.textLt(context)),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1000))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark]),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Text('🌿', style: TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.bgCardDark : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18), topRight: Radius.circular(18),
              bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4),
            ),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Row(mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = (_ctrl.value - i * 0.15).clamp(0.0, 1.0);
                final scale = 0.6 + 0.4 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.4 + 0.6 * scale),
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