// lib/services/chatbot_service.dart
// Chatbot cerdas dengan context awareness, mood detection, dan crisis protocol

class BotContext {
  final List<String> topics = [];
  String? detectedEmotion;
  int stressLevel = 0; // 0-3
  int turnCount = 0;
  bool crisisDetected = false;
  bool askedFollowUp = false;
  String? lastTopic;
}

class ChatbotService {
  static final BotContext _ctx = BotContext();

  /// Reset konteks (panggil saat chat baru)
  static void resetContext() {
    _ctx.topics.clear();
    _ctx.detectedEmotion = null;
    _ctx.stressLevel = 0;
    _ctx.turnCount = 0;
    _ctx.crisisDetected = false;
    _ctx.askedFollowUp = false;
    _ctx.lastTopic = null;
  }

  /// Proses pesan & return respons
  static String respond(String message, List<Map<String, String>> history) {
    _ctx.turnCount++;
    final m = message.toLowerCase().trim();

    // ── 1. CRISIS DETECTION (prioritas tertinggi) ──────────────────────────
    if (_isCrisis(m)) {
      _ctx.crisisDetected = true;
      return _crisisResponse();
    }

    // ── 2. DETECT EMOTION & TOPIC ─────────────────────────────────────────
    final topic = _detectTopic(m);
    final emotion = _detectEmotion(m);
    _ctx.detectedEmotion = emotion;
    if (topic != null) {
      _ctx.lastTopic = topic;
      if (!_ctx.topics.contains(topic)) _ctx.topics.add(topic);
    }

    // ── 3. CONTEXT-AWARE: apakah jawaban dari follow-up? ──────────────────
    if (_ctx.askedFollowUp && history.length > 1) {
      _ctx.askedFollowUp = false;
      return _respondToFollowUp(m, _ctx.lastTopic);
    }

    // ── 4. SMALL TALK / GREETINGS ─────────────────────────────────────────
    if (_isGreeting(m) && _ctx.turnCount <= 2) return _greetingResponse(m);
    if (_isThankYou(m)) return _thankYouResponse();
    if (_isGoodbye(m)) return _goodbyeResponse();

    // ── 5. FEATURE INQUIRY ────────────────────────────────────────────────
    if (_isFeatureInquiry(m)) return _featureResponse(m);

    // ── 6. TOPIC-BASED RESPONSES ──────────────────────────────────────────
    if (topic != null) {
      _ctx.askedFollowUp = true;
      return _topicResponse(topic, m, emotion);
    }

    // ── 7. CONTEXT FROM HISTORY ───────────────────────────────────────────
    if (_ctx.topics.isNotEmpty) {
      return _continuationResponse(_ctx.topics.last, m);
    }

    // ── 8. GENERIC EMPATHETIC ─────────────────────────────────────────────
    return _genericResponse(_ctx.turnCount);
  }

  // ── Crisis ───────────────────────────────────────────────────────────────
  static bool _isCrisis(String m) {
    const triggers = [
      'bunuh diri', 'mati saja', 'ingin mati', 'tidak mau hidup',
      'mengakhiri hidup', 'tidak ada gunanya hidup', 'lebih baik mati',
      'menyakiti diri', 'melukai diri', 'self harm', 'menyilet',
    ];
    return triggers.any((t) => m.contains(t));
  }

  static String _crisisResponse() =>
      '💙 Saya sangat khawatir dengan apa yang kamu sampaikan, dan saya ingin kamu tahu bahwa kamu sangat berarti.\n\n'
      'Tolong hubungi bantuan sekarang:\n'
      '📞 **Into The Light**: 119 ext 8 (24 jam)\n'
      '📞 **SEJIWA**: 119 ext 8\n'
      '📞 **RSJ Soeharto Heerdjan**: (021) 5682841\n\n'
      'Apakah ada orang terdekat yang bisa kamu hubungi sekarang? Kamu tidak harus menghadapi ini sendirian. 🙏';

