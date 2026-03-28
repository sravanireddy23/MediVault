// lib/services/news_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/news_config.dart';

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String source;
  final String publishedAt;
  final String? urlToImage;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    required this.publishedAt,
    this.urlToImage,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title:       json['title']               ?? '',
      description: json['description']         ?? '',
      url:         json['url']                 ?? '',
      source:      json['source']?['name']     ?? 'Health News',
      publishedAt: _formatDate(json['publishedAt'] ?? ''),
      urlToImage:  json['urlToImage'],
    );
  }

  static String _formatDate(String rawDate) {
    try {
      final dt  = DateTime.parse(rawDate).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final now  = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours   < 24) return '${diff.inHours}h ago';
      if (diff.inDays    <  7) return '${diff.inDays}d ago';
      return '${months[dt.month - 1]} ${dt.day}';
    } catch (_) {
      return '';
    }
  }
}

class NewsService {
  // ── Rotating query pool ────────────────────────────────────────────────────
  // Each fetch picks a random query so the feed always feels fresh and varied.
  static const List<String> _queryPool = [
    // Wellness & lifestyle
    'health tips nutrition wellness hydration daily habits',
    'healthy diet weight loss fitness exercise benefits',
    'sleep health mental wellness stress management',
    'water intake hydration benefits body health',

    // Medical condition explainers
    'PCOD PCOS symptoms treatment women health',
    'diabetes type 2 insulin metformin treatment explained',
    'thyroid hypothyroidism hyperthyroidism symptoms causes',
    'hypertension blood pressure causes prevention diet',
    'anemia iron deficiency symptoms treatment diet',
    'cholesterol heart disease prevention lifestyle',

    // Research & discoveries
    'medical research breakthrough treatment discovery 2025',
    'new study health benefits turmeric curcumin anti-inflammatory',
    'cancer research new treatment immunotherapy 2025',
    'gut health microbiome probiotics benefits research',
    'vitamin D deficiency health effects sunlight benefits',
    'omega 3 fatty acids heart brain health benefits study',
  ];

  static Future<List<NewsArticle>> fetchHealthNews({
    int pageSize = 10,
    int page     = 1,
  }) async {
    try {
      // Pick a random query from the pool for variety
      final query = _queryPool[Random().nextInt(_queryPool.length)];

      final uri = Uri.parse(
        '${NewsConfig.baseUrl}/everything'
            '?q=${Uri.encodeComponent(query)}'
            '&language=en'
            '&sortBy=relevancy'
            '&pageSize=$pageSize'
            '&page=$page'
            '&apiKey=${NewsConfig.apiKey}',
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data     = jsonDecode(response.body) as Map<String, dynamic>;
        final articles = data['articles'] as List<dynamic>;

        return articles
            .map((a) => NewsArticle.fromJson(a as Map<String, dynamic>))
            .where((a) =>
        a.title.isNotEmpty       &&
            a.title       != '[Removed]' &&
            a.description.isNotEmpty &&
            a.description != '[Removed]' &&
            a.url.isNotEmpty)
            .toList();
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }
}