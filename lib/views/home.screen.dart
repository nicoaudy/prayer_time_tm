import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayer_time_tm/models/prayer_times.model.dart';
import 'package:prayer_time_tm/models/save_city.model.dart';
import 'package:prayer_time_tm/views/add_new_city.screen.dart';
import 'package:prayer_time_tm/views/prayer_details.screen.dart';
import 'package:worldtime/worldtime.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  final Map<String, DateTime> _cityTimes = {};
  late Timer _timer;
  final _worldtimePlugin = Worldtime();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimeUpdates();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimeUpdates() async {
    await _updateAllCityTimes();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateAllCityTimes();
    });
  }

  Future<void> _updateAllCityTimes() async {
    final box = Hive.box<SavedCity>('saved_cities');
    final cities = box.values.toList();

    if (cities.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      for (var city in cities) {
        if (!_cityTimes.containsKey(city.timezone)) {
          final cityTime = await _worldtimePlugin.timeByCity(city.timezone);
          _cityTimes[city.timezone] = cityTime;
        } else {
          _cityTimes[city.timezone] = _cityTimes[city.timezone]!.add(
            const Duration(seconds: 1),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating times: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  Color _getPrayerColor(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':
        return Colors.indigo;
      case 'dhuhr':
        return Colors.orange;
      case 'asr':
        return Colors.amber;
      case 'maghrib':
        return Colors.deepPurple;
      case 'isha':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "Prayer Companion",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<SavedCity>('saved_cities').listenable(),
        builder: (context, Box<SavedCity> box, _) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (box.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_city, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No cities added yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a city',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final cities = box.values.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              final cityTime = _cityTimes[city.timezone];
              final nextPrayer = city.getNextPrayer(cityTime).split(': ');

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getPrayerColor(nextPrayer[0]).withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                city.cityName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _formatDateTime(cityTime),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            city.countryName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getPrayerColor(nextPrayer[0]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: Colors.white,
                                  size: 16,
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
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Text(
                              nextPrayer[0],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getPrayerColor(nextPrayer[0]),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              nextPrayer[1],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _getPrayerColor(nextPrayer[0]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: _getPrayerColor(nextPrayer[0]),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrayerDetailsScreen(
                              cityName: city.cityName,
                              countryName: city.countryName,
                              prayerTimes: PrayerTimes(
                                fajr: city.prayerTimes['Fajr']!,
                                dhuhr: city.prayerTimes['Dhuhr']!,
                                asr: city.prayerTimes['Asr']!,
                                maghrib: city.prayerTimes['Maghrib']!,
                                isha: city.prayerTimes['Isha']!,
                                timezone: city.timezone,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewCityScreen()),
          );
        },
        tooltip: 'Add new city',
        child: const Icon(Icons.add),
      ),
    );
  }
}
