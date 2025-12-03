import 'package:flutter/material.dart';

class QuizRadioGroupScope<T> extends InheritedWidget {
  const QuizRadioGroupScope({
    required this.groupValue,
    required this.onChanged,
    required super.child,
    super.key,
  });

  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  static QuizRadioGroupScope<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<QuizRadioGroupScope<T>>();
  }

  @override
  bool updateShouldNotify(QuizRadioGroupScope<T> oldWidget) {
    return groupValue != oldWidget.groupValue || onChanged != oldWidget.onChanged;
  }
}

class QuizRadioGroup<T> extends StatelessWidget {
  const QuizRadioGroup({
    required this.groupValue,
    required this.onChanged,
    required this.child,
    super.key,
  });

  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return QuizRadioGroupScope<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: child,
    );
  }
}
