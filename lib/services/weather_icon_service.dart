import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart'; 

class WeatherIconService {
  static const String _apiKey =
      '0MuxlNmnRgj8xv9uZulmEAxGz6NY3Oxm'; 

  static String getWeatherIconUrl(String condition, {bool isDay = true}) {
    const String baseUrl = 'https://cdn.tomorrow.io/v1/icons/';
    String iconFileName = _mapConditionToIconName(condition, isDay: isDay);
    return '$baseUrl$iconFileName';
  }

  static Future<String> getIconUrlFromApi(int weatherCode,
      {bool isDay = true}) async {
    try {
      const String baseUrl = 'https://api.tomorrow.io/v4/weather/realtime';
      final response = await http.get(
        Uri.parse('$baseUrl?location=0,0&apikey=$_apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return getWeatherIconUrlFromCode(weatherCode, isDay: isDay);
      } else {
        return getWeatherIconUrlFromCode(weatherCode, isDay: isDay);
      }
    } catch (e) {
      return getWeatherIconUrlFromCode(weatherCode, isDay: isDay);
    }
  }

  static String getWeatherIconUrlFromCode(int weatherCode,
      {bool isDay = true}) {
    const String baseUrl = 'https://cdn.tomorrow.io/v1/icons/';
    String iconFileName = _mapWeatherCodeToIconName(weatherCode, isDay: isDay);
    return '$baseUrl$iconFileName';
  }

  static Widget weatherIconWidget(String condition,
      {required bool isDay, double width = 32, double height = 32}) {
    return Icon(
      getWeatherIconFromCondition(condition, isDay: isDay),
      color: Colors.white,
      size: width,
    );
  }

  static Widget weatherIconWidgetFromCode(int weatherCode,
      {required bool isDay, double width = 32, double height = 32}) {
    final iconUrl = getWeatherIconUrlFromCode(weatherCode, isDay: isDay);

    return Icon(
      getWeatherIconFromWeatherCode(weatherCode, isDay: isDay),
      color: Colors.white,
      size: width,
    );
  }

  static IconData getWeatherIconFromWeatherCode(int code, {bool isDay = true}) {
    
    switch (code) {
      case 1000: 
        return isDay ? Icons.wb_sunny : Icons.nightlight_round;
      case 1100: 
        return isDay ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined;
      case 1101: 
        return isDay ? Icons.wb_cloudy : Icons.nights_stay;
      case 1102: 
        return Icons.cloud_queue;
      case 1001: 
        return Icons.cloud;
      case 2000: 
      case 2100: 
        return Icons.foggy;
      case 4000: 
        return Icons.grain;
      case 4001: 
      case 4200: 
        return Icons.water_drop;
      case 4201: 
        return Icons.thunderstorm;
      case 5000: 
      case 5001: 
      case 5100: 
      case 5101: 
        return Icons.ac_unit;
      case 6000:     
      case 6001:  
      case 6200: 
      case 6201: 
        return Icons.ac_unit;
      case 7000: 
      case 7101: 
      case 7102: 
        return Icons.thunderstorm;
      case 8000: 
        return Icons.flash_on;
      default:
        return Icons.cloud;
    }
  }

  static String _weatherCodeToCondition(int code) {
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

  static String _mapConditionToIconName(String condition, {bool isDay = true}) {
    String timeOfDay = isDay ? 'day' : 'night';

    if (condition == 'Clear') return 'clear-$timeOfDay.svg';
    if (condition == 'Mostly Clear') return 'mostly-clear-$timeOfDay.svg';

    if (condition == 'Partly Cloudy') return 'partly-cloudy-$timeOfDay.svg';
    if (condition == 'Mostly Cloudy') return 'mostly-cloudy-$timeOfDay.svg';
    if (condition == 'Cloudy') return 'cloudy.svg';
    if (condition == 'Fog') return 'fog.svg';
    if (condition == 'Light Fog') return 'fog-light.svg';

    if (condition == 'Drizzle') return 'drizzle.svg';
    if (condition == 'Rain') return 'rain.svg';
    if (condition == 'Light Rain') return 'rain-light.svg';
    if (condition == 'Heavy Rain') return 'rain-heavy.svg';

    if (condition == 'Snow') return 'snow.svg';
    if (condition == 'Flurries') return 'flurries.svg';
    if (condition == 'Light Snow') return 'snow-light.svg';
    if (condition == 'Heavy Snow') return 'snow-heavy.svg';

    if (condition == 'Freezing Drizzle') return 'freezing-drizzle.svg';
    if (condition == 'Freezing Rain') return 'freezing-rain.svg';
    if (condition == 'Light Freezing Rain') return 'freezing-rain-light.svg';
    if (condition == 'Heavy Freezing Rain') return 'freezing-rain-heavy.svg';
    if (condition == 'Mixed Precipitation') return 'mixed.svg';
    if (condition == 'Heavy Mixed Precipitation') return 'mixed-heavy.svg';
    if (condition == 'Light Mixed Precipitation') return 'mixed-light.svg';
    if (condition == 'Thunderstorm') return 'thunderstorm.svg';

    return 'cloudy.svg';
  }

  static String _mapWeatherCodeToIconName(int code, {bool isDay = true}) {
    String timeOfDay = isDay ? 'day' : 'night';

    if (code == 1000) return 'clear-$timeOfDay.svg';
    if (code == 1100) return 'mostly-clear-$timeOfDay.svg';
    if (code == 1101) return 'partly-cloudy-$timeOfDay.svg';
    if (code == 1102) return 'mostly-cloudy-$timeOfDay.svg';
    if (code == 1001) return 'cloudy.svg';
    if (code == 2000) return 'fog.svg';
    if (code == 2100) return 'fog-light.svg';
    if (code == 4000) return 'drizzle.svg';
    if (code == 4001) return 'rain.svg';
    if (code == 4200) return 'rain-light.svg';
    if (code == 4201) return 'rain-heavy.svg';
    if (code == 5000) return 'snow.svg';
    if (code == 5001) return 'flurries.svg';
    if (code == 5100) return 'snow-light.svg';
    if (code == 5101) return 'snow-heavy.svg';
    if (code == 6000) return 'freezing-drizzle.svg';
    if (code == 6001) return 'freezing-rain.svg';
    if (code == 6200) return 'freezing-rain-light.svg';
    if (code == 6201) return 'freezing-rain-heavy.svg';
    if (code == 7000) return 'mixed.svg';
    if (code == 7101) return 'mixed-heavy.svg';
    if (code == 7102) return 'mixed-light.svg';
    if (code == 8000) return 'thunderstorm.svg';

    return 'cloudy.svg';
  }

  static bool isDaytime() {
    final hour = DateTime.now().hour;
    return hour >= 6 && hour < 18;
  }

  static IconData getWeatherIconFromCondition(String condition,
      {bool isDay = true}) {
    if (condition == 'Clear')
      return isDay ? Icons.wb_sunny : Icons.nightlight_round;
    if (condition == 'Mostly Clear')
      return isDay ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined;

    if (condition == 'Partly Cloudy')
      return isDay ? Icons.wb_cloudy : Icons.nights_stay;
    if (condition == 'Mostly Cloudy') return Icons.cloud_queue;
    if (condition == 'Cloudy') return Icons.cloud;
    if (condition == 'Fog') return Icons.foggy;
    if (condition == 'Light Fog') return Icons.cloud;

    // Rain conditions
    if (condition == 'Drizzle') return Icons.grain;
    if (condition == 'Rain') return Icons.beach_access;
    if (condition == 'Light Rain') return Icons.water_drop;
    if (condition == 'Heavy Rain') return Icons.thunderstorm;
    if (condition == 'Rainy')
      return Icons.beach_access; 

    if (condition == 'Snow') return Icons.ac_unit;
    if (condition == 'Flurries') return Icons.ac_unit;
    if (condition == 'Light Snow') return Icons.ac_unit;
    if (condition == 'Heavy Snow') return Icons.ac_unit;

    if (condition == 'Freezing Drizzle') return Icons.ac_unit;
    if (condition == 'Freezing Rain') return Icons.ac_unit;
    if (condition == 'Light Freezing Rain') return Icons.ac_unit;
    if (condition == 'Heavy Freezing Rain') return Icons.ac_unit;
    if (condition == 'Freezing')
      return Icons.ac_unit; 

    if (condition == 'Mixed Precipitation') return Icons.thunderstorm;
    if (condition == 'Heavy Mixed Precipitation') return Icons.thunderstorm;
    if (condition == 'Light Mixed Precipitation') return Icons.thunderstorm;

    if (condition == 'Thunderstorm') return Icons.flash_on;

    if (condition == 'Sunny') return Icons.wb_sunny;

    return Icons.cloud;
  }
}
