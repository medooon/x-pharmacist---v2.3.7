
import 'package:hive/hive.dart';

part 'age_weight.g.dart';

@HiveType(typeId: 4)
class AgeWeight extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int years;

  @HiveField(2)
  final int months;

  @HiveField(3)
  final double weightKg;

  AgeWeight({
    required this.id,
    required this.years,
    required this.months,
    required this.weightKg,
  });

  factory AgeWeight.fromJson(Map<String, dynamic> json) {
    return AgeWeight(
      id: json['id']?.toString() ?? '',
      years: (json['years'] as num?)?.toInt() ?? 0,
      months: (json['months'] as num?)?.toInt() ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
