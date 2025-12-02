import 'package:hive/hive.dart';

part 'trade_data.g.dart';

@HiveType(typeId: 2)
class TradeData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String indication;

  @HiveField(2)
  final String activeSubstance;

  @HiveField(3)
  final String route;

  @HiveField(4)
  final String param;

  @HiveField(5)
  final double doseFrom;

  @HiveField(6)
  final double doseTo;

  @HiveField(7)
  final String dosePer;

  @HiveField(8)
  final String? maxDose;

  @HiveField(9)
  final String? duration;

  @HiveField(10)
  final String divisionDoseNumber;

  @HiveField(11)
  final String? note;

  @HiveField(12)
  final String? ref;

  @HiveField(13)
  final String? use;

  @HiveField(14)
  final String? category;

  @HiveField(15)
  final String? precaution;

  @HiveField(16)
  final String? contraindications;

  @HiveField(17)
  final dynamic g6pd;

  @HiveField(18)
  final String? solidDose;

  TradeData({
    required this.id,
    required this.indication,
    required this.activeSubstance,
    required this.route,
    required this.param,
    required this.doseFrom,
    required this.doseTo,
    required this.dosePer,
    this.maxDose,
    this.duration,
    required this.divisionDoseNumber,
    this.note,
    this.ref,
    this.use,
    this.category,
    this.precaution,
    this.contraindications,
    this.g6pd,
    this.solidDose,
  });

  factory TradeData.fromJson(Map<String, dynamic> json) {
    return TradeData(
      id: json['id']?.toString() ?? '',
      indication: json['indication'] ?? '',
      activeSubstance: json['activeSubstance'] ?? '',
      route: json['route'] ?? '',
      param: json['param'] ?? '',
      doseFrom: (json['doseFrom'] as num?)?.toDouble() ?? 0.0,
      doseTo: (json['doseTo'] as num?)?.toDouble() ?? 0.0,
      dosePer: json['dosePer'] ?? '',
      maxDose: json['maxDose']?.toString(),
      duration: json['duration']?.toString(),
      divisionDoseNumber: json['divisionDoseNumber']?.toString() ?? '1',
      note: json['note']?.toString(),
      ref: json['ref']?.toString(),
      use: json['use']?.toString(),
      category: json['category']?.toString(),
      precaution: json['precaution']?.toString(),
      contraindications: json['contraindications']?.toString(),
      g6pd: json['g6pd'],
      solidDose: json['Soliddose']?.toString(),
    );
  }

  // Helper methods for division dose number handling
  List<int> get divisionDoseNumbers {
    return divisionDoseNumber
        .split(';')
        .map((e) => int.tryParse(e.trim()) ?? 1)
        .toList();
  }

  int get minDivisionDoseNumber {
    final numbers = divisionDoseNumbers;
    return numbers.isNotEmpty ? numbers.first : 1;
  }

  int get maxDivisionDoseNumber {
    final numbers = divisionDoseNumbers;
    return numbers.isNotEmpty ? numbers.last : 1;
  }

  bool get hasMultipleDivisionOptions {
    return divisionDoseNumber.contains(';');
  }
}