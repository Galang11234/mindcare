import 'package:flutter/material.dart';

class ArticleDetailScreen extends StatelessWidget {
  final dynamic article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(article.content ?? ''),
      ),
    );
  }
}