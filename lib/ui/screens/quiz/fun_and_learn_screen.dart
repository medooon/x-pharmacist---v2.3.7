import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/quiz/models/comprehension.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:screen_protector/screen_protector.dart';

final class FunAndLearnScreenArgs extends RouteArgs {
  const FunAndLearnScreenArgs({
    required this.categoryId,
    required this.comprehension,
    required this.isPremiumCategory,
    this.subcategoryId,
  });

  final String categoryId;
  final String? subcategoryId;
  final Comprehension comprehension;
  final bool isPremiumCategory;
}

class FunAndLearnScreen extends StatefulWidget {
  const FunAndLearnScreen({required this.args, super.key});

  final FunAndLearnScreenArgs args;

  @override
  State<FunAndLearnScreen> createState() => _FunAndLearnScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.args<FunAndLearnScreenArgs>();

    return CupertinoPageRoute(builder: (_) => FunAndLearnScreen(args: args));
  }
}

class _FunAndLearnScreen extends State<FunAndLearnScreen> {
  late final Comprehension _comprehension = widget.args.comprehension;

  late final _ytController = YoutubePlayerController(
    initialVideoId: _comprehension.contentData,
    flags: const YoutubePlayerFlags(autoPlay: false),
  );

  @override
  void initState() {
    super.initState();
    _enableScreenProtection();
  }
  Future<void> _enableScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (e) {
      debugPrint("Error enabling screen protection: $e");
    }
  }
  Future<void> _disableScreenProtection() async {
    try {
      await ScreenProtector.preventScreenshotOff();
    } catch (e) {
      debugPrint("Error disabling screen protection: $e");
    }
  }
  void dispose() {
    super.dispose();
    _ytController.dispose();
    _disableScreenProtection();
    super.dispose();
  }

  

  bool showFullPdf = false;
  bool ytFullScreen = false;

  Widget _buildParagraph(Widget player) {



    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      // أزلنا أي ارتفاع ثابت حتى يشبه الإصدار القديم
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10), // حواف ثابتة 16 بكسل من جميع الجهات
        child: Column(
          children: [
            // محتوى الفيديو
             if (_comprehension.contentType == ContentType.yt &&

                    _comprehension.contentData.isNotEmpty)

                  player,


            // محتوى الـ PDF



            if (_comprehension.contentType == ContentType.pdf &&

                    _comprehension.contentData.isNotEmpty) ...[

              // أزلنا الـ height عن الـ SizedBox حتى يتمدد بحسب المحتوى
              // أو يمكنك استبداله بـ Container دون تحديد ارتفاع
              Container(

                constraints: BoxConstraints(

                  // حد أقصى للارتفاع لمنع تمدد PDF بلا حدود 



                  maxHeight: MediaQuery.of(context).size.height * (showFullPdf ? 0.7 : 0.2),



                ),

                child: const PDF(

                  swipeHorizontal: true,

                  fitPolicy: FitPolicy.BOTH,

                ).fromUrl(_comprehension.contentData),

              ),

              TextButton(

                onPressed: () => setState(() => showFullPdf = !showFullPdf),

                child: Text(

                  showFullPdf ? 'Show Less' : 'Show Full',

                  style: Theme.of(context).textTheme.labelLarge?.copyWith(

                    color: Theme.of(context).colorScheme.onTertiary,

                    decoration: TextDecoration.underline,

                  ),

                ),

              ),

            ],

            const SizedBox(height: 10),

            HtmlWidget(

              _comprehension.detail,

              onErrorBuilder: (_, e, err) => Text('$e error: $err'),

              onLoadingBuilder: (_, __, ___) => const Center(



                child: CircularProgressIndicator(),



              ),

              textStyle: TextStyle(

                color: context.primaryTextColor,

                fontWeight: FontWeights.regular,

                fontSize: 18,

              ),

            ),

            const SizedBox(height: 10),

          ],

        ),

      ),

    );

  }



  @override

  Widget build(BuildContext context) {

    return YoutubePlayerBuilder(

      player: YoutubePlayer(

        controller: _ytController,

        progressIndicatorColor: context.primaryColor,

        progressColors: ProgressBarColors(

          playedColor: context.primaryColor,

          bufferedColor: context.primaryTextColor.withValues(alpha: .5),

          backgroundColor: context.surfaceColor.withValues(alpha: .5),

          handleColor: context.primaryColor,

        ),

      ),

      onExitFullScreen: () {

        SystemChrome.setEnabledSystemUIMode(

          SystemUiMode.manual,

          overlays: SystemUiOverlay.values,

        );

      },

      builder: (context, player) {

        return Scaffold(

          appBar: QAppBar(

            roundedAppBar: false,

            title: Text(_comprehension.title),

          ),

          body: Center(



            child: _buildParagraph(player),

          ),

        );

      },

    );

  }

}
