import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterquiz/models/pharmacy_news.dart';

class PharmacyNewsService {
  static const String _remoteUrl = 'https://www.moazpharmacy.com/pharmacy_news.json';
  static List<PharmacyNews>? _cachedNews;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 30);

  Future<List<PharmacyNews>> loadNews() async {
    if (_cachedNews != null && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedNews!;
    }

    try {
      final response = await http.get(Uri.parse(_remoteUrl))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> newsJson = jsonData['news'] as List<dynamic>;
        
        _cachedNews = newsJson
            .map((json) => PharmacyNews.fromJson(json as Map<String, dynamic>))
            .toList();
        
        _cachedNews!.sort((a, b) => b.publishDate.compareTo(a.publishDate));
        _cacheTime = DateTime.now();
        
        return _cachedNews!;
      } else {
        print('Error loading pharmacy news: HTTP ${response.statusCode}');
        return _cachedNews ?? [];
      }
    } catch (e) {
      print('Error loading pharmacy news: $e');
      return _cachedNews ?? [];
    }
  }

  List<PharmacyNews> getRecentNews(List<PharmacyNews> allNews, {int limit = 10}) {
    return allNews.take(limit).toList();
  }

  void clearCache() {
    _cachedNews = null;
  }
}
