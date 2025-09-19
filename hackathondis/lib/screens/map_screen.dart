import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

// --- DATA MODEL for Parking Zones ---

class ParkingZone {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final int totalSpots;
  int occupiedSpots; // Changed to non-final to allow updates
  final double pricePerHour;
  bool isHighlighted = false;

  ParkingZone({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.totalSpots,
    required this.occupiedSpots,
    required this.pricePerHour,
  });

  int get availableSpots => totalSpots - occupiedSpots;
  double get occupancyRate => occupiedSpots / totalSpots;
}

// --- RESERVATION DATA MODEL ---
class ParkingReservation {
  final String id;
  final ParkingZone zone;
  final DateTime fromTime;
  final DateTime toTime;
  final double totalCost;
  
  ParkingReservation({
    required this.id,
    required this.zone,
    required this.fromTime,
    required this.toTime,
    required this.totalCost,
  });
  
  Duration get duration => toTime.difference(fromTime);
}

// --- MAIN WIDGET ---

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  List<ParkingZone> parkingZones = []; // Use a list directly
  LatLng? currentLocation;
  AnimationController? _mapAnimationController;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isMapLoading = true; // Add loading state

  // --- State for Parking Functionality ---
  ParkingZone? _activeParkingSession;
  DateTime? _parkingStartTime;
  Timer? _parkingTimer;
  
  // --- State for Reservation Functionality ---
  List<ParkingReservation> _reservations = [];

  @override
  void initState() {
    super.initState();
    _initializeMapAndData();
    // Optionally start location tracking automatically
    // _startLocationTracking(); // Uncomment if you want auto-tracking
  }

  Future<void> _initializeMapAndData() async {
    LatLng initialCenter =
        await _loadLastPosition() ?? const LatLng(36.775, 3.058); // Algiers Center
    
    // Try to get current location first
    await _fetchCurrentUserLocation(moveCamera: false);
    final dataCenter = currentLocation ?? initialCenter;

    final zones = await _generateMockParkingZones(dataCenter, 2); // Display only 2 real parking zones
    if (mounted) {
      setState(() {
        parkingZones = zones;
        _isMapLoading = false; // Set loading to false
        // If we have current location, center on it, otherwise use last position
        if (currentLocation != null) {
          mapController.move(currentLocation!, 14.0);
        } else {
          mapController.move(dataCenter, 14.0);
        }
        _highlightNearbyZones();
      });
    }
  }

  // --- REAL WORLD PARKING ZONES ---
  Future<List<ParkingZone>> _generateMockParkingZones(
    LatLng center,
    int count,
  ) async {
    await Future.delayed(
        const Duration(milliseconds: 300)); // Simulate network latency
    final random = math.Random();
    
    // Real parking locations in Algiers with actual coordinates
    final List<Map<String, dynamic>> realParkingLocations = [
      {
        'name': 'Ardis Mall Parking',
        'address': 'Hydra, Alger',
        'location': LatLng(36.7387, 3.144436),
        'totalSpots': 250,
        'pricePerHour': 150.0,
      },
      {
        'name': 'Centre Commercial Bab Ezzouar',
        'address': 'Bab Ezzouar, Alger',
        'location': LatLng(36.7125, 3.1978),
        'totalSpots': 180,
        'pricePerHour': 120.0,
      },
      {
        'name': 'Sofia Parking',
        'address': 'Alger Centre, Alger',
        'location': LatLng(36.7712, 3.0597),
        'totalSpots': 150,
        'pricePerHour': 180.0,
      },
    ];

    // Take only the requested number of zones or all available if count is larger
    final selectedLocations = realParkingLocations.take(count).toList();
    
    return selectedLocations.asMap().entries.map((entry) {
      final index = entry.key;
      final location = entry.value;
      
      // Random occupancy between 10% and 85% for realistic availability
      final totalSpots = location['totalSpots'] as int;
      final occupiedSpots = (totalSpots * (0.1 + random.nextDouble() * 0.75)).round();

      return ParkingZone(
        id: 'real_zone_$index',
        name: location['name'] as String,
        address: location['address'] as String,
        location: location['location'] as LatLng,
        totalSpots: totalSpots,
        occupiedSpots: occupiedSpots,
        pricePerHour: location['pricePerHour'] as double,
      );
    }).toList();
  }

  // --- LOCATION & MAP LOGIC ---
  Future<LatLng?> _loadLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('last_map_lat');
    final lng = prefs.getDouble('last_map_lng');
    return (lat != null && lng != null) ? LatLng(lat, lng) : null;
  }

  Future<void> _saveLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final center = mapController.camera.center;
    await prefs.setDouble('last_map_lat', center.latitude);
    await prefs.setDouble('last_map_lng', center.longitude);
  }

  Future<void> _fetchCurrentUserLocation({bool moveCamera = true}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them in settings.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied. Cannot show current position.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission permanently denied. Please enable in app settings.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium, // Changed from high to medium for better performance
          timeLimit: const Duration(seconds: 10), // Add timeout to prevent hanging
      );
      if (mounted) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
        });
        if (moveCamera) {
          _animatedMapMove(currentLocation!, 15.0); // Reduced zoom for smoother animation
        }
        _highlightNearbyZones();
        
        // Show success message when location is found
        if (moveCamera) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Current location found!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get current location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to start continuous location tracking
  void _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) return;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.medium, // Changed to medium for better performance
      distanceFilter: 15, // Increased to 15 meters to reduce updates
      timeLimit: Duration(seconds: 30), // Add timeout for location updates
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
        });
        _highlightNearbyZones();
      }
    });
  }

  // Method to stop location tracking
  void _stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  void _highlightNearbyZones() {
    if (currentLocation == null) return;
    setState(() {
      for (var zone in parkingZones) {
        final distance = Geolocator.distanceBetween(
          currentLocation!.latitude,
          currentLocation!.longitude,
          zone.location.latitude,
          zone.location.longitude,
        );
        // Highlight zones within 1km with available spots
        zone.isHighlighted = (distance < 1000 && zone.availableSpots > 0);
      }
    });
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    _mapAnimationController?.dispose();
    _mapAnimationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this); // Reduced duration for smoother animation
    final latTween = Tween<double>(
        begin: mapController.camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.camera.center.longitude, end: destLocation.longitude);
    final zoomTween =
        Tween<double>(begin: mapController.camera.zoom, end: destZoom);
    final animation = CurvedAnimation(
        parent: _mapAnimationController!, curve: Curves.easeInOut); // Changed curve for smoother animation

    _mapAnimationController!.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _mapAnimationController!.dispose();
        _mapAnimationController = null;
      }
    });
    _mapAnimationController!.forward();
  }

  void _onZoneTapped(ParkingZone zone) {
    _animatedMapMove(zone.location, 16.5);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ParkingDetailsSheet(
        zone: zone,
        currentLocation: currentLocation,
        onBookSpot: (bookedZone) {
          Navigator.pop(context); // Close the sheet first
          _showReservationDialog(bookedZone);
        },
      ),
    );
  }

  // --- RESERVATION FUNCTIONALITY ---
  void _showReservationDialog(ParkingZone zone) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: ReservationDialog(zone: zone),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
    );
  }
  
  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }
  
  Duration _calculateDuration(TimeOfDay from, TimeOfDay to) {
    final fromMinutes = _timeToMinutes(from);
    final toMinutes = _timeToMinutes(to);
    return Duration(minutes: toMinutes - fromMinutes);
  }
  
  void _makeReservation(ParkingZone zone, DateTime date, TimeOfDay fromTime, TimeOfDay toTime) {
    final fromDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      fromTime.hour,
      fromTime.minute,
    );
    
    final toDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      toTime.hour,
      toTime.minute,
    );
    
    final duration = toDateTime.difference(fromDateTime);
    final totalCost = (duration.inMinutes / 60) * zone.pricePerHour;
    
    final reservation = ParkingReservation(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      zone: zone,
      fromTime: fromDateTime,
      toTime: toDateTime,
      totalCost: totalCost,
    );
    
    setState(() {
      _reservations.add(reservation);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Reservation Confirmed!', 
                      style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${zone.name}'),
                    Text('${fromTime.format(context)} - ${toTime.format(context)}'),
                    Text('Cost: ${totalCost.toStringAsFixed(2)} DA'),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- PARKING FUNCTIONALITY ---
  void _startParking(ParkingZone zone) {
    setState(() {
      _activeParkingSession = zone;
      _parkingStartTime = DateTime.now();
      zone.occupiedSpots++; // Simulate taking a spot
      // Start a timer to update the UI every second
      _parkingTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) => setState(() {}));
    });
  }

  void _endParking() {
    setState(() {
      if (_activeParkingSession != null) {
        _activeParkingSession!.occupiedSpots--; // Free up the spot
      }
      _activeParkingSession = null;
      _parkingStartTime = null;
      _parkingTimer?.cancel();
    });
  }

  @override
  void dispose() {
    _mapAnimationController?.dispose();
    _parkingTimer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const ModernAppBar(title: 'ParkDZ Finder'),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation ?? const LatLng(36.775, 3.058),
              initialZoom: 14.0,
              minZoom: 10.0,
              maxZoom: 18.0,
              // Performance optimizations
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) _saveLastPosition();
              },
              // Reduce animation jank
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(35.0, 1.0), // Southwest Algeria
                  const LatLng(38.0, 5.0), // Northeast Algeria
                ),
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.hackathondis',
                // Performance optimizations
                maxZoom: 18,
                maxNativeZoom: 18,
                tileSize: 256,
                // Better caching
                retinaMode: false, // Disable retina for better performance
                // Error handling
                errorTileCallback: (tile, error, stackTrace) {
                  debugPrint('Tile error: $error');
                },
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 80, // Reduced for better performance
                  size: const Size(35, 35), // Slightly smaller
                  centerMarkerOnClick: true,
                  spiderfyCluster: false, // Disable for better performance
                  markers: [
                    ...parkingZones.map(
                      (zone) => Marker(
                        width: 110,
                        height: 60,
                        point: zone.location,
                        child: GestureDetector(
                          onTap: () => _onZoneTapped(zone),
                          child: _activeParkingSession?.id == zone.id
                              ? const _ActiveParkingMarker()
                              : _ParkingZoneMarker(zone: zone),
                        ),
                      ),
                    ),
                    if (currentLocation != null)
                      Marker(
                        point: currentLocation!,
                        width: 80,
                        height: 80,
                        child: const _UserLocationMarker(),
                      ),
                  ],
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blueAccent,
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Loading overlay
          if (_isMapLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading map...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Location tracking buttons
          Positioned(
            bottom: _activeParkingSession != null ? 120 : 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Continuous tracking toggle button
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    if (_positionStreamSubscription != null) {
                      _stopLocationTracking();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Location tracking stopped'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      _startLocationTracking();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Continuous location tracking started'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  backgroundColor: _positionStreamSubscription != null 
                      ? Colors.green 
                      : Colors.grey.shade600,
                  tooltip: _positionStreamSubscription != null 
                      ? 'Stop location tracking' 
                      : 'Start location tracking',
                  heroTag: 'tracking_button',
                  child: Icon(
                    _positionStreamSubscription != null 
                        ? Icons.location_on 
                        : Icons.location_off,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                // Get current location button
                FloatingActionButton(
                  onPressed: () => _fetchCurrentUserLocation(),
                  backgroundColor: Colors.blueAccent,
                  tooltip: 'Go to my location',
                  heroTag: 'location_button',
                  child: const Icon(Icons.gps_fixed, color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(top: 10, left: 10, child: _buildLegend()),
          if (_activeParkingSession != null && _parkingStartTime != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ActiveParkingCard(
                zone: _activeParkingSession!,
                startTime: _parkingStartTime!,
                onEndParking: _endParking,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegendItem(Colors.greenAccent, 'Many Spots'),
          _buildLegendItem(Colors.orangeAccent, 'Few Spots'),
          _buildLegendItem(Colors.redAccent, 'Full / Almost Full'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 12)),
        ],
      ),
    );
  }
}

// --- CUSTOM WIDGETS FOR MAP & UI ---

class _ParkingZoneMarker extends StatelessWidget {
  const _ParkingZoneMarker({required this.zone});
  final ParkingZone zone;

  @override
  Widget build(BuildContext context) {
    final availableColor = _getZoneColor(zone.occupancyRate);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              zone.isHighlighted ? Colors.amber.shade600 : Colors.grey.shade400,
          width: zone.isHighlighted ? 2.0 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.car, color: availableColor, size: 14),
              const SizedBox(width: 6),
              Text(
                '${zone.availableSpots}',
                style: TextStyle(
                  color: availableColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${zone.pricePerHour.toInt()} DA/hr',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveParkingMarker extends StatelessWidget {
  const _ActiveParkingMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.indigoAccent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
              color: Colors.black54, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: const Center(
        child: Text(
          'P',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

class _UserLocationMarker extends StatefulWidget {
  const _UserLocationMarker();

  @override
  __UserLocationMarkerState createState() => __UserLocationMarkerState();
}

class __UserLocationMarkerState extends State<_UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing ring
          FadeTransition(
            opacity: Tween<double>(begin: 0.8, end: 0.0)
                .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.2)
                  .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.3),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1),
                ),
              ),
            ),
          ),
          // Inner accuracy circle
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withOpacity(0.2),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1),
            ),
          ),
          // Center dot
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _getZoneColor(double occupancyRate) {
  if (occupancyRate >= 0.9) return Colors.red.shade600;
  if (occupancyRate > 0.7) return Colors.orange.shade600;
  return Colors.green.shade600;
}

