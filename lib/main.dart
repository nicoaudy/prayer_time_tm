import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayer_time_tm/models/save_city.model.dart';
import 'package:prayer_time_tm/views/home.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SavedCityAdapter());

  await Hive.openBox<SavedCity>('saved_cities');
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
      ),
      home: const Home(),
    );
  }
}
