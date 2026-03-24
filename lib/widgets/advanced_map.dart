// lib/widgets/advanced_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

enum MapMode {
  view, // Normal viewing mode
  select, // Select a single location
  draw, // Draw a path/route
  measure, // Measure distances
}

class AdvancedMap extends StatefulWidget {
  // Core configuration
  final LatLng? initialLocation;
  final double initialZoom;
  final double minZoom;
  final double maxZoom;
  final MapMode initialMode;

  // Features
  final bool showZoomControls;
  final bool showCurrentLocation;
  final bool showScaleBar;
  final bool showAttribution;
  final bool enableRotation;
  final bool enablePinching;

  // Data
  final List<Marker>? initialMarkers;
  final List<Polyline>? initialPolylines;
  final List<Polygon>? initialPolygons;
  final List<LatLng>? initialPath;

  // Callbacks
  final Function(LatLng)? onLocationSelected;
  final Function(LatLng)? onCurrentLocation;
  final Function(List<LatLng>)? onPathDrawn;
  final Function(double)? onDistanceMeasured;
  final Function(MapMode)? onModeChanged;
  final Function(LatLng, double)? onCameraMoved;

  // Styling
  final Color selectionColor;
  final Color pathColor;
  final Color measurementColor;
  final double pathWidth;
  final String? tileServerUrl;
  final Map<String, dynamic>? tileServerOptions;

  const AdvancedMap({
    super.key,
    this.onCurrentLocation,
    this.initialLocation,
    this.initialZoom = 13.0,
    this.minZoom = 3.0,
    this.maxZoom = 19.0,
    this.initialMode = MapMode.view,
    this.showZoomControls = true,
    this.showCurrentLocation = true,
    this.showScaleBar = true,
    this.showAttribution = true,
    this.enableRotation = false,
    this.enablePinching = true,
    this.initialMarkers,
    this.initialPolylines,
    this.initialPolygons,
    this.initialPath,
    this.onLocationSelected,
    this.onPathDrawn,
    this.onDistanceMeasured,
    this.onModeChanged,
    this.onCameraMoved,
    this.selectionColor = Colors.red,
    this.pathColor = Colors.blue,
    this.measurementColor = Colors.purple,
    this.pathWidth = 4.0,
    this.tileServerUrl,
    this.tileServerOptions,
  });

  @override
  State<AdvancedMap> createState() => AdvancedMapState();
}

