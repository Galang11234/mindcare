import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/models.dart';
import '../../../utils/app_theme.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  List<Widget> _parseContent(String content) {
    final widgets = <Widget>[];
    for (final line in content.split('\n')) {
      if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Text(
            line.replaceAll('**', ''),
            style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textDark),
          ),
        ));
      } else if (line.startsWith('• ') || line.startsWith('✓ ') || line.startsWith('⏰ ') ||
          line.startsWith('📱') || line.startsWith('🌡️') || line.startsWith('☕') ||
          line.startsWith('🏃') || line.startsWith('🧘')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 8),
              Text('•', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.primary, fontWeight: FontWeight.w700)),
              const SizedBox(width: 10),
              Expanded(child: Text(line.replaceFirst(RegExp(r'^[•✓⏰📱🌡️☕🏃🧘]\s'), ''),
                  style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMedium, height: 1.6))),
            ],
          ),
        ));
      } else if (line.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(line, style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textMedium, height: 1.7)),
        ));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(article.emoji, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(article.category,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
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
                  Row(children: [
                    const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textLight),
                    const SizedBox(width: 4),
                    Text('${article.readMinutes} menit baca',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textLight)),
                  ]),
                  const SizedBox(height: 10),
                  Text(article.title,
                      style: GoogleFonts.nunito(
                          fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textDark, height: 1.3)),
                  const SizedBox(height: 8),
                  Text(article.summary,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: AppTheme.primary, fontWeight: FontWeight.w500, height: 1.5)),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _parseContent(article.content)),
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