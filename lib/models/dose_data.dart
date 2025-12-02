
import 'package:hive/hive.dart';

part 'dose_data.g.dart';

@HiveType(typeId: 3)
class DoseData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String tradeName;

  @HiveField(2)
  final String activeSubstanceWithConc;

  @HiveField(3)
  final String activeSubstance;

  @HiveField(4)
  final String route;

  @HiveField(5)
  final String? form;

  @HiveField(6)
  final double concMg;

  @HiveField(7)
  final double volumeMl;

  @HiveField(8)
  final double? packageSize;

  @HiveField(9)
  final String? barcode;

  @HiveField(10)
  final String? note;

  DoseData({
    required this.id,
    required this.tradeName,
    required this.activeSubstanceWithConc,
    required this.activeSubstance,
    required this.route,
    this.form,
    required this.concMg,
    required this.volumeMl,
    this.packageSize,
    this.barcode,
    this.note,
  });

  factory DoseData.fromJson(Map<String, dynamic> json) {
    return DoseData(
      id: json['id']?.toString() ?? '',
      tradeName: json['tradeName'] ?? '',
      activeSubstanceWithConc: json['activeSubstanceWithConc'] ?? '',
      activeSubstance: json['activeSubstance'] ?? '',
      route: json['route'] ?? '',
      form: json['form'],
      concMg: (json['concMg'] as num?)?.toDouble() ?? 0.0,
      volumeMl: (json['volumeMl'] as num?)?.toDouble() ?? 1.0,
      packageSize: (json['packageSize'] as num?)?.toDouble(),
      barcode: json['barcode']?.toString(),
      note: json['note'],
    );
  }
}
