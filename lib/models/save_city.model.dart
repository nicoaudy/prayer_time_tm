import 'package:hive/hive.dart';

part 'saved_city.model.g.dart';

@HiveType(typeId: 1)
class SavedCity {
  @HiveField(0)
  final String cityName;

  @HiveField(1)
  final String countryName;

  @HiveField(2)
  final Map<String, String> prayerTimes;

  @HiveField(3)
  final DateTime lastUpdated;

  SavedCity({
    required this.cityName,
    required this.countryName,
    required this.prayerTimes,
    required this.lastUpdated,
  });
}
