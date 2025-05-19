import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:irawan_driweather/services/weather_service.dart';
import 'package:irawan_driweather/services/weather_icon_service.dart';
import 'package:irawan_driweather/models/weather_data.dart';
import 'package:irawan_driweather/screens/weather_details_screen.dart';
import 'package:irawan_driweather/widgets/notification_popup_stateful.dart';
import 'package:irawan_driweather/screens/search_location_screen.dart';
import 'package:irawan_driweather/services/location_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  WeatherData? _weatherData;
  String _location = "Semarang";
  bool _isLoading = true;
  Position? _currentPosition;
  bool _isDaytime = true; // Track if it's daytime for proper icon display
  int _weatherCode = 1001; // Default to cloudy

  // Add tracking for API request limits
  int _apiRequestCount = 0;
  final int _maxApiRequests = 50; // Set your actual API limit here
  bool _hasReachedLimit = false;

  // Add tracking for location border limits
  bool _isOutOfServiceArea = false;
  final List<String> _supportedCountries = [
    'Indonesia',
    'Malaysia',
    'Singapore'
  ]; // Example

  @override
  void initState() {
    super.initState();
    _checkDaytime();
    _getCurrentLocation();
  }

  
  void _checkDaytime() {
    setState(() {
      _isDaytime = WeatherIconService.isDaytime();
    });
  }

   Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLimitNotification('Location services are disabled');
        _fetchWeatherData(_location);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLimitNotification('Location permission denied');
          _fetchWeatherData(_location);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLimitNotification('Location permissions permanently denied');
        _fetchWeatherData(_location);
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();

      // Check if location is within service area menggunakan LocationService
      bool isInServiceArea = await _locationService.checkIfInServiceArea(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          _supportedCountries);

      if (!isInServiceArea) {
        _isOutOfServiceArea = true;
        _showLimitNotification('You are outside our service area');
      }

      _fetchWeatherByCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);
    } catch (e) {
      _showLimitNotification('Could not determine your location');
      _fetchWeatherData(_location);
    }
  }
  // Check if coordinates are within supported service area
  Future<bool> _checkIfInServiceArea(double latitude, double longitude) async {
    try {
      // This is a placeholder. In a real app, you would:
      // 1. Either use a geocoding service to get the country from coordinates
      // 2. Or check if coordinates are within defined boundaries

      // Example of how you might check using a geocoding service:
      // final placemarks = await placemarkFromCoordinates(latitude, longitude);
      // final country = placemarks.first.country;
      // return _supportedCountries.contains(country);

      // For demonstration, we'll return true. Replace with actual implementation.
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _fetchWeatherByCoordinates(
      double latitude, double longitude) async {
    // Check API limits before making request
    if (_hasReachedApiLimit()) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final weatherData =
          await _weatherService.getWeatherByCoordinates(latitude, longitude);

      // Increment API counter
      _incrementApiCounter();

      // Get the weather code
      int weatherCode = _getWeatherCodeFromCondition(weatherData.condition);

      setState(() {
        _weatherData = weatherData;
        _location = weatherData.locationName;
        _weatherCode = weatherCode;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to fetch weather data');
    }
  }

  Future<void> _fetchWeatherData(String location) async {
    // Check API limits before making request
    if (_hasReachedApiLimit()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final weatherData = await _weatherService.getWeatherByCity(location);

      // Increment API counter
      _incrementApiCounter();

      // Get the weather code
      int weatherCode = _getWeatherCodeFromCondition(weatherData.condition);

      setState(() {
        _weatherData = weatherData;
        _weatherCode = weatherCode;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to fetch weather data');
    }
  }

  // Check if API request limit has been reached
  bool _hasReachedApiLimit() {
    if (_apiRequestCount >= _maxApiRequests) {
      if (!_hasReachedLimit) {
        // Only show notification once
        _hasReachedLimit = true;
        _showLimitNotification('API request limit reached for today');
      }
      return true;
    }
    return false;
  }

  // Increment API request counter
  void _incrementApiCounter() {
    setState(() {
      _apiRequestCount++;

      // If we're approaching the limit (80%), warn the user
      if (_apiRequestCount >= (_maxApiRequests * 0.8).round() &&
          !_hasReachedLimit) {
        _showLimitNotification(
            'Approaching API request limit (${_apiRequestCount}/$_maxApiRequests)');
      }
    });
  }

  // Show a notification about reaching a limit
  void _showLimitNotification(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });
  }

  // Helper method to derive weather code from condition
  int _getWeatherCodeFromCondition(String condition) {
    // Map conditions back to codes
    if (condition == 'Clear') return 1000;
    if (condition == 'Mostly Clear') return 1100;
    if (condition == 'Partly Cloudy') return 1101;
    if (condition == 'Mostly Cloudy') return 1102;
    if (condition == 'Cloudy') return 1001;
    if (condition == 'Fog') return 2000;
    if (condition == 'Light Fog') return 2100;
    if (condition == 'Drizzle') return 4000;
    if (condition == 'Rain' || condition == 'Rainy') return 4001;
    if (condition == 'Light Rain') return 4200;
    if (condition == 'Heavy Rain') return 4201;
    if (condition == 'Snow') return 5000;
    if (condition == 'Flurries') return 5001;
    if (condition == 'Light Snow') return 5100;
    if (condition == 'Heavy Snow') return 5101;
    if (condition == 'Freezing Drizzle') return 6000;
    if (condition == 'Freezing Rain') return 6001;
    if (condition == 'Light Freezing Rain') return 6200;
    if (condition == 'Heavy Freezing Rain') return 6201;
    if (condition == 'Mixed Precipitation') return 7000;
    if (condition == 'Heavy Mixed Precipitation') return 7101;
    if (condition == 'Light Mixed Precipitation') return 7102;
    if (condition == 'Thunderstorm') return 8000;
    if (condition == 'Sunny') return 1000;

    // Default is cloudy
    return 1001;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('d MMMM');
    return 'Today, ${formatter.format(now)}';
  }

  // Helper method to get weather icon widget
  Widget _getWeatherIconWidget(String condition) {
    // Use the weather code for more accurate icon display
    return WeatherIconService.weatherIconWidgetFromCode(
      _weatherCode,
      isDay: _isDaytime,
      width: 100,
      height: 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isDaytime
                ? [
                    const Color(0xFF52ACFF),
                    const Color(0xFF1976D2),
                  ]
                : [
                    const Color(0xFF172B4D),
                    const Color(0xFF0A1929),
                  ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location and notification row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Location button
                            InkWell(
                              onTap: () async {
                                final selectedLocation =
                                    await Navigator.push<String>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchLocationScreen(
                                    ),
                                  ),
                                );
                                if (selectedLocation != null) {
                                  setState(() {
                                    _location = selectedLocation;
                                  });
                                  _fetchWeatherData(selectedLocation);
                                }
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    _location,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down,
                                      color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                            // API Count & Notification row
                            Row(
                              children: [
                                // API Limit indicator
                                _hasReachedLimit ||
                                        _apiRequestCount >
                                            (_maxApiRequests * 0.8).round()
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _hasReachedLimit
                                              ? Colors.red
                                              : Colors.orange,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${_apiRequestCount}/$_maxApiRequests',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(width: 8),
                                // Notification icon
                                IconButton(
                                  icon: const Icon(Icons.notifications_outlined,
                                      color: Colors.white),
                                  onPressed: () {
                                    NotificationManager.showNotificationPopup(
                                        context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Show warning banner if outside service area
                      if (_isOutOfServiceArea)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Outside service area - using approximate data',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Spacer(flex: 2),

                      // Current weather display
                      Center(
                        child: _getWeatherIconWidget(
                            _weatherData?.condition ?? ""),
                      ),

                      const SizedBox(height: 16),

                      // Weather Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            // Date
                            Text(
                              _getFormattedDate(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Temperature
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_weatherData?.temperature.toStringAsFixed(0) ?? "0"}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 72,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const Text(
                                  '°',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 72,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),

                            // Weather condition
                            Text(
                              _weatherData?.condition ?? 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Wind and humidity row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Wind
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.air,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Wind',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_weatherData?.windSpeed ?? "0"} km/h',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),

                                // Humidity
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.water_drop_outlined,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Hum',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_weatherData?.humidity ?? "0"}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Weather Details Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_weatherData != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WeatherDetailsScreen(
                                      weatherData: _weatherData!,
                                      location: _location,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _isDaytime
                                  ? Colors.blue[600]
                                  : Colors.indigo[800],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Weather Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
