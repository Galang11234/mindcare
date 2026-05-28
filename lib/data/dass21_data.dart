class Dass21Data {
  static const List<Map<String, dynamic>> questions = [
    {
      'id': 1,
      'text': 'Saya merasa sulit untuk menjadi tenang setelah sesuatu yang membuat saya kesal',
      'scale': 'S', // Stress
    },
    {
      'id': 2,
      'text': 'Saya menyadari mulut saya kering',
      'scale': 'A', // Anxiety
    },
    {
      'id': 3,
      'text': 'Saya tidak bisa merasakan perasaan positif sama sekali',
      'scale': 'D', // Depression
    },
    {
      'id': 4,
      'text': 'Saya mengalami kesulitan bernapas (misalnya napas cepat, kesulitan bernapas tanpa melakukan aktivitas fisik)',
      'scale': 'A',
    },
    {
      'id': 5,
      'text': 'Saya merasa sulit untuk memulai kegiatan apapun',
      'scale': 'D',
    },
    {
      'id': 6,
      'text': 'Saya cenderung bereaksi berlebihan terhadap situasi',
      'scale': 'S',
    },
    {
      'id': 7,
      'text': 'Saya mengalami gemetar (misalnya di tangan)',
      'scale': 'A',
    },
    {
      'id': 8,
      'text': 'Saya merasa banyak menghabiskan energi karena kecemasan',
      'scale': 'S',
    },
    {
      'id': 9,
      'text': 'Saya khawatir tentang situasi dimana saya mungkin panik dan mempermalukan diri sendiri',
      'scale': 'A',
    },
    {
      'id': 10,
      'text': 'Saya merasa tidak ada yang bisa saya nantikan',
      'scale': 'D',
    },
    {
      'id': 11,
      'text': 'Saya merasa agitasi (tidak nyaman/tidak bisa diam)',
      'scale': 'S',
    },
    {
      'id': 12,
      'text': 'Saya merasa sulit untuk rileks',
      'scale': 'S',
    },
    {
      'id': 13,
      'text': 'Saya merasa sedih dan tertekan',
      'scale': 'D',
    },
    {
      'id': 14,
      'text': 'Saya tidak bisa mentolerir gangguan apapun yang menghalangi saya dari apa yang sedang saya lakukan',
      'scale': 'S',
    },
    {
      'id': 15,
      'text': 'Saya merasa hampir panik',
      'scale': 'A',
    },
    {
      'id': 16,
      'text': 'Saya tidak bisa bersemangat tentang apapun',
      'scale': 'D',
    },
    {
      'id': 17,
      'text': 'Saya merasa tidak berharga sebagai seorang manusia',
      'scale': 'D',
    },
    {
      'id': 18,
      'text': 'Saya merasa sangat mudah tersinggung',
      'scale': 'S',
    },
    {
      'id': 19,
      'text': 'Saya menyadari detak jantung saya tanpa melakukan aktivitas fisik (misalnya merasakan detak jantung meningkat)',
      'scale': 'A',
    },
    {
      'id': 20,
      'text': 'Saya merasa takut tanpa alasan yang jelas',
      'scale': 'A',
    },
    {
      'id': 21,
      'text': 'Saya merasa hidup tidak berharga',
      'scale': 'D',
    },
  ];

  // Indices for each scale (0-based)
  static const List<int> depressionIndices = [2, 4, 9, 12, 15, 16, 20];
  static const List<int> anxietyIndices = [1, 3, 6, 8, 14, 18, 19];
  static const List<int> stressIndices = [0, 5, 7, 10, 11, 13, 17];

  static const List<String> answerOptions = [
    'Tidak pernah',
    'Kadang-kadang',
    'Cukup sering',
    'Sangat sering / selalu',
  ];

  static Map<String, int> calculateScores(List<int> answers) {
    int depression = 0, anxiety = 0, stress = 0;

    for (final i in depressionIndices) {
      depression += answers[i] * 2;
    }
    for (final i in anxietyIndices) {
      anxiety += answers[i] * 2;
    }
    for (final i in stressIndices) {
      stress += answers[i] * 2;
    }

    return {
      'depression': depression,
      'anxiety': anxiety,
      'stress': stress,
    };
  }

  static String getSeverityColor(String level) {
    switch (level) {
      case 'Normal':
        return '#00B894';
      case 'Ringan':
        return '#FDCB6E';
      case 'Sedang':
        return '#E17055';
      case 'Berat':
        return '#D63031';
      case 'Sangat Berat':
        return '#C0392B';
      default:
        return '#636E72';
    }
  }

  static String getRecommendation(String depressionLevel, String anxietyLevel, String stressLevel) {
    final levels = [depressionLevel, anxietyLevel, stressLevel];
    if (levels.contains('Sangat Berat') || levels.contains('Berat')) {
      return 'Hasil tesmu menunjukkan kamu mungkin sedang mengalami kesulitan yang cukup serius. Kami sangat menyarankan kamu untuk segera berbicara dengan profesional kesehatan mental. Kamu tidak harus menghadapi ini sendirian. 💙';
    } else if (levels.contains('Sedang')) {
      return 'Kamu sedang mengalami beberapa tantangan. Coba praktikkan teknik relaksasi, jaga pola tidur, dan jangan ragu berbagi dengan orang tepercaya. Jika perasaan ini berlanjut, pertimbangkan konsultasi profesional.';
    } else if (levels.contains('Ringan')) {
      return 'Kamu menunjukkan beberapa tanda stres atau kecemasan ringan. Ini adalah kesempatan bagus untuk mulai mempraktikkan self-care secara rutin. Fitur Relaksasi dan Jurnal di MindCare bisa membantu.';
    } else {
      return 'Bagus sekali! Hasil tesmu menunjukkan kondisi mental yang sehat. Tetap jaga kebiasaan positifmu dan lanjutkan penggunaan MindCare untuk memantau kondisimu secara rutin. 🌟';
    }
  }
}