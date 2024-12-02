import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayer_time_tm/models/prayer_times.model.dart';
import 'package:prayer_time_tm/models/save_city.model.dart';
import 'package:prayer_time_tm/views/add_new_city.screen.dart';
import 'package:prayer_time_tm/views/prayer_details.screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
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
              final nextPrayer = city.getNextPrayer().split(': ');

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    children: [
                      Text(
                        city.cityName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        city.countryName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getPrayerColor(nextPrayer[0]).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getPrayerColor(nextPrayer[0]),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            nextPrayer[0],
                            style: TextStyle(
                              color: _getPrayerColor(nextPrayer[0]),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          nextPrayer[1],
                          style: TextStyle(
                            color: _getPrayerColor(nextPrayer[0]),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
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
