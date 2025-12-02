import 'package:flutter/material.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/models/ad_banner.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerWidget extends StatelessWidget {
  final AdBanner banner;

  const BannerWidget({
    required this.banner,
    super.key,
  });

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(banner.clickUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchUrl,
      child: Container(
        height: banner.minHeight.toDouble(),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: QImage(
            imageUrl: banner.imageUrl,
            width: double.infinity,
            height: banner.minHeight.toDouble(),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
