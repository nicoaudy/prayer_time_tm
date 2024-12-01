import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prayer_time_tm/models/country_city.model.dart';
import 'package:prayer_time_tm/models/prayer_times.model.dart';
import 'package:hive/hive.dart';
import 'package:prayer_time_tm/models/save_city.model.dart';

class AddNewCityScreen extends StatefulWidget {
  const AddNewCityScreen({super.key});

  @override
  AddNewCityScreenState createState() => AddNewCityScreenState();
}

class AddNewCityScreenState extends State<AddNewCityScreen> {
  PrayerTimes? _prayerTimes;
  bool _isLoading = false;
  bool _showPrayerTimes = false;
  final Dio _dio = Dio();

  List<CountryCity> _countryData = [];
  List<String> _countries = [];
  List<String> _cities = [];
  String? _selectedCountry;
  String? _selectedCity;

  Future<void> _fetchCountries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await rootBundle.loadString("assets/country.json");
      final jsonData = json.decode(response);

      _countryData = (jsonData['data'] as List)
          .map((item) => CountryCity.fromJson(item))
          .toList();

      _countries = _countryData.map((item) => item.country).toList();

      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to fetch countries. Please try again!'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCities(String country) async {
    try {
      final countryData = _countryData.firstWhere(
        (element) => element.country == country,
        orElse: () => CountryCity(country: '', cities: []),
      );

      setState(() {
        _cities = countryData.cities;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to fetch cities. Please try again!'),
      ));
    }
  }

  Future<void> _fetchPrayerTimes() async {
    if (_selectedCountry == null || _selectedCity == null) return;

    setState(() {
      _isLoading = true;
      _showPrayerTimes = false;
    });

    final city = _selectedCity;
    final country = _selectedCountry ?? 'Any';
    final url =
        'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=2';

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _prayerTimes = PrayerTimes.fromJson(data['data']['timings']);
          _showPrayerTimes = true;
        });
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to fetch prayer times. Please try again!'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveCity() async {
    if (_prayerTimes == null ||
        _selectedCity == null ||
        _selectedCountry == null) {
      return;
    }

    try {
      final box = Hive.box<SavedCity>('saved_cities');

      final savedCity = SavedCity(
        cityName: _selectedCity!,
        countryName: _selectedCountry!,
        prayerTimes: {
          'Fajr': _prayerTimes!.fajr,
          'Dhuhr': _prayerTimes!.dhuhr,
          'Asr': _prayerTimes!.asr,
          'Maghrib': _prayerTimes!.maghrib,
          'Isha': _prayerTimes!.isha,
        },
        lastUpdated: DateTime.now(),
      );

      await box.put('${_selectedCity}_${_selectedCountry}', savedCity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_selectedCity saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save city. Please try again!')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New City'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Location',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownSearch<String>(
                              popupProps: const PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    hintText: "Search country...",
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                              ),
                              items: (_, __) => _countries,
                              decoratorProps: const DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  labelText: "Select Country",
                                  prefixIcon: Icon(Icons.flag),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedCountry = newValue;
                                  _cities.clear();
                                  _selectedCity = null;
                                });
                                if (newValue != null) {
                                  _fetchCities(newValue);
                                }
                              },
                              selectedItem: _selectedCountry,
                            ),
                            const SizedBox(height: 16),
                            DropdownSearch<String>(
                              popupProps: const PopupProps.menu(
                                showSearchBox: true,
                                searchFieldProps: TextFieldProps(
                                  decoration: InputDecoration(
                                    hintText: "Search city...",
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                              ),
                              items: (_, __) => _cities,
                              decoratorProps: const DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  labelText: "Select City",
                                  prefixIcon: Icon(Icons.location_city),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              onChanged: (newValue) {
                                setState(() => _selectedCity = newValue);
                              },
                              selectedItem: _selectedCity,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: (_selectedCountry != null &&
                                        _selectedCity != null)
                                    ? _fetchPrayerTimes
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.schedule),
                                label: const Text(
                                  'Fetch Prayer Times',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showPrayerTimes && _prayerTimes != null) ...[
                      const SizedBox(height: 24),
                      Card(
                        elevation: 4,
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                              child: Text(
                                _selectedCity ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildPrayerTimeRow('Fajr',
                                      _prayerTimes!.fajr, Icons.wb_twilight),
                                  _buildPrayerTimeRow('Dhuhr',
                                      _prayerTimes!.dhuhr, Icons.wb_sunny),
                                  _buildPrayerTimeRow(
                                      'Asr', _prayerTimes!.asr, Icons.sunny),
                                  _buildPrayerTimeRow('Maghrib',
                                      _prayerTimes!.maghrib, Icons.nights_stay),
                                  _buildPrayerTimeRow('Isha',
                                      _prayerTimes!.isha, Icons.dark_mode),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _saveCity,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.save),
                                  label: const Text(
                                    'Save City',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPrayerTimeRow(String prayer, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Text(
            prayer,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
