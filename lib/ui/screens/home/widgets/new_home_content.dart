import 'package:flutter/material.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/core/constants/fonts.dart';
import 'package:flutterquiz/models/ad_banner.dart';
import 'package:flutterquiz/models/pharmacy_news.dart';
import 'package:flutterquiz/services/banner_service.dart';
import 'package:flutterquiz/services/pharmacy_news_service.dart';
import 'package:flutterquiz/ui/screens/home/widgets/home_action_card.dart';
import 'package:flutterquiz/ui/screens/home/widgets/simple_action_card.dart';
import 'package:flutterquiz/ui/widgets/banner_carousel.dart';
import 'package:flutterquiz/ui/widgets/banner_widget.dart';
import 'package:flutterquiz/ui/widgets/pharmacy_news_card.dart';
import 'package:flutterquiz/commons/screens/dashboard_screen.dart';

class NewHomeContent extends StatefulWidget {
  const NewHomeContent({super.key});

  @override
  State<NewHomeContent> createState() => _NewHomeContentState();
}

class _NewHomeContentState extends State<NewHomeContent> {
  final BannerService _bannerService = BannerService();
  final PharmacyNewsService _newsService = PharmacyNewsService();

  List<AdBanner> _allBanners = [];
  List<PharmacyNews> _allNews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final banners = await _bannerService.loadBanners();
      final news = await _newsService.loadNews();

      setState(() {
        _allBanners = banners;
        _allNews = news;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading home content: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToKsaDrugIndex() {
    globalCtx.pushNamed(Routes.saudiIndex);
  }

  void _navigateToDoseCalculator() {
    globalCtx.pushNamed(Routes.doseCalculator);
  }

  void _navigateToOTCHelper() {
    globalCtx.pushNamed(Routes.treatGuide);
  }

  void _navigateToCourses() {
    final dashboard = context.findAncestorStateOfType<DashboardScreenState>();
    dashboard?.changeTab(NavTabType.playZone);
  }

  void _navigateToQuiz() {
    final dashboard = context.findAncestorStateOfType<DashboardScreenState>();
    dashboard?.changeTab(NavTabType.quizZone);
  }

  void _onNewsTap(PharmacyNews news) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(news.emoji),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                news.title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(news.content.isNotEmpty ? news.content : news.preview),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topBanners = _bannerService.getBannersByPosition(_allBanners, 'top');
    final bottomBanners = _bannerService.getBannersByPosition(_allBanners, 'bottom');
    final recentNews = _newsService.getRecentNews(_allNews, limit: 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        
        if (!_isLoading && topBanners.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BannerWidget(banner: topBanners.first),
          ),
          const SizedBox(height: 20),
        ],
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: _navigateToKsaDrugIndex,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF6BB6),
                    Color(0xFF9D5CFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 5),
                    blurRadius: 5,
                    color: Colors.black12,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ksa Drug Index',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeights.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Browse comprehensive drug database',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeights.regular,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: HomeActionCard(
                  title: 'Dose\nCalculator',
                  description: 'Calculate precise medication dosages',
                  icon: Assets.mathsQuizIcon,
                  gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  onTap: _navigateToDoseCalculator,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HomeActionCard(
                  title: 'OTC\nHelper',
                  description: 'Treatment guidelines and protocols',
                  icon: Assets.examQuizIcon,
                  gradientColors: const [Color(0xFFEC4899), Color(0xFFF59E0B)],
                  onTap: _navigateToOTCHelper,
                ),
              ),
            ],
          ),
        ),

        if (!_isLoading && recentNews.isNotEmpty) ...[
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📰 Pharmacy News & Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeights.bold,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: recentNews.length,
              itemBuilder: (context, index) {
                return PharmacyNewsCard(
                  news: recentNews[index],
                  onTap: () => _onNewsTap(recentNews[index]),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 28),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: SimpleActionCard(
                  title: 'Courses',
                  description: 'Fun & Learn pharmacy courses',
                  icon: Assets.funNLearnIcon,
                  onTap: _navigateToCourses,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SimpleActionCard(
                  title: 'Quiz',
                  description: 'Test your knowledge',
                  icon: Assets.dailyQuizIcon,
                  onTap: _navigateToQuiz,
                ),
              ),
            ],
          ),
        ),

        if (!_isLoading && bottomBanners.isNotEmpty) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BannerCarousel(
              banners: bottomBanners,
              height: 200,
            ),
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}