  // ── Topic Detection ───────────────────────────────────────────────────────
  static String? _detectTopic(String m) {
    final Map<String, List<String>> topics = {
      'stress': ['stres', 'stress', 'tertekan', 'tekanan', 'beban', 'overwhelmed', 'burnout', 'kewalahan', 'capek', 'kelelahan'],
      'anxiety': ['cemas', 'khawatir', 'takut', 'panik', 'gelisah', 'gugup', 'deg-degan', 'overthinking', 'pikiran berlebihan', 'was-was'],
      'sadness': ['sedih', 'menangis', 'nangis', 'kesepian', 'sendiri', 'hampa', 'kosong', 'muram', 'galau', 'patah hati', 'kecewa'],
      'depression': ['depresi', 'tidak semangat', 'tidak ada harapan', 'putus asa', 'tidak berharga', 'tidak ada tujuan', 'malas', 'lemas'],
      'anger': ['marah', 'kesal', 'frustrasi', 'jengkel', 'benci', 'emosi', 'sebal', 'dongkol'],
      'sleep': ['tidur', 'insomnia', 'susah tidur', 'begadang', 'tidak bisa tidur', 'ngantuk', 'tidurnya'],
      'work': ['kerja', 'kerjaan', 'tugas', 'deadline', 'bos', 'kantor', 'kuliah', 'kampus', 'ujian', 'skripsi', 'dosen', 'teman kerja'],
      'relationship': ['pacar', 'hubungan', 'putus', 'patah hati', 'cinta', 'keluarga', 'orang tua', 'teman', 'sahabat', 'pertemanan', 'konflik'],
      'selfesteem': ['tidak percaya diri', 'minder', 'kurang pede', 'merasa bodoh', 'merasa jelek', 'tidak mampu', 'gagal', 'kegagalan'],
      'happy': ['senang', 'bahagia', 'gembira', 'semangat', 'excited', 'bersyukur', 'alhamdulillah', 'baik-baik', 'baik saja'],
      'meditation': ['meditasi', 'relaksasi', 'pernapasan', 'tenang', 'mindfulness', 'meditasi'],
      'journal': ['jurnal', 'nulis', 'menulis', 'catatan', 'diary'],
      'dass': ['tes', 'test', 'dass', 'screening', 'cek kondisi', 'ukur'],
    };
    for (final entry in topics.entries) {
      if (entry.value.any((kw) => m.contains(kw))) return entry.key;
    }
    return null;
  }

  static String? _detectEmotion(String m) {
    if (m.contains('sangat') || m.contains('banget') || m.contains('sekali') || m.contains('parah'))
      return 'intense';
    if (m.contains('sedikit') || m.contains('agak') || m.contains('lumayan'))
      return 'mild';
    return 'moderate';
  }

  // ── Greeting ──────────────────────────────────────────────────────────────
  static bool _isGreeting(String m) =>
      ['halo', 'hai', 'hi', 'hello', 'hei', 'hey', 'selamat pagi', 'selamat siang',
       'selamat sore', 'selamat malam', 'apa kabar', 'gimana kabar'].any((g) => m.contains(g));

  static String _greetingResponse(String m) {
    final hour = DateTime.now().hour;
    final timeGreet = hour < 12 ? 'Pagi' : hour < 17 ? 'Siang' : hour < 20 ? 'Sore' : 'Malam';
    final responses = [
      'Halo! Selamat $timeGreet 🌿 Senang kamu mampir ke sini. Aku MindCare Assistant — teman curhatmu kapan saja. Bagaimana perasaanmu hari ini?',
      'Hai hai! $timeGreet yang indah 😊 Aku di sini siap mendengarkan. Ada yang ingin kamu ceritakan?',
      'Halo! 🌸 Aku selalu senang setiap kamu hadir di sini. Ceritakan, hari ini bagaimana?',
    ];
    return responses[DateTime.now().second % responses.length];
  }

  static bool _isThankYou(String m) =>
      ['terima kasih', 'makasih', 'thanks', 'tengkyu', 'thx', 'tq', 'terimakasih'].any((t) => m.contains(t));

  static String _thankYouResponse() {
    final responses = [
      'Sama-sama! 💙 Aku senang bisa menemanimu. Ingat, kamu nggak sendirian ya!',
      'Dengan senang hati! 🌿 Kalau ada yang mau kamu ceritakan lagi, aku selalu ada di sini.',
      'Tentu saja! 😊 Merawat kesehatan mental itu penting banget. Kamu sudah melakukan hal yang baik dengan mau bercerita.',
    ];
    return responses[DateTime.now().second % responses.length];
  }

