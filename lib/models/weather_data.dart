class WeatherData {
  final String locationName;
  final double temperature;
  final String condition;
  final int weatherCode;
  final double windSpeed;
  final int humidity;
  final String currentDate;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final String weatherIconUrl; // URL ikon dari Tomorrow.io

  WeatherData({
    required this.locationName,
    required this.temperature,
    required this.condition,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.currentDate,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.weatherIconUrl,
  });
}

class HourlyForecast {
  final String time;
  final double temperature;
  final String condition;
  final int weatherCode;
  final String weatherIconUrl; // URL ikon dari Tomorrow.io

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.weatherCode,
    required this.weatherIconUrl,
  });
}

class DailyForecast {
  final String date;
  final double temperature;
  final String condition;
  final int weatherCode;
  final String weatherIconUrl; // URL ikon dari Tomorrow.io

  DailyForecast({
    required this.date,
    required this.temperature,
    required this.condition,
    required this.weatherCode,
    required this.weatherIconUrl,
  });
}
