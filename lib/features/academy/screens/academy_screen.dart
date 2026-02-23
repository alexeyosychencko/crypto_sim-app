import 'package:flutter/material.dart';
import '../data/articles_data.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';

class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: academyArticles.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: Colors.white12,
      ),
      itemBuilder: (context, index) {
        final Article article = academyArticles[index];
        final String summary =
            article.summary.isEmpty ? 'Coming soon' : article.summary;
        final String readTime =
            article.readTimeMinutes == 0
                ? 'Quick read'
                : '${article.readTimeMinutes} min read';

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ArticleDetailScreen(article: article),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  readTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