  static bool _isGoodbye(String m) =>
      ['dah', 'bye', 'dadah', 'sampai jumpa', 'pamit', 'cabut', 'tutup', 'keluar'].any((g) => m.contains(g));

  static String _goodbyeResponse() =>
      'Sampai jumpa! 👋 Jaga diri baik-baik ya. Ingat untuk minum air, istirahat cukup, dan cerita lagi kalau butuh teman bicara. Aku selalu ada di sini 💙';

  // ── Feature inquiry ───────────────────────────────────────────────────────
  static bool _isFeatureInquiry(String m) =>
      ['fitur', 'bisa apa', 'apa saja', 'fungsi', 'kegunaan', 'bantuan apa', 'cara'].any((f) => m.contains(f));

  static String _featureResponse(String m) =>
      'MindCare punya banyak fitur untukmu 🌟\n\n'
      '😊 **Mood Tracker** — catat perasaanmu setiap hari\n'
      '✍️ **Jurnal Harian** — tulis cerita & refleksi\n'
      '🧠 **Tes DASS-21** — ukur tingkat stres, cemas & depresi\n'
      '🧘 **Relaksasi** — meditasi & pernapasan terpandu\n'
      '📚 **Artikel** — tips kesehatan mental\n'
      '📊 **Statistik** — lihat perkembangan dari waktu ke waktu\n\n'
      'Ada fitur mana yang ingin kamu coba dulu?';

