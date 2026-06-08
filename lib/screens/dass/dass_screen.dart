import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/dass21_data.dart';
import '../../models/models.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';
import 'dass_result_screen.dart';

class DassScreen extends StatefulWidget {
  const DassScreen({super.key});
  @override
  State<DassScreen> createState() => _DassScreenState();
}

class _DassScreenState extends State<DassScreen> {
  int _currentIndex = 0;
  final List<int?> _answers = List.filled(21, null);
  bool _started = false;

  void _selectAnswer(int val) {
    setState(() => _answers[_currentIndex] = val);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentIndex < 20) {
        setState(() => _currentIndex++);
      } else {
        _submit();
      }
    });
  }

  void _submit() {
    if (_answers.any((a) => a == null)) return;
    final scores = Dass21Data.calculateScores(_answers.cast<int>());
    final result = Dass21Result(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      depressionScore: scores['depression']!,
      anxietyScore: scores['anxiety']!,
      stressScore: scores['stress']!,
      answers: _answers.cast<int>(),
    );
    StorageService.saveDassResult(result);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DassResultScreen(result: result)),
    );
  }

  double get _progress => (_currentIndex + 1) / 21;

  @override
  Widget build(BuildContext context) {
    if (!_started) return _buildIntro();
    return _buildQuestion();
  }

  Widget _buildIntro() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                const Text('🧠', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 24),
                Text('Tes Kesehatan\nMental DASS-21',
                    style: GoogleFonts.nunito(
                        fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
                const SizedBox(height: 16),
                Text(
                  'Tes ini mengukur tingkat Depresi, Kecemasan, dan Stres kamu dalam 1 minggu terakhir.',
                  style: GoogleFonts.poppins(fontSize: 15, color: Colors.white.withOpacity(0.85), height: 1.6),
                ),
                const SizedBox(height: 24),
                _InfoRow(icon: Icons.quiz_outlined, text: '21 pertanyaan singkat'),
                const SizedBox(height: 10),
                _InfoRow(icon: Icons.timer_outlined, text: '± 5-7 menit'),
                _InfoRow(
                    icon: Icons.lock_outline,
                    text: 'Hasilnya tersimpan privat di perangkatmu'),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tes ini bukan pengganti diagnosis profesional. Konsultasikan hasilnya dengan psikolog jika diperlukan.',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.85)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _started = true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, foregroundColor: const Color(0xFF6C5CE7)),
                    child: const Text('Mulai Tes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final q = Dass21Data.questions[_currentIndex];
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => _showExitDialog(),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Pertanyaan ${_currentIndex + 1} dari 21',
                              style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progress,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Dalam 1 minggu terakhir:',
                      style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMedium),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      q['text'] as String,
                      style: GoogleFonts.nunito(
                          fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textDark, height: 1.4),
                    ),
                    const SizedBox(height: 40),
                    ...List.generate(4, (i) {
                      final isSelected = _answers[_currentIndex] == i;
                      return GestureDetector(
                        onTap: () => _selectAnswer(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6C5CE7) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? Colors.white.withOpacity(0.25) : Colors.grey.shade100,
                                ),
                                child: Center(
                                  child: Text('$i',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? Colors.white : AppTheme.textMedium)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  Dass21Data.answerOptions[i],
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.white : AppTheme.textDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Navigation
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _currentIndex--),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF6C5CE7)),
                          foregroundColor: const Color(0xFF6C5CE7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  if (_currentIndex > 0) const SizedBox(width: 12),
                  if (_currentIndex == 20 && _answers[20] != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Lihat Hasil'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Tes?'),
        content: const Text('Progress kamu akan hilang jika keluar sekarang.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Lanjutkan Tes')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: const Text('Keluar', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.85), size: 18),
          const SizedBox(width: 12),
          Text(text, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 14)),
        ],
      ),
    );
  }
}