// --- UI COMPONENTS (AppBar, Bottom Sheets) ---

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const ModernAppBar({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) => AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const FaIcon(FontAwesomeIcons.squareParking, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
      );
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ParkingDetailsSheet extends StatelessWidget {
  final ParkingZone zone;
  final LatLng? currentLocation;
  final Function(ParkingZone) onBookSpot;

  const ParkingDetailsSheet({
    Key? key,
    required this.zone,
    this.currentLocation,
    required this.onBookSpot,
  }) : super(key: key);

  void _openDirections(LatLng destination) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final distance = currentLocation != null
        ? Geolocator.distanceBetween(
              currentLocation!.latitude,
              currentLocation!.longitude,
              zone.location.latitude,
              zone.location.longitude,
            ) /
            1000
        : null;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        // FIX: Wrap the ListView's children in padding to prevent overflow
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              zone.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${distance?.toStringAsFixed(1) ?? '--'} km away - ${zone.address}',
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '${zone.availableSpots} / ${zone.totalSpots} spots free',
                  style: TextStyle(
                    color: _getZoneColor(zone.occupancyRate),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${zone.pricePerHour.toInt()} DA / hour',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: zone.occupancyRate,
                minHeight: 8,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getZoneColor(zone.occupancyRate),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
                  zone.availableSpots > 0 ? () => onBookSpot(zone) : null,
              icon: const FaIcon(FontAwesomeIcons.bookmark, size: 16),
              label: const Text('Book a Spot'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _openDirections(zone.location),
              icon: const Icon(Icons.directions_car),
              label: const Text('Get Directions'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveParkingCard extends StatelessWidget {
  final ParkingZone zone;
  final DateTime startTime;
  final VoidCallback onEndParking;

  const ActiveParkingCard({
    Key? key,
    required this.zone,
    required this.startTime,
    required this.onEndParking,
  }) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final duration = DateTime.now().difference(startTime);
    final cost = (duration.inMinutes / 60) * zone.pricePerHour;

    return Card(
      margin: const EdgeInsets.all(12),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.squareParking,
                    color: Colors.indigoAccent, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACTIVE PARKING',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      zone.name,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.grey, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text('Duration', style: TextStyle(color: Colors.black54)),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Est. Cost', style: TextStyle(color: Colors.black54)),
                    Text(
                      '${cost.toStringAsFixed(2)} DA',
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onEndParking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('End', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- MODERN RESERVATION DIALOG ---
class ReservationDialog extends StatefulWidget {
  final ParkingZone zone;

  const ReservationDialog({Key? key, required this.zone}) : super(key: key);

  @override
  State<ReservationDialog> createState() => _ReservationDialogState();
}

class _ReservationDialogState extends State<ReservationDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  DateTime selectedDate = DateTime.now();
  TimeOfDay fromTime = TimeOfDay.now();
  late TimeOfDay toTime;

  @override
  void initState() {
    super.initState();
    
    // Initialize with valid future times in Algiers timezone
    final currentAlgiersTime = _getCurrentAlgiersTime();
    final nextHour = TimeOfDay(
      hour: (currentAlgiersTime.hour + 1) % 24,
      minute: currentAlgiersTime.minute,
    );
    
    // Set fromTime to next hour or current time + 15 minutes if it's in the future
    if (_isTimeInFuture(TimeOfDay(hour: currentAlgiersTime.hour, minute: currentAlgiersTime.minute + 15))) {
      fromTime = TimeOfDay(hour: currentAlgiersTime.hour, minute: currentAlgiersTime.minute + 15);
    } else {
      fromTime = nextHour;
    }
    
    // Set toTime to be 59 minutes after fromTime
    toTime = TimeOfDay(
      hour: fromTime.hour + (fromTime.minute >= 1 ? 1 : 0),
      minute: (fromTime.minute + 59) % 60,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  Duration _calculateDuration(TimeOfDay from, TimeOfDay to) {
    final fromMinutes = _timeToMinutes(from);
    final toMinutes = _timeToMinutes(to);
    return Duration(minutes: toMinutes - fromMinutes);
  }

  // Get current time in Algiers timezone (UTC+1)
  TimeOfDay _getCurrentAlgiersTime() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 1)); // Algiers is UTC+1
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

  // Check if a time is in the future (after current Algiers time)
  bool _isTimeInFuture(TimeOfDay time) {
    final currentTime = _getCurrentAlgiersTime();
    final currentMinutes = _timeToMinutes(currentTime);
    final selectedMinutes = _timeToMinutes(time);
    return selectedMinutes > currentMinutes;
  }

  // Validate time selection
  bool _isValidTimeSelection(TimeOfDay fromTime, TimeOfDay toTime) {
    // Check if fromTime is in the future
    if (!_isTimeInFuture(fromTime)) {
      return false;
    }
    // Check if toTime is after fromTime
    return _timeToMinutes(toTime) > _timeToMinutes(fromTime);
  }

  void _makeReservation() {
    final mapScreenState = context.findAncestorStateOfType<_MapScreenState>();
    if (mapScreenState != null) {
      mapScreenState._makeReservation(widget.zone, selectedDate, fromTime, toTime);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final duration = _calculateDuration(fromTime, toTime);
    final cost = (duration.inMinutes / 60) * widget.zone.pricePerHour;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 50),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.local_parking_rounded,
                            color: Colors.blue.shade600,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reserve Parking',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                widget.zone.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Date Display with Current Time
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.blue.shade600),
                              const SizedBox(width: 12),
                              Text(
                                'Today, ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.blue.shade600, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Current time (Algiers): ${_getCurrentAlgiersTime().format(context)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Time Selection
                    const Text(
                      'Select Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeSelector(
                            'From',
                            fromTime,
                            Icons.access_time,
                            Colors.green,
                            () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: fromTime,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      timePickerTheme: TimePickerThemeData(
                                        backgroundColor: Colors.white,
                                        hourMinuteShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        dayPeriodShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                // Validate that the picked time is in the future
                                if (!_isTimeInFuture(picked)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.access_time, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('Reservation must be after current time'),
                                        ],
                                      ),
                                      backgroundColor: Colors.orange.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                
                                setState(() {
                                  fromTime = picked;
                                  // Auto-adjust toTime to be at least 30 minutes after fromTime
                                  final minToTime = TimeOfDay(
                                    hour: fromTime.hour + (fromTime.minute >= 30 ? 1 : 0),
                                    minute: fromTime.minute >= 30 ? fromTime.minute - 30 : fromTime.minute + 30,
                                  );
                                  if (_timeToMinutes(toTime) <= _timeToMinutes(minToTime)) {
                                    toTime = minToTime;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeSelector(
                            'To',
                            toTime,
                            Icons.access_time_filled,
                            Colors.orange,
                            () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: toTime,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      timePickerTheme: TimePickerThemeData(
                                        backgroundColor: Colors.white,
                                        hourMinuteShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        dayPeriodShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                // Validate that toTime is after fromTime with minimum duration
                                final minToTimeMinutes = _timeToMinutes(fromTime) + 30; // Minimum 30 minutes
                                final pickedMinutes = _timeToMinutes(picked);
                                
                                if (pickedMinutes <= _timeToMinutes(fromTime)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.warning, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('End time must be after start time'),
                                        ],
                                      ),
                                      backgroundColor: Colors.red.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                } else if (pickedMinutes < minToTimeMinutes) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.schedule, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('Minimum reservation duration is 30 minutes'),
                                        ],
                                      ),
                                      backgroundColor: Colors.orange.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    toTime = picked;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Summary Card
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple.shade50, Colors.purple.shade100],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.purple.shade200),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Duration',
                                          style: TextStyle(
                                            color: Colors.purple.shade600,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${duration.inHours}h ${duration.inMinutes.remainder(60)}m',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Total Cost',
                                          style: TextStyle(
                                            color: Colors.purple.shade600,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${cost.toStringAsFixed(2)} DA',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isValidTimeSelection(fromTime, toTime) ? _makeReservation : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline),
                                const SizedBox(width: 8),
                                const Text(
                                  'Confirm Reservation',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay time, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}