import 'package:flutter/material.dart';
import '../models/article.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          article.content.isEmpty
              ? const Center(
                child: Text(
                  'Coming soon',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  article.content,
                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),
              ),
    );
  }
}
