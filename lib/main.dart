import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayer_time_tm/app.dart';
import 'package:prayer_time_tm/models/save_city.model.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SavedCityAdapter());
  await Hive.openBox<SavedCity>('saved_cities');

  runApp(const App());
}