  // ── Topic Responses ───────────────────────────────────────────────────────
  static String _topicResponse(String topic, String m, String? emotion) {
    final isIntense = emotion == 'intense';
    switch (topic) {
      case 'stress':
        return isIntense
            ? 'Wah, sepertinya beban yang kamu tanggung cukup berat sekarang 😔 Aku ingin kamu tahu — wajar banget merasa seperti ini. Satu langkah kecil yang bisa dilakukan sekarang: tarik napas dalam 4 hitungan, tahan 4, hembuskan 4. Sudah coba belum?\n\nApa yang paling bikin kamu tertekan saat ini?'
            : 'Stres memang bisa datang dari mana saja ya 😌 Coba yuk kita identifikasi dulu — stresnya lebih banyak dari mana: pekerjaan/kuliah, hubungan, atau hal lain?\n\nCeritakan lebih detail, aku ingin benar-benar memahami situasimu.';

      case 'anxiety':
        return 'Kecemasan bisa sangat menguras energi ya 💙 Otak kita kadang terlalu "rajin" memikirkan hal-hal yang belum tentu terjadi.\n\n'
            'Coba teknik grounding: sebutkan 5 hal yang kamu **lihat**, 4 yang bisa kamu **sentuh**, 3 yang kamu **dengar**. Ini membantu pikiran balik ke saat ini.\n\n'
            'Boleh cerita, apa yang lagi kamu khawatirkan?';

      case 'sadness':
        return 'Terima kasih sudah mau berbagi perasaan ini denganku 🌸 Merasa sedih itu manusiawi, dan kamu tidak perlu menahan atau menyembunyikannya.\n\n'
            'Menangis pun boleh — itu cara tubuh melepaskan beban. Aku di sini bersamamu.\n\n'
            'Sudah berapa lama kamu merasa seperti ini?';

      case 'depression':
        return 'Aku sangat menghargai keberanianmu untuk mengungkapkan ini 💙 Perasaan seperti ini berat sekali untuk ditanggung.\n\n'
            'Apakah ada hal kecil yang masih bisa membuatmu sedikit tersenyum hari-hari ini? Tidak perlu besar — bisa sepotong makanan enak, lagu favorit, atau apapun.\n\n'
            'Jika perasaan ini sudah berlangsung lebih dari 2 minggu, berbicara dengan psikolog bisa sangat membantu. Apakah kamu sudah pernah coba konsultasi?';

      case 'anger':
        return 'Marah itu perasaan yang valid dan manusiawi 💪 Yang penting adalah bagaimana kita mengelolanya.\n\n'
            'Coba tarik napas panjang dulu sebelum bereaksi. Jika bisa, cari ruang untuk sendiri sejenak.\n\n'
            'Apa yang membuatmu marah/kesal? Ceritakan — kadang sekadar menceritakan sudah membuat lebih lega.';

      case 'sleep':
        return 'Kurang tidur bisa membuat segalanya terasa lebih berat 🌙 Otak butuh istirahat untuk memproses emosi dengan baik.\n\n'
            'Beberapa hal yang bisa membantu:\n• Matikan layar 1 jam sebelum tidur\n• Coba audio relaksasi di menu Relaksasi MindCare\n• Hindari kafein setelah jam 3 sore\n\n'
            'Sudah berapa lama kamu mengalami masalah tidur ini?';

      case 'work':
        return 'Tekanan dari pekerjaan/kuliah memang sering kali menguras energi mental kita 📚\n\n'
            'Apakah ini soal beban yang terlalu banyak, konflik dengan orang lain, atau perasaan tidak mampu?\n\n'
            'Ceritakan lebih detail — aku ingin bantu kamu temukan cara yang tepat untuk menghadapinya.';

      case 'relationship':
        return 'Masalah hubungan bisa menjadi salah satu sumber stres terbesar dalam hidup 💔\n\n'
            'Apakah ini soal romantic relationship, keluarga, atau pertemanan?\n\n'
            'Aku ingin mendengar ceritamu lebih lengkap. Apa yang sebenarnya terjadi?';

      case 'selfesteem':
        return 'Satu hal yang ingin aku sampaikan: kamu jauh lebih berharga dari yang kamu pikir ⭐\n\n'
            'Perasaan tidak percaya diri sering kali muncul dari perbandingan yang tidak adil — kita membandingkan sisi terbaik orang lain dengan sisi terburuk diri kita.\n\n'
            'Coba ingat satu hal yang kamu lakukan dengan baik minggu ini. Apa itu?';

      case 'happy':
        return 'Wah, senang banget mendengar kamu merasa baik! 🌟🎉\n\n'
            'Momen positif seperti ini penting banget untuk dirayakan dan diingat. Catat di Mood Tracker ya, supaya nanti saat hari kurang baik kamu bisa lihat bahwa ada hari-hari indah juga.\n\n'
            'Apa yang membuat hari ini terasa menyenangkan?';

      case 'meditation':
        return 'Bagus sekali kamu tertarik dengan meditasi! 🧘 Ini salah satu cara paling efektif untuk menjaga ketenangan mental.\n\n'
            'Di menu **Relaksasi** MindCare ada:\n'
            '• Pernapasan 4-7-8 (untuk tidur & relaks)\n'
            '• Box Breathing (untuk fokus & stres akut)\n'
            '• Meditasi Mindfulness (10 menit)\n'
            '• Visualisasi Tempat Aman\n\n'
            'Mulai dari yang 5 menit dulu yuk! Mau aku rekomendasikan yang mana?';

      case 'journal':
        return 'Menulis jurnal itu luar biasa untuk kesehatan mental! ✍️ Banyak penelitian membuktikan efeknya.\n\n'
            'Tips menulis jurnal yang efektif:\n'
            '• Tulis tanpa menghakimi diri sendiri\n'
            '• 3 hal yang kamu syukuri hari ini\n'
            '• Apa yang paling mempengaruhimu hari ini?\n\n'
            'Di menu **Jurnal Harian** MindCare kamu bisa mulai sekarang. Sudah pernah coba?';

      case 'dass':
        return 'Tes DASS-21 adalah cara yang bagus untuk memahami kondisi mentalmu secara lebih objektif 📊\n\n'
            'Tes ini mengukur 3 hal: tingkat **Depresi**, **Kecemasan**, dan **Stres** berdasarkan 1 minggu terakhir.\n\n'
            'Hanya 21 pertanyaan, sekitar 5-7 menit. Hasilnya privat dan hanya tersimpan di perangkatmu.\n\n'
            'Mau mulai tesnya sekarang? Tap menu **Tes Mental** di beranda 🧠';

      default:
        return _genericResponse(_ctx.turnCount);
    }
  }

