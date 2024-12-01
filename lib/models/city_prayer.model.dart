class CityPrayer {
  final String cityName;
  final String countryName;
  final String nextPrayer;
  final String nextPrayerTime;
  final DateTime lastUpdated;

  CityPrayer({
    required this.cityName,
    required this.countryName,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.lastUpdated,
  });
}
