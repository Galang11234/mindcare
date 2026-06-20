import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../data/article_data.dart';
import '../../../models/models.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/app_theme.dart';
import 'article_detail_screen.dart';


class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});
  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final _searchCtrl = TextEditingController();

  List<Article> _filteredFor(UserProvider user) {
    var list = ArticleData.articles;

    // Free user only sees non-premium articles.
    if (!user.isPremium) {
      list = list.where((a) => !a.isPremium).toList();
    }

    if (_selectedCategory != 'Semua') {
      list = list.where((a) => a.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((a) => a.title.toLowerCase().contains(q) || a.summary.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }


  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final categories = ['Semua', ...ArticleData.categories];
    final filtered = _filteredFor(user);
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Artikel Edukasi', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Cari artikel...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                final active = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AppTheme.primary : Colors.grey.shade200),
                    ),
                    child: Text(cat,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : AppTheme.textMedium)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('🔍', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text('Artikel tidak ditemukan',
                          style: GoogleFonts.poppins(color: AppTheme.textMedium)),
                    ]),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final article = filtered[i];

                      return GestureDetector(
                        onTap: () {
                          if (!user.isPremium && article.isPremium) {
                            user.requirePremium(context, feature: 'Artikel premium eksklusif');
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ArticleDetailScreen(article: article)),
                          );
                        },
                        child: Container(

                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                child: Center(
                                  child: Text(article.emoji, style: const TextStyle(fontSize: 52)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(article.category,
                                          style: GoogleFonts.poppins(
                                              fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.timer_outlined, size: 13, color: AppTheme.textLight),
                                    const SizedBox(width: 3),
                                    Text('${article.readMinutes} menit',
                                        style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textLight)),
                                  ]),
                                  const SizedBox(height: 8),
                                  Text(article.title,
                                      style: GoogleFonts.poppins(
                                          fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                                  const SizedBox(height: 4),
                                  Text(article.summary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: AppTheme.textMedium, height: 1.5)),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}