  // ── Follow-up response ────────────────────────────────────────────────────
  static String _respondToFollowUp(String m, String? topic) {
    // User menjawab follow-up question
    final isLong = m.split(' ').length > 5;
    if (isLong) {
      // Mereka cerita panjang — validasi dulu
      final validations = [
        'Terima kasih sudah mau cerita lebih dalam 🙏 Aku benar-benar mendengarkanmu. ',
        'Aku mengerti sekarang — situasi yang kamu hadapi memang tidak mudah. ',
        'Wow, kamu sudah menanggung banyak ya 💙 Aku sangat menghargai kepercayaanmu. ',
      ];
      final v = validations[DateTime.now().second % validations.length];
      return '$v\n\nDari yang kamu ceritakan, hal yang paling bisa dilakukan sekarang adalah fokus pada satu langkah kecil dulu. Apa satu hal yang menurutmu bisa sedikit meringankan situasinya?';
    } else {
      return 'Aku mengerti. Boleh cerita lebih banyak lagi? Semakin aku memahami situasimu, semakin baik aku bisa menemanimu 💙';
    }
  }

  // ── Continuation ──────────────────────────────────────────────────────────
  static String _continuationResponse(String lastTopic, String m) {
    final continuations = {
      'stress': 'Masih soal stres tadi — apakah ada hal kecil yang bisa kamu delegasikan atau tunda dulu? Kadang memilah prioritas bisa membantu banget.',
      'anxiety': 'Terkait kecemasan yang kamu rasakan — apakah pikirannya sudah agak lebih tenang setelah kita bicara?',
      'sadness': 'Tadi kamu cerita tentang kesedihan — aku masih di sini ya. Ada lagi yang ingin kamu keluarkan?',
      'depression': 'Aku masih memikirkan apa yang kamu ceritakan. Apakah ada satu orang terdekat yang bisa kamu ajak ngobrol hari ini?',
      'relationship': 'Soal hubunganmu tadi — apakah sudah ada upaya untuk berbicara langsung dengan orang tersebut?',
    };
    return continuations[lastTopic] ?? _genericResponse(_ctx.turnCount);
  }

  // ── Generic ───────────────────────────────────────────────────────────────
  static String _genericResponse(int turn) {
    final responses = [
      'Aku mendengarmu 💙 Kadang sekadar bisa mengeluarkan isi hati sudah membuat lebih lega. Ada yang spesifik ingin kamu ceritakan?',
      'Hmm, aku ingin benar-benar memahami perasaanmu. Bisakah kamu ceritakan lebih detail apa yang sedang kamu alami?',
      'Terima kasih sudah mau berbagi denganku 🌿 Setiap orang punya perjuangannya masing-masing, dan tidak apa-apa untuk merasa seperti ini. Apa yang paling berat bagimu saat ini?',
      'Aku di sini bersamamu 🤗 Kalau ada sesuatu yang mengganjal di pikiran atau hati, ceritakan saja — tidak ada yang akan menghakimi di sini.',
      'Mau tanya sesuatu — sudah minum air yang cukup hari ini? Tidur yang cukup? Kadang hal kecil ini pengaruh besar ke perasaan kita lho 💙',
    ];
    return responses[turn % responses.length];
  }

  /// Quick reply suggestions berdasarkan konteks
  static List<String> getSuggestions(String? lastTopic) {
    if (lastTopic == 'stress') {
      return ['Cerita lebih lanjut 📖', 'Teknik relaksasi 🧘', 'Tips manajemen waktu ⏰', 'Aku butuh semangat 💪'];
    }
    if (lastTopic == 'anxiety') {
      return ['Grounding technique 🌱', 'Teknik pernapasan 🌬️', 'Overthinking banget nih', 'Gimana cara tenang?'];
    }
    if (lastTopic == 'sadness') {
      return ['Mau cerita lebih 💬', 'Butuh motivasi 🌟', 'Rekomendasikan jurnal ✍️', 'Tips biar semangat lagi'];
    }
    if (lastTopic == 'sleep') {
      return ['Audio tidur 🌙', 'Tips tidur nyenyak 😴', 'Meditasi sebelum tidur 🧘', 'Sudah seminggu begini'];
    }
    // Default suggestions
    return [
      'Saya sedang stres 😓',
      'Saya merasa cemas 😰',
      'Saya tidak bisa tidur 😴',
      'Ceritain fitur MindCare 📱',
      'Butuh semangat 💪',
      'Saya merasa kesepian 😞',
    ];
  }
}