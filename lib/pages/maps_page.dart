import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapsPage extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng, String) onLocationSelected;

  const MapsPage({
    super.key,
    required this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late LatLng _selectedLocation;
  late MapController mapController;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    mapController = MapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mapController.move(_selectedLocation, 15);
    });
  }

  // ============================
  // 🔹 TAP MAP → PIN PINDAH
  // ============================
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    _getAddressFromCoordinates(point);
  }

  // ============================
  // 🔹 REVERSE GEOCODE
  // ============================
  Future<String> _getAddressFromCoordinates(LatLng point) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1',
        ),
        headers: {'User-Agent': 'FlutterApp/1.0 (contact@example.com)'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['display_name'] ?? 'Alamat tidak ditemukan';
      }
      return 'Alamat tidak ditemukan';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // ============================
  // 🔹 SEARCH ALAMAT → MOVE CAMERA
  // ============================
  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final url =
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'FlutterApp/1.0 (contact@example.com)'},
      );

      if (response.statusCode == 200) {
        final List results = json.decode(response.body);

        if (results.isNotEmpty) {
          final lat = double.parse(results[0]['lat']);
          final lon = double.parse(results[0]['lon']);
          final display = results[0]['display_name'];

          final newPoint = LatLng(lat, lon);

          setState(() {
            _selectedLocation = newPoint;
            _searchController.text = display;
          });

          mapController.move(newPoint, 16);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lokasi tidak ditemukan")),
          );
        }
      }
    } catch (e) {
      print("Search error: $e");
    }

    setState(() => _isSearching = false);
  }

  // ============================
  // 🔹 BUILD UI
  // ============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Lokasi')),

      body: Column(
        children: [
          // ============================
          // 🔍 SEARCH BAR
          // ============================
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari tempat…",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isSearching ? null : _searchLocation,
                  child: const Text("Cari"),
                ),
              ],
            ),
          ),

          // ============================
          // 🔹 MAP
          // ============================
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 15,
                onTap: _onMapTap,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ============================
          // 🔹 SIMPAN LOCATION BUTTON
          // ============================
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () async {
                final address = await _getAddressFromCoordinates(
                  _selectedLocation,
                );
                widget.onLocationSelected(_selectedLocation, address);
                Navigator.pop(context);
              },
              child: const Text("SIMPAN LOKASI"),
            ),
          ),
        ],
      ),
    );
  }
}
