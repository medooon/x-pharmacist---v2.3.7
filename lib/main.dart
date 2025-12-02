// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutterquiz/models/drug.dart';
import 'package:flutterquiz/models/data_version.dart';
import 'package:flutterquiz/models/trade_data.dart';
import 'package:flutterquiz/models/dose_data.dart';
import 'package:flutterquiz/models/age_weight.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
// Register Hive adapters (check if not already registered)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DrugAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DataVersionAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TradeDataAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(DoseDataAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AgeWeightAdapter());
    }

  // Open Hive boxes
  await Hive.openBox<Drug>('drugsBox');
  await Hive.openBox<DataVersion>('dataVersionBox');
  await Hive.openBox<TradeData>('tradeDataBox');
  await Hive.openBox<DoseData>('doseDataBox');
  await Hive.openBox<AgeWeight>('ageWeightBox');

  // Initialize and run the app
  runApp(await initializeApp());
}