class AdvancedMapState extends State<AdvancedMap>
    with TickerProviderStateMixin {
  Marker? _currentLocationMarker;
  late MapController _mapController;
  late MapMode _currentMode;
  late List<Marker> _markers;
  late List<Polyline> _polylines;
  late List<Polygon> _polygons;
  late List<LatLng> _pathPoints;
  LatLng? _selectedPoint;
  // LatLng? _measurementStart;
  // LatLng? _measurementEnd;
  final List<LatLng> _measurementPoints = [];
  bool _isDrawing = false;
  bool _isMeasuring = false;
  AnimationController? _pulseController;

  // For performance tracking (unused but kept for future use)
  // ignore: unused_field
  final int _frameCount = 0;
  double _currentZoom = 13.0;
  LatLng _currentCenter = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentMode = widget.initialMode;
    _markers = List.from(widget.initialMarkers ?? []);
    _polylines = List.from(widget.initialPolylines ?? []);
    _polygons = List.from(widget.initialPolygons ?? []);
    _pathPoints = List.from(widget.initialPath ?? []);
    _currentCenter = widget.initialLocation ?? const LatLng(51.5, -0.09);
    _currentZoom = widget.initialZoom;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerOnCurrentLocation();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentCenter,
            initialZoom: _currentZoom,
            minZoom: widget.minZoom,
            maxZoom: widget.maxZoom,
            interactionOptions: InteractionOptions(
              flags: _getInteractionFlags(),
            ),
            onTap: (tapPosition, point) => _handleMapTap(point),
            onLongPress: _handleMapLongPress,
            onPositionChanged: (position, hasGesture) {
              setState(() {
                _currentCenter = position.center;
                _currentZoom = position.zoom;
              });
              if (widget.onCameraMoved != null) {
                widget.onCameraMoved!(position.center, position.zoom);
              }
            },
          ),
          children: [
            // Tile Layer
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.ennius5.ssers',
              maxZoom: 19,
            ),

            if (_pathPoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _pathPoints,
                    color: _currentMode == MapMode.draw
                        ? widget.pathColor
                        : widget.measurementColor,
                    strokeWidth: widget.pathWidth,
                    // isDotted not available; remove if needed
                  ),
                ],
              ),

            // Existing Polylines
            if (_polylines.isNotEmpty) PolylineLayer(polylines: _polylines),

            // Existing Polygons
            if (_polygons.isNotEmpty) PolygonLayer(polygons: _polygons),
            if (_currentLocationMarker != null)
              MarkerLayer(markers: [_currentLocationMarker!]),
            // Markers Layer
            if (_markers.isNotEmpty) MarkerLayer(markers: _markers),

            // Selected Point Marker
            if (_selectedPoint != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPoint!,
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    child: _buildSelectionMarker(),
                  ),
                ],
              ),

            // Measurement Markers
            if (_measurementPoints.isNotEmpty)
              MarkerLayer(
                markers: List.generate(_measurementPoints.length, (index) {
                  final point = _measurementPoints[index];
                  return Marker(
                    point: point,
                    width: 40,
                    height: 40,
                    child: _buildMeasurementMarker(
                      index == 0
                          ? '1'
                          : '${index + 1}', // First point = 1, rest numbered
                    ),
                  );
                }),
              ),

            // Path/Polyline Layer

            // Scale Bar
            if (widget.showScaleBar)
              Positioned(bottom: 20, left: 20, child: _buildScaleBar()),

            // Attribution
            if (widget.showAttribution)
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
          ],
        ),

        // Custom Controls Overlay
        _buildControlsOverlay(),

        // Mode Indicator
        if (_currentMode != MapMode.view)
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getModeText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Measurement Result
        if (_measurementPoints.length > 1)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: _buildMeasurementCard(),
          ),
      ],
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      bottom: 20,
      right: 10,
      child: Column(
        children: [
          // Mode Selector Button
          _buildControlButton(
            icon: _getModeIcon(),
            onPressed: _cycleMode,
            tooltip: 'Change Mode',
          ),
          const SizedBox(height: 8),

          // Zoom In
          if (widget.showZoomControls)
            _buildControlButton(
              icon: Icons.add,
              onPressed: () => _mapController.move(
                _currentCenter,
                math.min(_currentZoom + 1, widget.maxZoom),
              ),
              tooltip: 'Zoom In',
            ),

          if (widget.showZoomControls) const SizedBox(height: 8),

          // Zoom Out
          if (widget.showZoomControls)
            _buildControlButton(
              icon: Icons.remove,
              onPressed: () => _mapController.move(
                _currentCenter,
                math.max(_currentZoom - 1, widget.minZoom),
              ),
              tooltip: 'Zoom Out',
            ),

          if (widget.showZoomControls) const SizedBox(height: 8),

          // Current Location
          if (widget.showCurrentLocation)
            _buildControlButton(
              icon: Icons.my_location,
              onPressed: _centerOnCurrentLocation,
              tooltip: 'My Location',
            ),

          const SizedBox(height: 8),

          // Clear All
          if (_selectedPoint != null || _pathPoints.isNotEmpty)
            _buildControlButton(
              icon: Icons.clear_all,
              onPressed: _clearAll,
              tooltip: 'Clear All',
              backgroundColor: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: backgroundColor == Colors.red
                  ? Colors.white
                  : Colors.black87,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionMarker() {
    return AnimatedBuilder(
      animation: _pulseController!,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40 + (20 * _pulseController!.value),
              height: 40 + (20 * _pulseController!.value),
              decoration: BoxDecoration(
                color: widget.selectionColor.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
            const Icon(Icons.location_on, color: Colors.red, size: 40),
          ],
        );
      },
    );
  }

  Widget _buildMeasurementMarker(String label) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: widget.measurementColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementCard() {
    final distance = _calculateTotalDistance(_measurementPoints);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Distance',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDistance(distance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // _measurementStart = null;
                // _measurementEnd = null;
                _measurementPoints.clear();
                _pathPoints.clear();
                _isMeasuring = false;
              });
              if (widget.onDistanceMeasured != null) {
                widget.onDistanceMeasured!(distance);
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _handleMapTap(LatLng point) {
    switch (_currentMode) {
      case MapMode.view:
        // Do nothing in view mode
        break;

      case MapMode.select:
        setState(() {
          _selectedPoint = point;
        });
        if (widget.onLocationSelected != null) {
          widget.onLocationSelected!(point);
        }
        break;

      case MapMode.draw:
        if (_isDrawing) {
          setState(() {
            _pathPoints.add(point);
          });
        } else {
          _startDrawing(point);
        }
        break;

      case MapMode.measure:
        setState(() {
          _measurementPoints.add(point);
          _pathPoints = List.from(_measurementPoints);
        });

        final totalDistance = _calculateTotalDistance(_measurementPoints);

        if (widget.onDistanceMeasured != null) {
          widget.onDistanceMeasured!(totalDistance);
        }
        break;
    }
  }

  void _handleMapLongPress(TapPosition tapPosition, LatLng point) {
    if (_currentMode == MapMode.draw && _isDrawing) {
      _finishDrawing();
    }
  }

  void _startDrawing(LatLng point) {
    setState(() {
      _isDrawing = true;
      _pathPoints.clear();
      _pathPoints.add(point);
    });
  }

  void _finishDrawing() {
    setState(() {
      _isDrawing = false;
    });
    if (widget.onPathDrawn != null && _pathPoints.length > 1) {
      widget.onPathDrawn!(_pathPoints);
    }
    _addPolylineFromPath();
  }

  void _addPolylineFromPath() {
    if (_pathPoints.length > 1) {
      setState(() {
        _polylines.add(
          Polyline(
            points: List.from(_pathPoints),
            color: widget.pathColor,
            strokeWidth: widget.pathWidth,
          ),
        );
        _pathPoints.clear();
      });
    }
  }

  void _cycleMode() {
    final modes = MapMode.values;
    final currentIndex = modes.indexOf(_currentMode);
    final nextIndex = (currentIndex + 1) % modes.length;

    setState(() {
      _currentMode = modes[nextIndex];
      _clearTemporaryData();
    });

    if (widget.onModeChanged != null) {
      widget.onModeChanged!(_currentMode);
    }

    _showModeToast();
  }

  void _clearTemporaryData() {
    setState(() {
      _selectedPoint = null;
      // _measurementStart = null;
      // _measurementEnd = null;
      _measurementPoints.clear();
      _pathPoints.clear();
      _isDrawing = false;
      _isMeasuring = false;
    });
  }

  void _clearAll() {
    setState(() {
      _selectedPoint = null;
      // _measurementStart = null;
      // _measurementEnd = null;
      _measurementPoints.clear();
      _pathPoints.clear();
      _markers.clear();
      _polylines.clear();
      _polygons.clear();
      _isDrawing = false;
      _isMeasuring = false;
    });
  }

  Future<void> _centerOnCurrentLocation() async {
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        return;
      }

      // 2. Check permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission permanently denied'),
          ),
        );
        return;
      }

      // 3. Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);

      // 4. Move map
      _mapController.move(latLng, 16);

      // Add marker
      setState(() {
        _currentCenter = latLng;
        _currentLocationMarker = Marker(
          point: latLng,
          width: 50,
          height: 50,
          child: const Icon(Icons.my_location, color: Colors.orange, size: 40),
        );
      });

      // Send data out
      if (widget.onCurrentLocation != null) {
        widget.onCurrentLocation!(latLng);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    }
  }

  double _calculateTotalDistance(List<LatLng> points) {
    double total = 0;
    for (int i = 0; i < points.length - 1; i++) {
      total += _calculateDistance(points[i], points[i + 1]);
    }
    return total;
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // meters
    final dLat = _toRadians(end.latitude - start.latitude);
    final dLon = _toRadians(end.longitude - start.longitude);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(start.latitude)) *
            math.cos(_toRadians(end.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  int _getInteractionFlags() {
    int flags = InteractiveFlag.drag;
    if (widget.enablePinching) flags |= InteractiveFlag.pinchZoom;
    if (widget.enableRotation) flags |= InteractiveFlag.rotate;
    return flags;
  }

  IconData _getModeIcon() {
    switch (_currentMode) {
      case MapMode.view:
        return Icons.visibility;
      case MapMode.select:
        return Icons.location_on;
      case MapMode.draw:
        return Icons.draw;
      case MapMode.measure:
        return Icons.straighten;
    }
  }

  String _getModeText() {
    switch (_currentMode) {
      case MapMode.view:
        return 'View Mode';
      case MapMode.select:
        return 'Select Mode - Tap to select location';
      case MapMode.draw:
        return 'Draw Mode - Tap to draw, long press to finish';
      case MapMode.measure:
        return 'Measure Mode - Tap two points';
    }
  }

  void _showModeToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getModeText()),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Public methods for external control
  void addMarker(LatLng point, {String? title}) {
    setState(() {
      _markers.add(
        Marker(
          point: point,
          width: 40,
          height: 40,
          child: Tooltip(
            message: title ?? 'Marker',
            child: const Icon(Icons.place, color: Colors.red),
          ),
        ),
      );
    });
  }

  void addPolyline(List<LatLng> points, {Color? color}) {
    setState(() {
      _polylines.add(
        Polyline(
          points: points,
          color: color ?? widget.pathColor,
          strokeWidth: widget.pathWidth,
        ),
      );
    });
  }

  void clearMarkers() {
    setState(() {
      _markers.clear();
    });
  }

  void centerOnPoint(LatLng point, {double? zoom}) {
    _mapController.move(point, zoom ?? _currentZoom);
  }

  Widget _buildScaleBar() {
    // Approximate meters per pixel
    final metersPerPixel = _getMetersPerPixel(
      _currentZoom,
      _currentCenter.latitude,
    );

    // Target ~100px width
    final scaleWidthPx = 100.0;
    final distanceMeters = metersPerPixel * scaleWidthPx;

    final roundedDistance = _roundDistance(distanceMeters);

    final adjustedWidth = roundedDistance / metersPerPixel;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: adjustedWidth, height: 4, color: Colors.black),
          const SizedBox(height: 4),
          Text(
            _formatDistance(roundedDistance),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  double _getMetersPerPixel(double zoom, double latitude) {
    const earthCircumference = 40075016.686; // meters
    return earthCircumference *
        math.cos(_toRadians(latitude)) /
        math.pow(2, zoom + 8);
  }

  double _roundDistance(double distance) {
    if (distance > 1000) {
      return (distance / 1000).round() * 1000;
    } else if (distance > 100) {
      return (distance / 100).round() * 100;
    } else if (distance > 10) {
      return (distance / 10).round() * 10;
    } else {
      return distance.roundToDouble();
    }
  }
}
