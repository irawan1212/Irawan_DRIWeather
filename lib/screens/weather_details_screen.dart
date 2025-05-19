import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:irawan_driweather/models/weather_data.dart';
import 'package:irawan_driweather/services/weather_icon_service.dart';

class WeatherDetailsScreen extends StatelessWidget {
  final WeatherData weatherData;
  final String location;

  const WeatherDetailsScreen({
    Key? key,
    required this.weatherData,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final bool isDaytime = WeatherIconService.isDaytime();

   
    Set<String> usedDates = {};
    List<dynamic> nextDaysForecast = [];
    
    for (var forecast in weatherData.dailyForecast) {
      try {
        String dateStr = forecast.date;
        DateTime forecastDate;
        
       
        try {
          forecastDate = DateFormat('MMM d').parse(dateStr);
          forecastDate = DateTime(today.year, forecastDate.month, forecastDate.day);
        } catch (e) {
          continue; 
        }
       
        if (forecastDate.isAfter(todayOnly) && !usedDates.contains(dateStr)) {
          nextDaysForecast.add(forecast);
          usedDates.add(dateStr);
        }
      } catch (e) {
        print('Error processing forecast: $e');
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDaytime
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            weatherData.currentDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: weatherData.hourlyForecast.length,
                          itemBuilder: (context, index) {
                            final hourForecast = weatherData.hourlyForecast[index];

                            bool isHourDaytime = isDaytime;
                            if (hourForecast.time.contains('AM') ||
                                hourForecast.time.contains('PM')) {
                              try {
                                final hourStr =
                                    hourForecast.time.replaceAll(RegExp(r'[^\d:]'), '');
                                final timeParts = hourStr.split(':');
                                int hour = int.parse(timeParts[0]);

                                if (hourForecast.time.contains('PM') && hour != 12) {
                                  hour += 12;
                                } else if (hourForecast.time.contains('AM') &&
                                    hour == 12) {
                                  hour = 0;
                                }

                                isHourDaytime = hour >= 6 && hour < 18;
                              } catch (e) {
                                print('Time parse error: $e');
                              }
                            }

                            return Container(
                              width: 60,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${hourForecast.temperature.toStringAsFixed(0)}°',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  WeatherIconService.weatherIconWidget(
                                    hourForecast.condition,
                                    isDay: isHourDaytime,
                                    width: 28,
                                    height: 28,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    hourForecast.time,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),
                      
                      const Text(
                        'Next Forecast',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      nextDaysForecast.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                itemCount: nextDaysForecast.length,
                                itemBuilder: (context, index) {
                                  final daily = nextDaysForecast[index];
                                  final date = daily.date;
                                  final temp = daily.temperature;
                                  final condition = daily.condition;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12.0),
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            date,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        WeatherIconService.weatherIconWidget(
                                          condition,
                                          isDay: true, 
                                          width: 28,
                                          height: 28,
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          '${temp.toStringAsFixed(0)}°',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : Expanded(
                              child: Center(
                                child: Text(
                                  'No forecast data available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),

                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Dri Weather',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}