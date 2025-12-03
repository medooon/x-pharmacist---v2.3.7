import 'package:flutter/material.dart';

class RadioGroupScope<T> extends InheritedWidget {
  const RadioGroupScope({
    required this.groupValue,
    required this.onChanged,
    required super.child,
    super.key,
  });

  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  static RadioGroupScope<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RadioGroupScope<T>>();
  }

  @override
  bool updateShouldNotify(RadioGroupScope<T> oldWidget) {
    return groupValue != oldWidget.groupValue || onChanged != oldWidget.onChanged;
  }
}

class RadioGroup<T> extends StatelessWidget {
  const RadioGroup({
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
    return RadioGroupScope<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: child,
    );
  }
}
