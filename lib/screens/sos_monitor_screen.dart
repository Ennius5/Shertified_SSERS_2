import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/advanced_map.dart'; // assume SosTile is in a separate file

class SosMonitorScreen extends StatefulWidget {
  const SosMonitorScreen({super.key});

  @override
  State<SosMonitorScreen> createState() => _SosMonitorScreenState();
}

class _SosMonitorScreenState extends State<SosMonitorScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GlobalKey<AdvancedMapState> _mapKey = GlobalKey();
  StreamSubscription<Position>? _positionStream;
LatLng? _activeSosPoint;

void _startTracking(LatLng sosPoint) {
  _positionStream?.cancel(); // stop previous tracking
  _activeSosPoint = sosPoint;

  _positionStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // update every ~5 meters
    ),
  ).listen((position) {
    final current = LatLng(position.latitude, position.longitude);

    // Update markers + route
    _mapKey.currentState?.clearMarkers();
_mapKey.currentState?.addMarker(
  current,
  title: "You",
  color: Colors.green, // 👈 respondent = green
);

_mapKey.currentState?.addMarker(
  _activeSosPoint!,
  title: "SOS",
  color: Colors.red, // 👈 victim = red
);

    _mapKey.currentState?.drawRoute(current, _activeSosPoint!);
  });
}

void _stopTracking() {
  _positionStream?.cancel();
  _positionStream = null;
  _activeSosPoint = null;
}

  Map<String, double> progressMap = {}; // docId -> progress
  Map<String, Timer> timerMap = {};     // docId -> timer
  String _searchQuery = '';             // search query

  LatLng? _extractLatLng(Map<String, dynamic> data) {
    if (data['lat'] != null && data['lng'] != null) {
      return LatLng(data['lat'], data['lng']);
    }
    final message = data['message'] ?? '';
    final regex = RegExp(r'q=([-0-9.]+),([-0-9.]+)');
    final match = regex.firstMatch(message);
    if (match != null) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);
      if (lat != null && lng != null) return LatLng(lat, lng);
    }
    return null;
  }

Future<void> _moveToLocation(LatLng sosPoint) async {
  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );

  final current = LatLng(position.latitude, position.longitude);

  // Move camera
  _mapKey.currentState?.centerOnPoint(sosPoint, zoom: 19);

  // Initial draw
  _mapKey.currentState?.clearMarkers();
_mapKey.currentState?.addMarker(
  current,
  title: "You",
  color: Colors.green,
);

_mapKey.currentState?.addMarker(
  sosPoint,
  title: "SOS",
  color: Colors.red,
);
  _mapKey.currentState?.drawRoute(current, sosPoint);

  // 🔥 Start live tracking
  _startTracking(sosPoint);
}

  Future<void> _toggleStatus(String docId, String currentStatus) async {
    final newStatus = currentStatus == "pending" ? "resolved" : "pending";
    Map<String, dynamic> updateData = {
      "status": newStatus,
    };
    if (newStatus == "resolved") {
      updateData['resolvedAt'] = FieldValue.serverTimestamp();
    } else {
      updateData['resolvedAt'] = null;
    }
    await firestore.collection("sos_events").doc(docId).update(updateData);
    setState(() {
      progressMap[docId] = 0.0;
    });
  }

  void _startProgress(String docId, String status) {
    const totalDuration = 5; // seconds
    const tick = 0.05;
    timerMap[docId]?.cancel();
    timerMap[docId] = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        progressMap[docId] = (progressMap[docId] ?? 0.0) + tick / totalDuration;
        if ((progressMap[docId] ?? 0.0) >= 1.0) {
          progressMap[docId] = 1.0;
          _toggleStatus(docId, status);
          timer.cancel();
        }
      });
    });
  }

  void _stopProgress(String docId) {
    timerMap[docId]?.cancel();
    setState(() {
      progressMap[docId] = 0.0;
    });
  }

@override
void dispose() {
  _stopTracking(); // 🔥 prevent memory leaks
  timerMap.values.forEach((t) => t.cancel());
  super.dispose();
}

Future<LatLng?> _getCurrentLocation() async {
  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return LatLng(position.latitude, position.longitude);
  } catch (e) {
    return null;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SOS Monitor")),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: AdvancedMap(
              key: _mapKey,
              initialLocation: const LatLng(7.92, 125.09),
              initialZoom: 19,
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.blueGrey.shade900,
                  width: double.infinity,
                  child: const Text(
                    "Hold an SOS tile to toggle its status",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search SOS messages...",
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection("sos_events")
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No SOS events"));
                      }

                      List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                      // Filter by search query
                      if (_searchQuery.isNotEmpty) {
                        docs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final message = (data['message'] ?? '').toString().toLowerCase();
                          return message.contains(_searchQuery);
                        }).toList();
                      }

                      // Sort pending first
                      docs.sort((a, b) {
                        final statusA = (a.data() as Map<String, dynamic>)['status'] ?? '';
                        final statusB = (b.data() as Map<String, dynamic>)['status'] ?? '';
                        if (statusA == 'pending' && statusB != 'pending') return -1;
                        if (statusA != 'pending' && statusB == 'pending') return 1;
                        return 0;
                      });

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final coords = _extractLatLng(data);

                          return SosTile(
                            data: data,
                            docId: doc.id,
                            coords: coords,
                            onTap: _moveToLocation,
                            toggleStatus: _toggleStatus,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SosTile extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;
  final LatLng? coords;
  final void Function(LatLng) onTap;
  final Future<void> Function(String, String) toggleStatus;

  const SosTile({
    super.key,
    required this.data,
    required this.docId,
    required this.coords,
    required this.onTap,
    required this.toggleStatus,
  });

  @override
  State<SosTile> createState() => _SosTileState();
}





class _SosTileState extends State<SosTile> {
  double progress = 0.0;
  Timer? timer;

  void _startProgress() {
    const totalDuration = 5; // seconds
    const tick = 0.05;

    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() {
        progress += tick / totalDuration;
        if (progress >= 1.0) {
          progress = 1.0;
          widget.toggleStatus(widget.docId, widget.data['status'] ?? 'pending');
          t.cancel();
        }
      });
    });
  }

  void _stopProgress() {
    timer?.cancel();
    setState(() {
      progress = 0.0;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
 @override
Widget build(BuildContext context) {
  final status = widget.data['status'] ?? 'unknown';
  final message = widget.data['message'] ?? '';
  final timestamp = widget.data['timestamp'];
  final isPending = status == "pending";
  final resolvedTimestamp = widget.data['resolvedAt'] as Timestamp?;
  String resolvedText = resolvedTimestamp != null
    ? "Resolved: ${resolvedTimestamp.toDate().toLocal().toString().split('.').first}"
    : "Pending";
  Color tileColor =
      isPending ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2);


  return GestureDetector(
    onTap: widget.coords != null ? () => widget.onTap(widget.coords!) : null,
    onLongPressStart: (_) => _startProgress(),
    onLongPressEnd: (_) => _stopProgress(),
    child: Card(
      color: tileColor,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: Text(
              message,
              style: TextStyle(
                color: isPending ? Colors.red : Colors.green[800],
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  timestamp != null
                      ? (timestamp as Timestamp).toDate().toString()
                      : "No time",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(width: 10),
                Text(
                  resolvedText,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            trailing: Text(
              status,
              style: TextStyle(
                color: isPending ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            
          ),
          // Linear progress bar at the bottom
          if (progress > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                minHeight: 6,
              ),
            ),
        ],
      ),
    ),
  );
}
}