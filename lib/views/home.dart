import 'package:flutter/material.dart';
import 'package:prayer_time_tm/models/city_prayer.model.dart';
import 'package:prayer_time_tm/models/prayer_times.model.dart';
import 'package:prayer_time_tm/views/add_new_city.screen.dart';
import 'package:prayer_time_tm/views/prayer_details.screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  final List<CityPrayer> _cities = [
    CityPrayer(
      cityName: 'Jakarta',
      countryName: 'Indonesia',
      nextPrayer: 'Maghrib',
      nextPrayerTime: '18:15',
      lastUpdated: DateTime.now(),
    ),
    CityPrayer(
      cityName: 'Makkah',
      countryName: 'Saudi Arabia',
      nextPrayer: 'Isha',
      nextPrayerTime: '19:45',
      lastUpdated: DateTime.now(),
    ),
    CityPrayer(
      cityName: 'Istanbul',
      countryName: 'Turkey',
      nextPrayer: 'Fajr',
      nextPrayerTime: '05:30',
      lastUpdated: DateTime.now(),
    ),
    CityPrayer(
      cityName: 'Dubai',
      countryName: 'UAE',
      nextPrayer: 'Asr',
      nextPrayerTime: '15:45',
      lastUpdated: DateTime.now(),
    ),
  ];

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
      body: _cities.isEmpty
          ? const Center(
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
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _cities.length,
              itemBuilder: (context, index) {
                final city = _cities[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
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
                              color: _getPrayerColor(city.nextPrayer)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getPrayerColor(city.nextPrayer),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              city.nextPrayer,
                              style: TextStyle(
                                color: _getPrayerColor(city.nextPrayer),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            city.nextPrayerTime,
                            style: TextStyle(
                              color: _getPrayerColor(city.nextPrayer),
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
                              fajr: '05:30',
                              dhuhr: '12:30',
                              asr: '15:45',
                              maghrib: '18:15',
                              isha: '19:45',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddNewCityScreen(),
            ),
          );
        },
        tooltip: 'Add new city',
        child: const Icon(Icons.add),
      ),
    );
  }
}
