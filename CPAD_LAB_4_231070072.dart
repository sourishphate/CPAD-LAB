// ============================================================
//  EXPERIMENT NO. 4 — Map Application Using Dart / Flutter
//  Aim   : Display an interactive map, show the user's current
//          location, and place markers using Google Maps Platform.
//  Author: Sourish  |  Roll No: 231070072  |  Batch: C
//  Institute: VJTI, Mumbai
//
//  Enhanced Features:
//  1. Map Type Switcher (Normal/Satellite/Hybrid/Terrain)
//  2. Polylines connecting all POI markers
//  3. Circle radius around current location
//  4. Bottom sheet on marker tap with POI details
//  5. Search bar to jump to any POI
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MapDemoApp());
}

// ─── Root Widget ─────────────────────────────────────────────────────────────
class MapDemoApp extends StatelessWidget {
  const MapDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraceMap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const MapScreen(),
    );
  }
}

// ─── Map Screen ──────────────────────────────────────────────────────────────
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controllerCompleter = Completer();

  LatLng? _currentLatLng;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<Circle> _circles = {};

  // FEATURE 1: Map type switcher
  MapType _currentMapType = MapType.normal;

  // FEATURE 5: Search
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _showSearchResults = false;

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(19.0222, 72.8561),
    zoom: 13,
  );

  // ── Points of Interest with categories ───────────────────────────────────
  static const List<Map<String, dynamic>> _pointsOfInterest = [
    {
      'id': 'vjti',
      'title': 'VJTI Mumbai',
      'snippet': 'Veermata Jijabai Technological Institute',
      'position': LatLng(19.0222, 72.8561),
      'category': 'education',
      'description':
          'One of the oldest and most prestigious technical institutes in India, established in 1887. Located in Matunga, Mumbai.',
    },
    {
      'id': 'bandra_worli',
      'title': 'Bandra–Worli Sea Link',
      'snippet': 'Iconic cable-stayed bridge over Mahim Bay',
      'position': LatLng(19.0407, 72.8183),
      'category': 'landmark',
      'description':
          'A cable-stayed bridge that spans the Mahim Bay connecting Bandra to Worli. Opened in 2009, it is 5.6 km long.',
    },
    {
      'id': 'gateway',
      'title': 'Gateway of India',
      'snippet': 'Historic arch monument on the waterfront',
      'position': LatLng(18.9220, 72.8347),
      'category': 'landmark',
      'description':
          'Built in 1924 to commemorate the visit of King George V and Queen Mary. A iconic symbol of Mumbai on the Apollo Bunder waterfront.',
    },
    {
      'id': 'dadar',
      'title': 'Dadar Station',
      'snippet': 'Major railway junction near VJTI',
      'position': LatLng(19.0178, 72.8478),
      'category': 'transport',
      'description':
          'One of the busiest railway stations in Mumbai, serving both Central and Western Railway lines. A key interchange point.',
    },
    {
      'id': 'marine_drive',
      'title': 'Marine Drive',
      'snippet': "The Queen's Necklace — iconic seafront boulevard",
      'position': LatLng(18.9432, 72.8236),
      'category': 'landmark',
      'description':
          'A 3.6 km long boulevard along the coast of South Mumbai. At night, the streetlights along the curved road resemble a necklace.',
    },
    {
      'id': 'cst',
      'title': 'CST Mumbai',
      'snippet': 'UNESCO Heritage railway terminus',
      'position': LatLng(18.9398, 72.8355),
      'category': 'transport',
      'description':
          'Chhatrapati Shivaji Maharaj Terminus — a UNESCO World Heritage Site and one of the finest examples of Victorian Gothic architecture in India.',
    },
  ];

  // Category → marker hue mapping
  static const Map<String, double> _categoryHue = {
    'education': BitmapDescriptor.hueViolet,
    'landmark': BitmapDescriptor.hueRed,
    'transport': BitmapDescriptor.hueOrange,
  };

  // Category → color for bottom sheet badge
  static const Map<String, Color> _categoryColor = {
    'education': Color(0xFF7B1FA2),
    'landmark': Color(0xFFD32F2F),
    'transport': Color(0xFFE65100),
  };

  static const Map<String, IconData> _categoryIcon = {
    'education': Icons.school,
    'landmark': Icons.account_balance,
    'transport': Icons.train,
  };

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _addPoiMarkers();
    _addPolyline();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controllerCompleter.future.then((c) => c.dispose());
    super.dispose();
  }

  // ── FEATURE 2: Polyline connecting all POIs ───────────────────────────────
  void _addPolyline() {
    final List<LatLng> points =
        _pointsOfInterest.map((p) => p['position'] as LatLng).toList();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('poi_route'),
        points: points,
        color: Colors.indigo,
        width: 3,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    );
  }

  // ── Location ──────────────────────────────────────────────────────────────
  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _snack('Location services are disabled. Enable them in device settings.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _snack('Location permission denied.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _snack('Location permanently denied. Enable in App Settings.');
      return;
    }

    await _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng latLng = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _currentLatLng = latLng;

        // Current location marker (azure/blue)
        _markers.removeWhere((m) => m.markerId.value == 'current_location');
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: latLng,
            zIndex: 10,
            infoWindow: const InfoWindow(
              title: 'You are here',
              snippet: 'Your current GPS location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );

        // FEATURE 3: Circle around current location
        _circles.clear();
        _circles.add(
          Circle(
            circleId: const CircleId('location_radius'),
            center: latLng,
            radius: 500, // 500 metres
            fillColor: Colors.indigo.withOpacity(0.12),
            strokeColor: Colors.indigo,
            strokeWidth: 2,
          ),
        );
      });

      _animateCameraTo(latLng, zoom: 15);
    } catch (e) {
      _snack('Could not fetch location: $e');
    }
  }

  // ── FEATURE 4: Markers with bottom sheet on tap ───────────────────────────
  void _addPoiMarkers() {
    for (final poi in _pointsOfInterest) {
      final hue = _categoryHue[poi['category']] ?? BitmapDescriptor.hueRed;
      _markers.add(
        Marker(
          markerId: MarkerId(poi['id'] as String),
          position: poi['position'] as LatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          onTap: () => _showPoiBottomSheet(poi),
        ),
      );
    }
  }

  void _showPoiBottomSheet(Map<String, dynamic> poi) {
    final category = poi['category'] as String;
    final color = _categoryColor[category] ?? Colors.indigo;
    final icon = _categoryIcon[category] ?? Icons.place;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category badge + title
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        category[0].toUpperCase() + category.substring(1),
                        style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              poi['title'] as String,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              poi['snippet'] as String,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              poi['description'] as String,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),

            // Go to location button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _animateCameraTo(poi['position'] as LatLng, zoom: 16);
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Focus on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FEATURE 1: Map type switcher ──────────────────────────────────────────
  void _showMapTypePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Map Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _mapTypeOption(
                  'Normal', Icons.map, MapType.normal, Colors.indigo),
              _mapTypeOption('Satellite', Icons.satellite_alt,
                  MapType.satellite, Colors.teal),
              _mapTypeOption(
                  'Hybrid', Icons.layers, MapType.hybrid, Colors.orange),
              _mapTypeOption(
                  'Terrain', Icons.terrain, MapType.terrain, Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _mapTypeOption(
      String label, IconData icon, MapType type, Color color) {
    final isSelected = _currentMapType == type;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? color : color.withOpacity(0.12),
        child: Icon(icon, color: isSelected ? Colors.white : color, size: 20),
      ),
      title: Text(label,
          style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? Icon(Icons.check_circle, color: color) : null,
      onTap: () {
        setState(() => _currentMapType = type);
        Navigator.pop(context);
      },
    );
  }

  // ── FEATURE 5: Search ─────────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }
    final results = _pointsOfInterest
        .where((poi) =>
            (poi['title'] as String)
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            (poi['snippet'] as String)
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
    setState(() {
      _searchResults = results;
      _showSearchResults = true;
    });
  }

  void _selectSearchResult(Map<String, dynamic> poi) {
    _searchController.clear();
    setState(() {
      _showSearchResults = false;
      _searchResults = [];
    });
    FocusScope.of(context).unfocus();
    _animateCameraTo(poi['position'] as LatLng, zoom: 16);
    Future.delayed(
        const Duration(milliseconds: 600), () => _showPoiBottomSheet(poi));
  }

  // ── Camera ────────────────────────────────────────────────────────────────
  Future<void> _animateCameraTo(LatLng target, {double zoom = 14}) async {
    final ctrl = await _controllerCompleter.future;
    ctrl.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  // ── Snackbar ──────────────────────────────────────────────────────────────
  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF283593), Color(0xFF3F51B5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Logo icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.explore,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Name + tagline
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TraceMap',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Explore · Discover · Navigate',
                        style: TextStyle(
                          color: Color(0xBBFFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Map type button
                  IconButton(
                    onPressed: _showMapTypePicker,
                    icon:
                        const Icon(Icons.layers_outlined, color: Colors.white),
                    tooltip: 'Map Type',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: _initialCamera,
            mapType: _currentMapType,
            onMapCreated: (GoogleMapController controller) {
              if (!_controllerCompleter.isCompleted) {
                _controllerCompleter.complete(controller);
              }
              if (_currentLatLng != null) {
                _animateCameraTo(_currentLatLng!, zoom: 15);
              }
            },
            markers: Set<Marker>.from(_markers),
            polylines: _polylines,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
            onTap: (_) {
              // Dismiss search results when tapping the map
              if (_showSearchResults) {
                setState(() => _showSearchResults = false);
                FocusScope.of(context).unfocus();
              }
            },
          ),

          // ── FEATURE 5: Search bar overlay ──────────────────────────────
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                // Search input
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search places...',
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.indigo),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                // Search results dropdown
                if (_showSearchResults && _searchResults.isNotEmpty)
                  Material(
                    elevation: 4,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12)),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final poi = _searchResults[i];
                          final category = poi['category'] as String;
                          final color =
                              _categoryColor[category] ?? Colors.indigo;
                          final icon = _categoryIcon[category] ?? Icons.place;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.12),
                              child: Icon(icon, color: color, size: 18),
                            ),
                            title: Text(poi['title'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(poi['snippet'] as String,
                                style: const TextStyle(fontSize: 12)),
                            onTap: () => _selectSearchResult(poi),
                          );
                        },
                      ),
                    ),
                  ),

                if (_showSearchResults && _searchResults.isEmpty)
                  Material(
                    elevation: 4,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12)),
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: const Text('No places found.',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
              ],
            ),
          ),

          // ── Legend (category colors) ────────────────────────────────────
          Positioned(
            bottom: 100,
            left: 12,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Legend',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 4),
                    _legendItem(
                        Icons.school, 'Education', const Color(0xFF7B1FA2)),
                    _legendItem(Icons.account_balance, 'Landmark',
                        const Color(0xFFD32F2F)),
                    _legendItem(
                        Icons.train, 'Transport', const Color(0xFFE65100)),
                    _legendItem(Icons.my_location, 'You', Colors.blue),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ── FAB: My Location ─────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_currentLatLng != null) {
            _animateCameraTo(_currentLatLng!, zoom: 15);
          } else {
            _initLocation();
          }
        },
        icon: const Icon(Icons.my_location),
        label: const Text('My Location'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _legendItem(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
