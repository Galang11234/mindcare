import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/dass21_data.dart';
import '../../models/models.dart';
import '../../utils/app_theme.dart';

class DassResultScreen extends StatelessWidget {
  final Dass21Result result;
  const DassResultScreen({super.key, required this.result});

  Color _levelColor(String level) {
    switch (level) {
      case 'Normal': return AppTheme.success;
      case 'Ringan': return AppTheme.warning;
      case 'Sedang': return AppTheme.orange;
      case 'Berat': return AppTheme.danger;
      default: return const Color(0xFFC0392B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rec = Dass21Data.getRecommendation(
        result.depressionLevel, result.anxietyLevel, result.stressLevel);
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF6C5CE7),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA855F7)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text('📊', style: TextStyle(fontSize: 52)),
                      const SizedBox(height: 8),
                      Text('Hasil Tes DASS-21',
                          style: GoogleFonts.nunito(
                              fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score Cards
                  Row(
                    children: [
                      _ScoreCard(
                        label: 'Depresi',
                        emoji: '😔',
                        score: result.depressionScore,
                        maxScore: 28,
                        level: result.depressionLevel,
                        color: _levelColor(result.depressionLevel),
                      ),
                      const SizedBox(width: 10),
                      _ScoreCard(
                        label: 'Kecemasan',
                        emoji: '😰',
                        score: result.anxietyScore,
                        maxScore: 28,
                        level: result.anxietyLevel,
                        color: _levelColor(result.anxietyLevel),
                      ),
                      const SizedBox(width: 10),
                      _ScoreCard(
                        label: 'Stres',
                        emoji: '😤',
                        score: result.stressScore,
                        maxScore: 28,
                        level: result.stressLevel,
                        color: _levelColor(result.stressLevel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Score bars
                  _ScoreBar(label: 'Depresi', score: result.depressionScore, level: result.depressionLevel, color: _levelColor(result.depressionLevel)),
                  const SizedBox(height: 12),
                  _ScoreBar(label: 'Kecemasan', score: result.anxietyScore, level: result.anxietyLevel, color: _levelColor(result.anxietyLevel)),
                  const SizedBox(height: 12),
                  _ScoreBar(label: 'Stres', score: result.stressScore, level: result.stressLevel, color: _levelColor(result.stressLevel)),
                  const SizedBox(height: 24),

                  // Recommendation
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Text('Rekomendasi',
                                style: GoogleFonts.nunito(
                                    fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(rec,
                            style: GoogleFonts.poppins(
                                fontSize: 14, color: AppTheme.textMedium, height: 1.6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // DASS Scale Reference
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Skala Referensi',
                            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        _RefRow('Normal', AppTheme.success),
                        _RefRow('Ringan', AppTheme.warning),
                        _RefRow('Sedang', AppTheme.orange),
                        _RefRow('Berat', AppTheme.danger),
                        _RefRow('Sangat Berat', const Color(0xFFC0392B)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Emergency contact
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.phone, color: AppTheme.danger, size: 18),
                          const SizedBox(width: 8),
                          Text('Butuh Bantuan Segera?',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppTheme.danger)),
                        ]),
                        const SizedBox(height: 8),
                        Text('Into The Light Indonesia: 119 ext 8',
                            style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textDark)),
                        Text('YKI Hotline: (021) 500-454',
                            style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textDark)),
                        Text('SEJIWA: 119 ext 8',
                            style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textDark)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                      icon: const Icon(Icons.home),
                      label: const Text('Kembali ke Beranda'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label, emoji, level;
  final int score, maxScore;
  final Color color;
  const _ScoreCard({required this.label, required this.emoji, required this.score, required this.maxScore, required this.level, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text('$score',
                style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
            Text(label,
                style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textMedium),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(level, style: GoogleFonts.poppins(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label, level;
  final int score;
  final Color color;
  const _ScoreBar({required this.label, required this.score, required this.level, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('$score / 28', style: GoogleFonts.poppins(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 28,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefRow extends StatelessWidget {
  final String level;
  final Color color;
  const _RefRow(this.level, this.color);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(level, style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textMedium)),
        ],
      ),
    );
  }
}