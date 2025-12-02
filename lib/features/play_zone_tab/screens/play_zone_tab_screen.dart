import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/home/widgets/featured_quiz_card.dart';
import 'package:flutterquiz/ui/screens/home/widgets/staggered_quiz_card.dart';
import 'package:flutterquiz/ui/screens/quiz/category_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/category_screencourse.dart';
import 'package:flutterquiz/ui/widgets/all.dart';

final class PlayZoneTabScreen extends StatefulWidget {
  const PlayZoneTabScreen({super.key});

  @override
  State<PlayZoneTabScreen> createState() => PlayZoneTabScreenState();
}

final class PlayZoneTabScreenState extends State<PlayZoneTabScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final _scrollController = ScrollController();

  final _featuredZones = <Zone>[];
  final _regularZones = <Zone>[];
  final List<AnimationController> _featuredControllers = [];
  final List<Animation<double>> _featuredScaleAnimations = [];
  final List<Animation<double>> _featuredOpacityAnimations = [];
  final List<AnimationController> _regularControllers = [];
  final List<Animation<double>> _regularScaleAnimations = [];
  final List<Animation<double>> _regularOpacityAnimations = [];

  @override
  void initState() {
    super.initState();
    _initializePlayZones();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final controller in _featuredControllers) {
      controller.dispose();
    }
    for (final controller in _regularControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void onTapTab() {
    if (_scrollController.hasClients && _scrollController.offset != 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _initializePlayZones() {
    final config = context.read<SystemConfigCubit>();

    if (config.isFunNLearnEnabled) {
      _featuredZones.add((
        type: QuizTypes.funAndLearn,
        title: 'funAndLearn',
        img: Assets.funNLearnIcon,
        desc: 'desFunAndLearn',
      ));
    }

    if (config.isDailyQuizEnabled) {
      _featuredZones.add((
        type: QuizTypes.dailyQuiz,
        title: 'dailyQuiz',
        img: Assets.dailyQuizIcon,
        desc: 'desDailyQuiz',
      ));
    }

    if (config.isGuessTheWordEnabled) {
      _regularZones.add((
        type: QuizTypes.guessTheWord,
        title: 'guessTheWord',
        img: Assets.guessTheWordIcon,
        desc: 'desGuessTheWord',
      ));
    }

    if (config.isAudioQuizEnabled) {
      _regularZones.add((
        type: QuizTypes.audioQuestions,
        title: 'audioQuestions',
        img: Assets.audioQuizIcon,
        desc: 'desAudioQuestions',
      ));
    }

    if (config.isMathQuizEnabled) {
      _regularZones.add((
        type: QuizTypes.mathMania,
        title: 'mathMania',
        img: Assets.mathsQuizIcon,
        desc: 'desMathMania',
      ));
    }

    if (config.isTrueFalseQuizEnabled) {
      _regularZones.add((
        type: QuizTypes.trueAndFalse,
        title: 'truefalse',
        img: Assets.trueFalseQuizIcon,
        desc: 'desTrueFalse',
      ));
    }

    if (config.isMultiMatchQuizEnabled) {
      _regularZones.add((
        type: QuizTypes.multiMatch,
        title: 'multiMatch',
        img: Assets.multiMatchIcon,
        desc: 'desMultiMatch',
      ));
    }

    // Initialize animations
    _initializeAnimations();
  }

  void _initializeAnimations() {
    const animDuration = Duration(milliseconds: 350);
    const staggerDelay = 60;

    // Initialize featured zone animations
    for (var i = 0; i < _featuredZones.length; i++) {
      final controller = AnimationController(
        duration: animDuration,
        vsync: this,
      );
      final curve = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      );

      _featuredControllers.add(controller);
      _featuredScaleAnimations.add(Tween<double>(begin: .7, end: 1).animate(curve));
      _featuredOpacityAnimations.add(Tween<double>(begin: 0, end: 1).animate(curve));

      Future.delayed(
        Duration(milliseconds: staggerDelay * i),
        controller.forward,
      );
    }

    // Initialize regular zone animations
    for (var i = 0; i < _regularZones.length; i++) {
      final controller = AnimationController(
        duration: animDuration,
        vsync: this,
      );
      final curve = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      );

      _regularControllers.add(controller);
      _regularScaleAnimations.add(Tween<double>(begin: .7, end: 1).animate(curve));
      _regularOpacityAnimations.add(Tween<double>(begin: 0, end: 1).animate(curve));

      Future.delayed(
        Duration(milliseconds: staggerDelay * (_featuredZones.length + i)),
        controller.forward,
      );
    }
  }

  void _onTapQuiz(QuizTypes type) {
    // Check if the user is a guest, Show login required dialog for guest users
    if (context.read<AuthCubit>().isGuest) {
      showLoginRequiredDialog(context);
      return;
    }

    if (type == QuizTypes.mathMania) {
      globalCtx.pushNamed(Routes.treatGuide);
    } else if (type == QuizTypes.dailyQuiz) {
      globalCtx.pushNamed(
        Routes.categoryCourse,
        arguments: CategoryScreenCourseArgs(quizType: QuizTypes.funAndLearn),
      );
    } else if (type == QuizTypes.trueAndFalse) {
      Navigator.of(
        globalCtx,
      ).pushNamed(Routes.quiz, arguments: {'quizType': type});
    } else {
      globalCtx.pushNamed(
        Routes.category,
        arguments: CategoryScreenArgs(quizType: type),
      );
    }
  }

  List<Color> _getGradientColors(QuizTypes type) {
    switch (type) {
      case QuizTypes.funAndLearn:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
      case QuizTypes.dailyQuiz:
        return [const Color(0xFFEC4899), const Color(0xFFF59E0B)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: QAppBar(
        title: Text(context.tr('playZone')!),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_featuredZones.isNotEmpty) ...[
              Text(
                context.tr('featured') ?? 'Featured',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 16),
              ..._featuredZones.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final zone = entry.value;
                  return FadeTransition(
                    opacity: _featuredOpacityAnimations[index],
                    child: ScaleTransition(
                      scale: _featuredScaleAnimations[index],
                      child: FeaturedQuizCard(
                        onTap: () => _onTapQuiz(zone.type),
                        title: context.tr(zone.title)!,
                        desc: context.tr(zone.desc)!,
                        img: zone.img,
                        gradientColors: _getGradientColors(zone.type),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
            if (_regularZones.isNotEmpty) ...[
              Text(
                context.tr('allQuizModes') ?? 'All Quiz Modes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 16),
              _buildStaggeredGrid(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredGrid() {
    final heights = [180.0, 200.0, 170.0, 190.0, 185.0];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 20) / 2;

        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: List.generate(
            _regularZones.length,
            (index) {
              final zone = _regularZones[index];
              final height = heights[index % heights.length];
              return SizedBox(
                width: cardWidth,
                child: FadeTransition(
                  opacity: _regularOpacityAnimations[index],
                  child: ScaleTransition(
                    scale: _regularScaleAnimations[index],
                    child: StaggeredQuizCard(
                      onTap: () => _onTapQuiz(zone.type),
                      title: context.tr(zone.title)!,
                      desc: context.tr(zone.desc)!,
                      img: zone.img,
                      height: height,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
