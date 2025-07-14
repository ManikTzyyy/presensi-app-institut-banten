import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:aplikasi_presensi/models/save-presensi-response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as myHttp;
import 'package:google_fonts/google_fonts.dart';

class SimpanPage extends StatefulWidget {
  const SimpanPage({super.key});

  @override
  State<SimpanPage> createState() => _SimpanPageState();
}

class _SimpanPageState extends State<SimpanPage> {
  late Future<String> _token;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((prefs) => prefs.getString("token") ?? "");
  }

  Future<LocationData?> _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled && !await location.requestService()) return null;

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied &&
        await location.requestPermission() != PermissionStatus.granted) {
      return null;
    }

    return await location.getLocation();
  }

  Future<void> savePresensi(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) return;

    final headers = {'Authorization': 'Bearer ${await _token}'};
    final body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };

    try {
      final response = await myHttp.post(
        Uri.parse('http://127.0.0.1:8000/api/save-presensi'),
        headers: headers,
        body: body,
      );

      final responseModel = SavePresensiResponseModel.fromJson(
        json.decode(response.body),
      );

      final message = responseModel.success
          ? "✅ Presensi berhasil disimpan"
          : "❌ Gagal menyimpan presensi";

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              responseModel.success ? Colors.green : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (responseModel.success && mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan saat menyimpan presensi."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "Presensi Lokasi",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FutureBuilder<LocationData?>(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Tidak dapat mengakses lokasi."));
          }

          final currentLocation = snapshot.data!;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        height: 280,
                        child: SfMaps(
                          layers: [
                            MapTileLayer(
                              initialFocalLatLng: MapLatLng(
                                currentLocation.latitude!,
                                currentLocation.longitude!,
                              ),
                              initialZoomLevel: 15,
                              initialMarkersCount: 1,
                              urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              markerBuilder: (context, index) => MapMarker(
                                latitude: currentLocation.latitude!,
                                longitude: currentLocation.longitude!,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 38,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Lokasi Saat Ini",
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Lat: ${currentLocation.latitude?.toStringAsFixed(6)}\nLng: ${currentLocation.longitude?.toStringAsFixed(6)}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      savePresensi(
                        currentLocation.latitude,
                        currentLocation.longitude,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            "Simpan Presensi",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
