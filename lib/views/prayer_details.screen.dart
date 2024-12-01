import 'package:flutter/material.dart';
import 'package:prayer_time_tm/models/prayer_times.model.dart';
import 'dart:async';

class PrayerDetailsScreen extends StatefulWidget {
  final String cityName;
  final String countryName;
  final PrayerTimes prayerTimes;

  const PrayerDetailsScreen({
    super.key,
    required this.cityName,
    required this.countryName,
    required this.prayerTimes,
  });

  @override
  State<PrayerDetailsScreen> createState() => _PrayerDetailsScreenState();
}

class _PrayerDetailsScreenState extends State<PrayerDetailsScreen> {
  late Timer _timer;
  String _currentDateTime = '';

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentDateTime = '${now.day.toString().padLeft(2, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.year} '
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}';
    });
  }

  String _getNextPrayer() {
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final prayers = [
      {'name': 'Fajr', 'time': widget.prayerTimes.fajr},
      {'name': 'Dhuhr', 'time': widget.prayerTimes.dhuhr},
      {'name': 'Asr', 'time': widget.prayerTimes.asr},
      {'name': 'Maghrib', 'time': widget.prayerTimes.maghrib},
      {'name': 'Isha', 'time': widget.prayerTimes.isha},
    ];

    for (var prayer in prayers) {
      if (currentTime.compareTo(prayer['time']!) < 0) {
        return prayer['name']!;
      }
    }

    return 'Fajr'; // If all prayers have passed, next is tomorrow's Fajr
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // TODO: Implement delete functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildPrayerTimesList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.cityName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.countryName,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _currentDateTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPrayerTimeCard(
            context,
            'Fajr',
            widget.prayerTimes.fajr,
            Icons.wb_twilight,
            Colors.indigo,
          ),
          _buildPrayerTimeCard(
            context,
            'Dhuhr',
            widget.prayerTimes.dhuhr,
            Icons.wb_sunny,
            Colors.orange,
          ),
          _buildPrayerTimeCard(
            context,
            'Asr',
            widget.prayerTimes.asr,
            Icons.sunny,
            Colors.amber,
          ),
          _buildPrayerTimeCard(
            context,
            'Maghrib',
            widget.prayerTimes.maghrib,
            Icons.nights_stay,
            Colors.deepPurple,
          ),
          _buildPrayerTimeCard(
            context,
            'Isha',
            widget.prayerTimes.isha,
            Icons.dark_mode,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeCard(
    BuildContext context,
    String prayerName,
    String time,
    IconData icon,
    Color color,
  ) {
    final isNextPrayer = prayerName == _getNextPrayer();

    return Card(
      elevation: isNextPrayer ? 8 : 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side:
            isNextPrayer ? BorderSide(color: color, width: 2) : BorderSide.none,
      ),
      child: Container(
        decoration: isNextPrayer
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.1),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              )
            : null,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          leading: Stack(
            alignment: Alignment.center,
            children: [
              if (isNextPrayer)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isNextPrayer
                      ? color.withOpacity(0.1)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isNextPrayer ? 24 : 20,
                ),
              ),
            ],
          ),
          title: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayerName,
                    style: TextStyle(
                      fontSize: isNextPrayer ? 20 : 18,
                      fontWeight:
                          isNextPrayer ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isNextPrayer)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'NEXT PRAYER',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: isNextPrayer ? 24 : 20,
                  fontWeight: isNextPrayer ? FontWeight.bold : FontWeight.w600,
                  color: color,
                ),
              ),
              if (isNextPrayer)
                Text(
                  'Remaining: ${_getRemainingTime(time)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRemainingTime(String prayerTime) {
    final now = DateTime.now();
    final prayer = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(prayerTime.split(':')[0]),
      int.parse(prayerTime.split(':')[1]),
    );

    final difference = prayer.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '$hours h ${minutes.abs()} m';
    } else {
      return '${minutes.abs()} minutes';
    }
  }
}
