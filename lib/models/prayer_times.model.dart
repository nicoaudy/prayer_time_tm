class PrayerTimes {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String timezone;

  PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.timezone,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      fajr: json["timings"]['Fajr'],
      dhuhr: json["timings"]['Dhuhr'],
      asr: json["timings"]['Asr'],
      maghrib: json["timings"]['Maghrib'],
      isha: json["timings"]['Isha'],
      timezone: json['meta']?['timezone'] ?? 'UTC',
    );
  }
}
