import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:irawan_driweather/models/weather_data.dart';
import 'package:irawan_driweather/services/weather_icon_service.dart';
import 'location_service.dart';

class WeatherService {
  final String _apiKey = '0MuxlNmnRgj8xv9uZulmEAxGz6NY3Oxm';
  final String _baseUrl = 'https://api.tomorrow.io/v4/weather';
  final LocationService _locationService = LocationService();

  Future<WeatherData> getWeatherByCity(String city) async {
    try {
      final coordinates =
          await _locationService.getCoordinatesFromAddress(city);
      if (coordinates == null) {
        throw Exception('Could not find coordinates for $city');
      }

      return getWeatherByCoordinates(
          coordinates.latitude, coordinates.longitude);
    } catch (e) {
      throw Exception('Failed to get weather for $city: $e');
    }
  }

  Future<WeatherData> getWeatherByCoordinates(
      double latitude, double longitude) async {
    try {
      final url =
          '$_baseUrl/realtime?location=$latitude,$longitude&units=metric&apikey=$_apiKey';
      final forecastUrl =
          '$_baseUrl/forecast?location=$latitude,$longitude&units=metric&apikey=$_apiKey';

      final response = await http.get(Uri.parse(url));
      final forecastResponse = await http.get(Uri.parse(forecastUrl));

      if (response.statusCode == 200 && forecastResponse.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> forecastData =
            json.decode(forecastResponse.body);

        final locationName = await _locationService.getAddressFromCoordinates(
                latitude, longitude) ??
            'Unknown Location';

        final currentValues = data['data']['values'];
        final weatherCode = currentValues['weatherCode'] ?? 0;
        final temperature = currentValues['temperature'] ?? 0.0;
        final condition = _mapWeatherCode(weatherCode);
        final windSpeed = currentValues['windSpeed'] ?? 0.0;
        final humidity = currentValues['humidity'] ?? 0;
       final weatherIconUrl =
            WeatherIconService.getWeatherIconUrlFromCode(weatherCode);

        final now = DateTime.now();
        final currentDate = DateFormat('d MMMM').format(now);

        final List<dynamic> timelines =
            forecastData['timelines']['hourly'] ?? [];
        final List<HourlyForecast> hourlyForecast = [];

        for (int i = 0; i < timelines.length && i < 5; i++) {
          final hourData = timelines[i];
          final DateTime forecastTime = DateTime.parse(hourData['time']);
          final String formattedTime = DateFormat('h a')
              .format(forecastTime); // Format as "2 PM" instead of "14:00"
          final hourTemp = hourData['values']['temperature'] ?? 0.0;
          final hourWeatherCode = hourData['values']['weatherCode'] ?? 0;
          final hourCondition = _mapWeatherCode(hourWeatherCode);

          final hourIconUrl =
              WeatherIconService.getWeatherIconUrlFromCode(hourWeatherCode);

          hourlyForecast.add(HourlyForecast(
            time: formattedTime,
            temperature: hourTemp.toDouble(),
            condition: hourCondition,
            weatherCode: hourWeatherCode,
            weatherIconUrl: hourIconUrl,
          ));
        }

        final List<dynamic> dailyTimelines =
            forecastData['timelines']['daily'] ?? [];
        final List<DailyForecast> dailyForecast = [];

        for (int i = 0; i < dailyTimelines.length && i < 5; i++) {
          final dayData = dailyTimelines[i];
          final date =
              DateFormat('MMM d').format(DateTime.parse(dayData['time']));
          final dayTemp = dayData['values']['temperatureMax'] ?? 0.0;
          final dayWeatherCode = dayData['values']['weatherCodeMax'] ?? 0;
          final dayCondition = _mapWeatherCode(dayWeatherCode);

          final dayIconUrl =
              WeatherIconService.getWeatherIconUrlFromCode(dayWeatherCode);

          dailyForecast.add(DailyForecast(
            date: date,
            temperature: dayTemp.toDouble(),
            condition: dayCondition,
            weatherCode: dayWeatherCode,
            weatherIconUrl: dayIconUrl,
          ));
        }

        return WeatherData(
          locationName: locationName,
          temperature: temperature.toDouble(),
          condition: condition,
          weatherCode: weatherCode,
          windSpeed: windSpeed.toDouble(),
          humidity: humidity,
          currentDate: currentDate,
          hourlyForecast: hourlyForecast,
          dailyForecast: dailyForecast,
          weatherIconUrl: weatherIconUrl,
        );
      } else {
        throw Exception(
            'Failed to load weather data. Status code: ${response.statusCode}, ${forecastResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  String _mapWeatherCode(int code) {
    if (code == 1000) return 'Clear';
    if (code == 1100) return 'Mostly Clear';
    if (code == 1101) return 'Partly Cloudy';
    if (code == 1102) return 'Mostly Cloudy';
    if (code == 1001) return 'Cloudy';
    if (code == 2000) return 'Fog';
    if (code == 2100) return 'Light Fog';
    if (code == 4000) return 'Drizzle';
    if (code == 4001) return 'Rain';
    if (code == 4200) return 'Light Rain';
    if (code == 4201) return 'Heavy Rain';
    if (code == 5000) return 'Snow';
    if (code == 5001) return 'Flurries';
    if (code == 5100) return 'Light Snow';
    if (code == 5101) return 'Heavy Snow';
    if (code == 6000) return 'Freezing Drizzle';
    if (code == 6001) return 'Freezing Rain';
    if (code == 6200) return 'Light Freezing Rain';
    if (code == 6201) return 'Heavy Freezing Rain';
    if (code == 7000) return 'Mixed Precipitation';
    if (code == 7101) return 'Heavy Mixed Precipitation';
    if (code == 7102) return 'Light Mixed Precipitation';
    if (code == 8000) return 'Thunderstorm';
    return 'Cloudy';
  }
}
