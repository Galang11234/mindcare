import '../models/models.dart';

class ChatbotService {
  static final List<Map<String, dynamic>> _responses = [
    {
      'keywords': ['halo', 'hai', 'hi', 'hello', 'selamat'],
      'response':
          'Hai! Selamat datang di MindCare 🌿 Saya di sini untuk mendengarkan dan membantu kamu. Bagaimana perasaan kamu hari ini?',
    },
    {
      'keywords': ['stres', 'stress', 'tertekan', 'lelah', 'capek', 'burnout'],
      'response':
          'Saya mengerti kamu sedang merasa stres 😔 Itu wajar terjadi. Coba tarik napas dalam-dalam beberapa kali. Kamu juga bisa mencoba fitur **Relaksasi** di menu untuk membantu menenangkan pikiranmu. Apa yang menyebabkan stresmu saat ini?',
    },
    {
      'keywords': ['cemas', 'anxiety', 'khawatir', 'takut', 'panik', 'gelisah'],
      'response':
          'Kecemasan memang tidak nyaman 💙 Tapi ingat, perasaan ini akan berlalu. Coba teknik 4-7-8: hirup napas 4 detik, tahan 7 detik, hembuskan 8 detik. Apakah ada hal spesifik yang membuatmu cemas?',
    },
    {
      'keywords': ['sedih', 'depresi', 'menangis', 'putus asa', 'tidak bersemangat', 'hampa'],
      'response':
          'Saya sangat senang kamu mau berbagi denganku 🌸 Merasa sedih itu manusiawi. Kamu tidak sendirian. Jika perasaan ini berlangsung lama, pertimbangkan untuk berbicara dengan profesional kesehatan mental. Apakah ada yang ingin kamu ceritakan?',
    },
    {
      'keywords': ['tidur', 'insomnia', 'susah tidur', 'tidak bisa tidur', 'begadang'],
      'response':
          'Gangguan tidur bisa sangat memengaruhi kesehatan mental 🌙 Beberapa tips: hindari layar gadget 1 jam sebelum tidur, buat rutinitas tidur yang konsisten, dan coba dengarkan musik relaksasi. Kamu bisa temukan audio meditasi di fitur Relaksasi.',
    },
    {
      'keywords': ['meditasi', 'relaksasi', 'bernapas', 'tenang'],
      'response':
          'Meditasi dan relaksasi sangat bagus untuk kesehatan mental! 🧘 Kamu bisa mengakses berbagai latihan pernapasan dan meditasi terpandu di menu **Relaksasi**. Hanya perlu 5-10 menit sehari untuk merasakan manfaatnya.',
    },
    {
      'keywords': ['jurnal', 'nulis', 'menulis', 'catatan'],
      'response':
          'Menulis jurnal adalah cara yang bagus untuk memproses perasaan ✍️ Coba tulis di fitur **Jurnal Harian** — tidak perlu panjang, cukup tuliskan apa yang kamu rasakan hari ini. Itu sudah sangat membantu!',
    },
    {
      'keywords': ['tes', 'test', 'dass', 'screening', 'cek kesehatan'],
      'response':
          'Bagus kamu ingin mengetahui kondisi mentalmu! 🎯 Kamu bisa mengakses tes DASS-21 di menu **Tes Mental** untuk mengukur tingkat depresi, kecemasan, dan stres. Hasilnya bersifat pribadi dan hanya untukmu.',
    },
    {
      'keywords': ['psikolog', 'dokter', 'profesional', 'bantuan', 'konseling'],
      'response':
          'Mencari bantuan profesional adalah keputusan yang sangat bijak 💪 Jika kamu membutuhkan, hubungi Into The Light Indonesia: 119 ext 8 atau YKI Hotline: (021) 500-454. Kamu bisa juga berkonsultasi dengan psikolog terdekat.',
    },
    {
      'keywords': ['baik', 'bagus', 'senang', 'bahagia', 'gembira', 'happy'],
      'response':
          'Senang mendengar kamu merasa baik! 🌟 Pertahankan momen positif ini ya. Kamu bisa mencatat perasaan ini di **Mood Tracker** agar kamu bisa melihat pola kebahagiaanmu dari waktu ke waktu.',
    },
    {
      'keywords': ['terima kasih', 'makasih', 'thanks'],
      'response':
          'Sama-sama! 😊 Saya selalu ada di sini untukmu. Jangan ragu untuk berbagi kapan pun kamu perlu. Ingat, menjaga kesehatan mental sama pentingnya dengan kesehatan fisik. Semangat ya! 💚',
    },
  ];

  static String getResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    for (final item in _responses) {
      final keywords = item['keywords'] as List<String>;
      for (final kw in keywords) {
        if (msg.contains(kw)) {
          return item['response'] as String;
        }
      }
    }

    // Default responses
    final defaults = [
      'Terima kasih sudah berbagi denganku 🌿 Bagaimana saya bisa membantu kamu lebih lanjut?',
      'Saya mendengar kamu 💙 Ceritakan lebih lanjut tentang apa yang kamu rasakan.',
      'Itu terdengar penting untukmu. Apakah kamu ingin mengeksplorasi lebih lanjut tentang perasaan ini?',
      'Saya di sini bersamamu 🤗 Kamu bisa mencoba fitur Relaksasi atau Jurnal untuk membantu memprosesnya.',
    ];

    return defaults[DateTime.now().millisecond % defaults.length];
  }

  static List<String> getSuggestions() {
    return [
      'Saya sedang stres 😓',
      'Saya merasa cemas 😰',
      'Saya tidak bisa tidur 😴',
      'Rekomendasikan meditasi 🧘',
      'Bagaimana cara mengelola emosi?',
      'Saya butuh bantuan 🙏',
    ];
  }
}