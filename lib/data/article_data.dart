import '../models/models.dart';

class ArticleData {
  static final List<Article> articles = [
    Article(
      id: '1',
      title: 'Mengenal Tanda-Tanda Stres dan Cara Mengatasinya',

      summary: 'Stres adalah respons normal tubuh terhadap tekanan. Pelajari cara mengenali dan mengelolanya dengan efektif.',
      content: '''Stres adalah respons alami tubuh terhadap situasi yang menekan atau mengancam. Dalam jumlah yang tepat, stres bahkan bisa membantu kita menjadi lebih fokus dan produktif. Namun, stres yang berlebihan atau berkepanjangan dapat berdampak buruk pada kesehatan fisik dan mental.

**Tanda-tanda stres yang perlu diperhatikan:**
• Sering merasa lelah tanpa sebab yang jelas
• Sulit berkonsentrasi atau membuat keputusan
• Mudah marah atau tersinggung
• Gangguan tidur (susah tidur atau tidur terlalu banyak)
• Sakit kepala, nyeri otot, atau masalah pencernaan
• Menarik diri dari lingkungan sosial

**Cara efektif mengatasi stres:**

1. **Teknik pernapasan dalam** - Bernapas perlahan dan dalam dapat mengaktifkan sistem saraf parasimpatis yang menenangkan tubuh.

2. **Olahraga teratur** - Minimal 30 menit berjalan kaki setiap hari dapat secara signifikan mengurangi hormon stres.

3. **Tidur yang cukup** - Usahakan tidur 7-9 jam setiap malam untuk memberikan waktu bagi otak untuk memulihkan diri.

4. **Berbicara dengan orang terpercaya** - Berbagi beban dengan teman atau keluarga dapat meringankan tekanan emosional.

5. **Batasi penggunaan media sosial** - Paparan berlebihan terhadap berita negatif dapat meningkatkan kecemasan.

Ingat, meminta bantuan adalah tanda kekuatan, bukan kelemahan!''',
      category: 'Stres',
      emoji: '😤',
      readMinutes: 4,
      isPremium: false,
    ),
    Article(
      id: '2',
      title: 'Pentingnya Self-Care untuk Kesehatan Mental',

      summary: 'Self-care bukan kemewahan, melainkan kebutuhan dasar. Pelajari praktik perawatan diri yang bisa kamu lakukan sehari-hari.',
      content: '''Self-care atau perawatan diri adalah segala tindakan yang kita lakukan secara sadar untuk menjaga kesehatan fisik, mental, dan emosional kita. Banyak orang menganggap self-care sebagai kemewahan, padahal ini adalah kebutuhan dasar yang penting.

**Kenapa self-care penting?**
Self-care membantu mencegah burnout, meningkatkan ketahanan mental, dan memungkinkan kita untuk hadir sepenuhnya untuk orang-orang yang kita cintai. Seperti instruksi di pesawat terbang — pasang masker oksigenmu sendiri sebelum membantu orang lain.

**5 Dimensi Self-Care:**

**1. Fisik**
• Tidur yang cukup dan berkualitas
• Makan makanan bergizi
• Berolahraga secara teratur
• Menjaga kebersihan diri

**2. Emosional**
• Mengakui dan menerima perasaanmu
• Menulis jurnal
• Menangis jika perlu — itu menyehatkan!
• Menetapkan batasan yang sehat

**3. Mental**
• Membaca buku
• Belajar hal baru
• Membatasi paparan berita negatif
• Meditasi atau mindfulness

**4. Sosial**
• Menjaga hubungan dengan orang-orang positif
• Menghabiskan waktu bersama keluarga
• Bergabung dengan komunitas

**5. Spiritual**
• Menemukan makna dan tujuan hidup
• Bersyukur setiap hari
• Menikmati alam

Mulailah dengan satu langkah kecil hari ini!''',
      category: 'Self-Care',
      emoji: '💆',
      readMinutes: 5,
      isPremium: false,
    ),
    Article(
      id: '3',
      title: 'Kecemasan: Memahami dan Mengelola Anxiety',
      summary: 'Kecemasan adalah pengalaman universal. Pelajari strategi berbasis bukti untuk mengelola anxiety sehari-hari.',
      content: '''Kecemasan atau anxiety adalah respons normal terhadap ancaman yang dirasakan. Namun, ketika kecemasan menjadi berlebihan atau tidak proporsional, ia dapat mengganggu kehidupan sehari-hari.

**Jenis-jenis kecemasan umum:**
• Generalized Anxiety Disorder (GAD) - kekhawatiran berlebihan tentang banyak hal
• Social Anxiety - ketakutan berlebihan dalam situasi sosial
• Panic Disorder - serangan panik yang tiba-tiba
• Specific Phobia - ketakutan berlebihan terhadap objek/situasi tertentu

**Gejala fisik kecemasan:**
• Jantung berdegup kencang
• Keringat berlebihan
• Gemetar atau tremor
• Sesak napas
• Mual atau sakit perut
• Pusing

**Teknik mengelola kecemasan:**

**Teknik 5-4-3-2-1 (Grounding)**
Ketika cemas melanda, identifikasi:
• 5 hal yang bisa kamu LIHAT
• 4 hal yang bisa kamu SENTUH
• 3 hal yang bisa kamu DENGAR
• 2 hal yang bisa kamu CIUM
• 1 hal yang bisa kamu RASAKAN

**Teknik Box Breathing:**
1. Hirup napas selama 4 hitungan
2. Tahan selama 4 hitungan
3. Hembuskan selama 4 hitungan
4. Tahan selama 4 hitungan
5. Ulangi 4-6 kali

**Cognitive Restructuring:**
Tanyakan pada dirimu: "Apakah pikiran ini berdasarkan fakta atau asumsi? Apa kemungkinan terburuknya? Seberapa besar kemungkinan itu terjadi?"

Jika kecemasan terasa membebani, jangan ragu mencari bantuan profesional.''',
      category: 'Kecemasan',
      emoji: '😰',
      readMinutes: 6,
      isPremium: true,
    ),
    Article(
      id: '4',
      title: 'Mindfulness: Hidup di Saat Ini',
      summary: 'Mindfulness adalah latihan sederhana namun kuat untuk meningkatkan kesejahteraan mental. Pelajari cara mempraktikkannya.',
      content: '''Mindfulness adalah praktik memusatkan perhatian pada momen saat ini dengan penuh kesadaran dan tanpa penilaian. Penelitian menunjukkan bahwa mindfulness dapat mengurangi stres, kecemasan, dan depresi secara signifikan.

**Manfaat Mindfulness yang Terbukti Secara Ilmiah:**
• Mengurangi stres dan kecemasan
• Meningkatkan fokus dan konsentrasi
• Memperbaiki kualitas tidur
• Meningkatkan regulasi emosi
• Mengurangi gejala depresi
• Meningkatkan rasa syukur dan kebahagiaan

**Cara Memulai Mindfulness:**

**Meditasi Pernapasan (5 menit)**
1. Duduk nyaman dengan punggung tegak
2. Tutup mata, letakkan tangan di lutut
3. Fokuskan perhatian pada napasmu
4. Rasakan udara masuk dan keluar
5. Ketika pikiran mengembara, bawa kembali perhatianmu ke napas dengan lembut
6. Tidak perlu menghakimi dirimu jika pikiran mengembara

**Mindful Eating**
Makan dengan perlahan, perhatikan rasa, tekstur, dan aroma makanan. Matikan layar saat makan.

**Body Scan**
Berbaring nyaman. Secara perlahan alihkan perhatian dari ujung kaki hingga kepala, rasakan setiap bagian tubuh.

**Mindful Walking**
Saat berjalan, perhatikan sensasi kaki menyentuh tanah, gerakan tubuh, dan lingkungan sekitar.

Mulailah dengan 5 menit sehari dan tingkatkan secara bertahap.''',
      category: 'Mindfulness',
      emoji: '🧘',
      readMinutes: 5,
      isPremium: true,
    ),
    Article(
      id: '5',
      title: 'Cara Membangun Ketahanan Mental (Resiliensi)',
      summary: 'Resiliensi adalah kemampuan bangkit dari kesulitan. Ini bukan bawaan lahir — ini keterampilan yang bisa dipelajari.',
      content: '''Resiliensi atau ketahanan mental adalah kemampuan seseorang untuk beradaptasi dan bangkit kembali dari adversitas, trauma, atau stres yang signifikan. Kabar baiknya: resiliensi bisa dilatih dan dikembangkan.

**4 Pilar Resiliensi:**

**1. Koneksi Sosial**
Hubungan yang kuat dengan orang lain adalah fondasi resiliensi. Cultivate jaringan dukungan yang kuat — keluarga, teman, komunitas.

**2. Makna dan Tujuan**
Orang yang memiliki "alasan untuk hidup" lebih tahan terhadap kesulitan. Temukan hal-hal yang memberikan makna bagimu.

**3. Kemampuan Beradaptasi**
Fleksibilitas dalam berpikir dan bertindak sangat penting. Latih dirimu untuk melihat perubahan sebagai peluang, bukan ancaman.

**4. Self-Efficacy**
Keyakinan pada kemampuan diri sendiri. Mulai dari pencapaian kecil dan bangun kepercayaan diri secara bertahap.

**Strategi Membangun Resiliensi:**

✓ **Jaga perspektif** - Hindari melihat krisis sebagai tak teratasi
✓ **Terima perubahan** - Fleksibilitas adalah kunci
✓ **Ambil tindakan** - Hadapi masalah, jangan hindari
✓ **Cari tanda-tanda positif** - Bahkan dalam situasi sulit
✓ **Jaga diri sendiri** - Resiliensi membutuhkan energi
✓ **Belajar dari masa lalu** - Bagaimana kamu melewati kesulitan sebelumnya?

Resiliensi bukan berarti tidak merasakan sakit. Ini berarti belajar bangkit meski sudah jatuh.''',
      category: 'Resiliensi',
      emoji: '💪',
      readMinutes: 5,
      isPremium: true,
    ),
    Article(
      id: '6',
      title: 'Pola Tidur Sehat untuk Kesehatan Mental',
      summary: 'Tidur dan kesehatan mental sangat erat kaitannya. Pelajari cara membangun kebiasaan tidur yang mendukung kesejahteraan mentalmu.',
      content: '''Tidur bukan sekadar istirahat — ini adalah proses biologis yang krusial untuk kesehatan otak dan mental. Penelitian menunjukkan hubungan dua arah antara gangguan tidur dan masalah kesehatan mental.

**Mengapa Tidur Sangat Penting:**
• Saat tidur, otak "membersihkan" toksin yang menumpuk
• Memori dikonsolidasi dan diperkuat
• Hormon stres diregulasi
• Sistem imun diperkuat
• Emosi diproses dan distabilkan

**Tanda-tanda kurang tidur:**
• Mudah marah dan emosional
• Sulit berkonsentrasi
• Pengambilan keputusan yang buruk
• Meningkatnya kecemasan
• Penurunan kreativitas

**Sleep Hygiene - Kebiasaan Tidur Sehat:**

⏰ **Konsistensi waktu tidur**
Tidur dan bangun di waktu yang sama setiap hari, termasuk akhir pekan.

📱 **Digital curfew**
Matikan layar minimal 1 jam sebelum tidur. Cahaya biru mengganggu produksi melatonin.

🌡️ **Lingkungan tidur ideal**
Suhu kamar sejuk (18-22°C), gelap, dan sunyi.

☕ **Batasi kafein**
Hindari kafein setelah pukul 14.00.

🏃 **Olahraga**
Berolahraga teratur meningkatkan kualitas tidur, tapi hindari olahraga berat 2-3 jam sebelum tidur.

🧘 **Wind-down routine**
Buat rutinitas relaksasi 30-60 menit sebelum tidur: membaca, mandi air hangat, atau stretching ringan.

Jika gangguan tidur berlanjut lebih dari beberapa minggu, konsultasikan dengan dokter.''',
      category: 'Tidur',
      emoji: '😴',
      readMinutes: 5,
      isPremium: true,
    ),
  ];

  static List<String> get categories {
    return articles.map((a) => a.category).toSet().toList();
  }

  static List<Article> getByCategory(String category) {
    return articles.where((a) => a.category == category).toList();
  }
}