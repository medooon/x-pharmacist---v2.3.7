
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:flutterquiz/models/trade_data.dart';
import 'package:flutterquiz/models/dose_data.dart';
import 'package:flutterquiz/models/age_weight.dart';

class DoseCalculatorService {
  static const String tradeUrl = 'https://egypt.moazpharmacy.com/trade.json';
  static const String doseUrl = 'https://egypt.moazpharmacy.com/dose.json';
  static const String ageWeightUrl = 'https://egypt.moazpharmacy.com/age_weight.json';

  // Fetch and store all dose calculator data
  Future<void> fetchAndStoreAllData() async {
    try {
      await Future.wait([
        _fetchAndStoreTradeData(),
        _fetchAndStoreDoseData(),
        _fetchAndStoreAgeWeightData(),
      ]);
    } catch (e) {
      print('Error fetching dose calculator data: $e');
      rethrow;
    }
  }

  Future<void> _fetchAndStoreTradeData() async {
    final response = await http.get(Uri.parse(tradeUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<TradeData> tradeDataList = jsonData
          .map((item) => TradeData.fromJson(item))
          .toList();

      final box = Hive.box<TradeData>('tradeDataBox');
      await box.clear();
      await box.addAll(tradeDataList);
    } else {
      throw Exception('Failed to load trade data');
    }
  }

  Future<void> _fetchAndStoreDoseData() async {
    final response = await http.get(Uri.parse(doseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<DoseData> doseDataList = jsonData
          .map((item) => DoseData.fromJson(item))
          .toList();

      final box = Hive.box<DoseData>('doseDataBox');
      await box.clear();
      await box.addAll(doseDataList);
    } else {
      throw Exception('Failed to load dose data');
    }
  }

  Future<void> _fetchAndStoreAgeWeightData() async {
    final response = await http.get(Uri.parse(ageWeightUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<AgeWeight> ageWeightList = jsonData
          .map((item) => AgeWeight.fromJson(item))
          .toList();

      final box = Hive.box<AgeWeight>('ageWeightBox');
      await box.clear();
      await box.addAll(ageWeightList);
    } else {
      throw Exception('Failed to load age weight data');
    }
  }

  // Check if local data exists
  bool hasLocalData() {
    final tradeBox = Hive.box<TradeData>('tradeDataBox');
    final doseBox = Hive.box<DoseData>('doseDataBox');
    final ageWeightBox = Hive.box<AgeWeight>('ageWeightBox');

    return tradeBox.isNotEmpty && doseBox.isNotEmpty && ageWeightBox.isNotEmpty;
  }

  // Get all dose data
  List<DoseData> getAllDoseData() {
    final box = Hive.box<DoseData>('doseDataBox');
    return box.values.toList();
  }

  // Get all trade data
  List<TradeData> getAllTradeData() {
    final box = Hive.box<TradeData>('tradeDataBox');
    return box.values.toList();
  }

  // Get all age weight data
  List<AgeWeight> getAllAgeWeightData() {
    final box = Hive.box<AgeWeight>('ageWeightBox');
    return box.values.toList();
  }

  // Find weight by age
  double? getWeightByAge(int years, int months) {
    final box = Hive.box<AgeWeight>('ageWeightBox');
    final ageWeightData = box.values.where((data) => 
        data.years == years && data.months == months).toList();
    
    if (ageWeightData.isNotEmpty) {
      return ageWeightData.first.weightKg;
    }
    return null;
  }

  // Check if patient fits param criteria
  bool patientFitsParam(String param, int years, int months, double weight) {
    if (param.isEmpty) return true;
    
    // Split by semicolon to handle multiple criteria
    final criteria = param.split(';');
    
    for (final criterion in criteria) {
      if (!_evaluateSingleCriterion(criterion, years, months, weight)) {
        return false; // All criteria must be met (AND logic)
      }
    }
    
    return true;
  }
  
  // Evaluate a single criterion
  bool _evaluateSingleCriterion(String criterion, int years, int months, double weight) {
    final trimmedCriterion = criterion.trim();
    
    // Handle special PMA (Post Menstrual Age) criteria
    if (trimmedCriterion.startsWith('\$p1:')) {
      // Skip PMA criteria for now as it requires additional clinical data
      return true;
    }
    
    // Handle age criteria
    if (trimmedCriterion.startsWith('age')) {
      return _evaluateAgeCriterion(trimmedCriterion, years, months);
    }
    
    // Handle weight criteria
    if (trimmedCriterion.startsWith('kg')) {
      return _evaluateWeightCriterion(trimmedCriterion, weight);
    }
    
    // Handle special terms
    if (trimmedCriterion.toLowerCase().contains('preterm') ||
        trimmedCriterion.toLowerCase().contains('loading') ||
        trimmedCriterion.toLowerCase().contains('maintenance')) {
      // These require clinical judgment, return true for now
      return true;
    }
    
    // If we can't parse the criterion, include it (conservative approach)
    return true;
  }
  
  // Evaluate age-based criteria
  bool _evaluateAgeCriterion(String criterion, int years, int months) {
    try {
      final ageRange = criterion.substring(3); // Remove 'age' prefix
      final parts = ageRange.split('-');
      
      if (parts.length == 2) {
        final minAge = double.tryParse(parts[0]) ?? 0;
        final maxAge = double.tryParse(parts[1]) ?? 999;
        final totalMonths = years * 12 + months;
        
        return totalMonths >= minAge && totalMonths <= maxAge;
      }
    } catch (e) {
      print('Error parsing age criterion: $criterion - $e');
    }
    
    return true; // Conservative approach
  }
  
  // Evaluate weight-based criteria
  bool _evaluateWeightCriterion(String criterion, double weight) {
    try {
      final weightRange = criterion.substring(2); // Remove 'kg' prefix
      final parts = weightRange.split('-');
      
      if (parts.length == 2) {
        final minWeight = double.tryParse(parts[0]) ?? 0;
        final maxWeight = double.tryParse(parts[1]) ?? 999;
        
        return weight >= minWeight && weight <= maxWeight;
      }
    } catch (e) {
      print('Error parsing weight criterion: $criterion - $e');
    }
    
    return true; // Conservative approach
  }

  // Calculate dose
  Map<String, dynamic> calculateDose({
    required TradeData tradeData,
    required DoseData doseData,
    required double weight,
  }) {
    // Check if solid dose is specified
    if (tradeData.solidDose != null && tradeData.solidDose!.isNotEmpty) {
      return {
        'indication': tradeData.indication,
        'result': tradeData.solidDose!,
        'note': tradeData.note,
        'ref': tradeData.ref,
      };
    }

    double dosePerAdministration = 0;
    String frequencyText = '';

    // Use the minimum division dose number for calculations
    final divisionNumber = tradeData.minDivisionDoseNumber;

    // Calculate dose based on dosePer
    switch (tradeData.dosePer.toLowerCase()) {
      case 'dose':
        dosePerAdministration = tradeData.doseFrom;
        frequencyText = '${tradeData.divisionDoseNumber} times daily';
        break;
      case 'kg/dose':
        dosePerAdministration = tradeData.doseFrom * weight;
        frequencyText = '${tradeData.divisionDoseNumber} times daily';
        break;
      case 'kg/day':
        final totalDailyDose = tradeData.doseFrom * weight;
        dosePerAdministration = totalDailyDose / divisionNumber;
        frequencyText = '${tradeData.divisionDoseNumber} times daily';
        break;
      case 'day':
        dosePerAdministration = tradeData.doseFrom / divisionNumber;
        frequencyText = '${tradeData.divisionDoseNumber} times daily';
        break;
    }

    // Convert mg to mL
    final mlPerDose = (dosePerAdministration * doseData.volumeMl) / doseData.concMg;

    // Calculate range if doseTo is different from doseFrom
    String dosageRange;
    if (tradeData.doseTo > 0 && tradeData.doseTo != tradeData.doseFrom) {
      double doseToPerAdministration = 0;
      switch (tradeData.dosePer.toLowerCase()) {
        case 'dose':
          doseToPerAdministration = tradeData.doseTo;
          break;
        case 'kg/dose':
          doseToPerAdministration = tradeData.doseTo * weight;
          break;
        case 'kg/day':
          final totalDailyDoseTo = tradeData.doseTo * weight;
          doseToPerAdministration = totalDailyDoseTo / divisionNumber;
          break;
        case 'day':
          doseToPerAdministration = tradeData.doseTo / divisionNumber;
          break;
      }
      final mlPerDoseTo = (doseToPerAdministration * doseData.volumeMl) / doseData.concMg;
      dosageRange = '${mlPerDose.toStringAsFixed(1)} – ${mlPerDoseTo.toStringAsFixed(1)} mL';
    } else {
      dosageRange = '${mlPerDose.toStringAsFixed(1)} mL';
    }

    // Calculate hours between doses using minimum division number
    final hoursInterval = (24 / divisionNumber).toStringAsFixed(0);

    String result = 'For (${tradeData.indication}): $dosageRange every $hoursInterval hours';
    
    // Add frequency options if there are multiple division options
    if (tradeData.hasMultipleDivisionOptions) {
      final options = tradeData.divisionDoseNumbers;
      result += ' (${options.join(' or ')} times daily)';
    }
    
    if (tradeData.duration != null && tradeData.duration!.isNotEmpty) {
      result += ' for ${tradeData.duration}';
    }
    result += '.';

    return {
      'indication': tradeData.indication,
      'result': result,
      'note': tradeData.note,
      'ref': tradeData.ref,
    };
  }
}
