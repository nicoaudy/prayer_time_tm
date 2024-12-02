import 'package:hive/hive.dart';

part 'save_city.model.g.dart';

@HiveType(typeId: 0)
class SavedCity extends HiveObject {
  @HiveField(0)
  final String cityName;

  @HiveField(1)
  final String countryName;

  @HiveField(2)
  final Map<String, dynamic> prayerTimes;

  @HiveField(3)
  final DateTime lastUpdated;

  @HiveField(4)
  final String timezone;

  SavedCity({
    required this.cityName,
    required this.countryName,
    required this.prayerTimes,
    required this.lastUpdated,
    required this.timezone,
  });

  String getNextPrayer() {
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final prayers = [
      {'name': 'Fajr', 'time': prayerTimes['Fajr']},
      {'name': 'Dhuhr', 'time': prayerTimes['Dhuhr']},
      {'name': 'Asr', 'time': prayerTimes['Asr']},
      {'name': 'Maghrib', 'time': prayerTimes['Maghrib']},
      {'name': 'Isha', 'time': prayerTimes['Isha']},
    ];

    for (var prayer in prayers) {
      if (currentTime.compareTo(prayer['time']!) < 0) {
        return '${prayer['name']}: ${prayer['time']}';
      }
    }

    return 'Fajr: ${prayerTimes['Fajr']}';
  }
}
