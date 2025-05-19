import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:irawan_driweather/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SearchLocationScreen extends StatefulWidget {
  final Position? currentPosition;

  const SearchLocationScreen({
    Key? key,
    this.currentPosition,
  }) : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  final List<String> _recentSearches = [];
  List<String> _searchResults = [];
  bool _isSearching = false;
  LatLng? _selectedLocation;
  String? _selectedLocationName;
  final MapController _mapController = MapController();

  static const String RECENT_SEARCHES_KEY = 'recent_searches';

  @override
  void initState() {
    super.initState();
    _initMap();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearchesJson = prefs.getString(RECENT_SEARCHES_KEY);
    if (recentSearchesJson != null) {
      setState(() {
        _recentSearches
            .addAll(List<String>.from(jsonDecode(recentSearchesJson)));
      });
    }
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
  await prefs.setString(RECENT_SEARCHES_KEY, jsonEncode(_recentSearches));
  }

  void _initMap() {
    if (widget.currentPosition != null) {
      _selectedLocation = LatLng(
        widget.currentPosition!.latitude,
        widget.currentPosition!.longitude,
      );
      _locationService
          .getAddressFromCoordinates(
        widget.currentPosition!.latitude,
        widget.currentPosition!.longitude,
      )
          .then((address) {
        if (address != null) {
          setState(() {
            _selectedLocationName = address;
          });
        }
      });
    } else {
      _selectedLocation = LatLng(-6.2088, 106.8456); 
    }
  }

  void _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _locationService.searchLocation(query);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      _showError('Failed to search location');
    }
  }

  void _selectLocation(String location, {LatLng? coordinates}) async {
    try {
      if (coordinates == null) {
        final locationCoords =
            await _locationService.getCoordinatesFromAddress(location);
        if (locationCoords != null) {
          setState(() {
            _selectedLocation = locationCoords;
            _selectedLocationName = location;
          });
          _mapController.move(locationCoords, 10);
        }
      } else {
        setState(() {
          _selectedLocation = coordinates;
          _selectedLocationName = location;
        });
        _mapController.move(coordinates, 10);
      }

      if (!_recentSearches.contains(location) &&
          location != "Current Location") {
        setState(() {
          if (_recentSearches.length >= 5) {
            _recentSearches.removeLast();
          }
          _recentSearches.insert(0, location);
        });

        _saveRecentSearches();
      }

      setState(() {
        _searchResults = [];
        _searchController.clear();
      });
    } catch (e) {
      _showError('Failed to select location');
    }
  }

  void _handleMapTap(TapPosition tapPosition, LatLng latLng) async {
    try {
      final address = await _locationService.getAddressFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      setState(() {
        _selectedLocation = latLng;
        _selectedLocationName = address ?? 'Selected Location';
      });
    } catch (e) {
      _showError('Failed to get location info');
    }
  }

  void _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permissions are permanently denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _selectedLocationName = address ?? 'Current Location';
      });
      _mapController.move(_selectedLocation!, 10);
    } catch (e) {
      _showError('Failed to get current location');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search here',
                                border: InputBorder.none,
                                suffixIcon: Icon(Icons.search),
                              ),
                              onChanged: _searchLocation,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _isSearching
                        ? const Center(child: CircularProgressIndicator())
                        : _searchResults.isNotEmpty
                            ? ListView.builder(
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading:
                                        const Icon(Icons.location_on_outlined),
                                    title: Text(_searchResults[index]),
                                    onTap: () {
                                      _selectLocation(_searchResults[index]);
                                    },
                                  );
                                },
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Text(
                                      'Recent locations',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),

                                  if (_recentSearches.isNotEmpty)
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _recentSearches.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          leading:
                                              const Icon(Icons.location_on),
                                          title: Text(_recentSearches[index]),
                                          onTap: () {
                                            _selectLocation(
                                                _recentSearches[index]);
                                          },
                                        );
                                      },
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Text(
                                        'No recent locations',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: FlutterMap(
                                          mapController: _mapController,
                                          options: MapOptions(
                                            initialCenter: _selectedLocation ??
                                                LatLng(0, 0),
                                            initialZoom: 10,
                                            onTap: _handleMapTap,
                                          ),
                                          children: [
                                            TileLayer(
                                              urlTemplate:
                                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                              subdomains: const ['a', 'b', 'c'],
                                              userAgentPackageName:
                                                  'com.example.weather_app',
                                            ),
                                            if (_selectedLocation != null)
                                              MarkerLayer(
                                                markers: [
                                                  Marker(
                                                    point: _selectedLocation!,
                                                    width: 40,
                                                    height: 40,
                                                    child: const Icon(
                                                      Icons.location_on,
                                                      color: Colors.red,
                                                      size: 40,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                  ),

                  if (_selectedLocationName != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, _selectedLocationName);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Confirm $_selectedLocationName',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
