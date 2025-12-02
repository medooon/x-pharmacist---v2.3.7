import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterquiz/models/ad_banner.dart';

class BannerService {
  static const String _remoteUrl = 'https://www.moazpharmacy.com/banners.json';
  static List<AdBanner>? _cachedBanners;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(hours: 1);

  Future<List<AdBanner>> loadBanners() async {
    if (_cachedBanners != null && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedBanners!;
    }

    try {
      final response = await http.get(Uri.parse(_remoteUrl))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> bannersJson = jsonData['banners'] as List<dynamic>;
        
        _cachedBanners = bannersJson
            .map((json) => AdBanner.fromJson(json as Map<String, dynamic>))
            .toList();
        _cacheTime = DateTime.now();
        
        return _cachedBanners!;
      } else {
        print('Error loading banners: HTTP ${response.statusCode}');
        return _cachedBanners ?? [];
      }
    } catch (e) {
      print('Error loading banners: $e');
      return _cachedBanners ?? [];
    }
  }

  List<AdBanner> getBannersByPosition(List<AdBanner> banners, String position) {
    return banners.where((banner) => banner.position == position).toList();
  }

  void clearCache() {
    _cachedBanners = null;
  }
}
