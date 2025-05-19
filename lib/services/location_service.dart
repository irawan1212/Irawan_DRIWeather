import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  static const String _openCageApiKey = '65efe1b32652482ca4dd247635a37168';
  static const String _openCageBaseUrl =
      'https://api.opencagedata.com/geocode/v1/json';

  Future<Position> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      final openCageAddress =
          await _getAddressFromOpenCage(latitude, longitude);
      if (openCageAddress != null) {
        return openCageAddress;
      }

      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality ?? place.subLocality ?? place.name ?? ''}, ${place.country ?? ''}';
      }
      return null;
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return null;
    }
  }

  Future<String?> _getAddressFromOpenCage(
      double latitude, double longitude) async {
    final url = Uri.parse(
        '$_openCageBaseUrl?q=$latitude+$longitude&key=$_openCageApiKey&language=en&pretty=1');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final components = result['components'];

          String city = components['city'] ??
              components['town'] ??
              components['village'] ??
              components['municipality'] ??
              components['suburb'] ??
              '';
          String country = components['country'] ?? '';

          return city.isNotEmpty && country.isNotEmpty
              ? '$city, $country'
              : result['formatted'] ?? null;
        }
      }
      return null;
    } catch (e) {
      print('Error with OpenCage API: $e');
      return null;
    }
  }

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final openCageCoords = await _getCoordinatesFromOpenCage(address);
      if (openCageCoords != null) {
        return openCageCoords;
      }

      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations[0].latitude, locations[0].longitude);
      }
      return null;
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return null;
    }
  }

  Future<LatLng?> _getCoordinatesFromOpenCage(String address) async {
    final url = Uri.parse(
        '$_openCageBaseUrl?q=${Uri.encodeComponent(address)}&key=$_openCageApiKey&language=en&pretty=1');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final geometry = data['results'][0]['geometry'];
          return LatLng(geometry['lat'], geometry['lng']);
        }
      }
      return null;
    } catch (e) {
      print('Error with OpenCage API: $e');
      return null;
    }
  }

  Future<List<String>> searchLocation(String query) async {
    if (query.isEmpty) return [];

    try {
      final openCageResults = await _searchWithOpenCage(query);
      if (openCageResults.isNotEmpty) {
        return openCageResults;
      }

      List<Location> locations = await locationFromAddress(query);
      return await Future.wait(locations.take(10).map((location) async {
        return await getAddressFromCoordinates(
                location.latitude, location.longitude) ??
            '';
      }));
    } catch (e) {
      print('Error searching location: $e');
      return [];
    }
  }

  Future<List<String>> _searchWithOpenCage(String query) async {
    final url = Uri.parse(
        '$_openCageBaseUrl?q=${Uri.encodeComponent(query)}&key=$_openCageApiKey&language=en&pretty=1&limit=10');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results']
                ?.map<String>((result) => result['formatted'] ?? '')
                ?.toList() ??
            [];
      }
      return [];
    } catch (e) {
      print('Error with OpenCage search: $e');
      return [];
    }
  }

  Future<bool> checkIfInServiceArea(double latitude, double longitude,
      List<String> supportedCountries) async {
    try {
      final address = await getAddressFromCoordinates(latitude, longitude);
      if (address == null) return false;

      final country = address.split(', ').last;
      return supportedCountries.any((supportedCountry) =>
          country.toLowerCase().contains(supportedCountry.toLowerCase()));
    } catch (e) {
      print('Error checking service area: $e');
      return false;
    }
  }
}
