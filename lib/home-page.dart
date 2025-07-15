import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;
import 'package:aplikasi_presensi/models/home-response.dart';
import 'package:aplikasi_presensi/simpan-page.dart';
import 'package:aplikasi_presensi/login-page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _name, _token;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];
  String pegawaiJabatan = "Saya Software Engineering";
  File? _customImage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    _name = prefs.getString("name");
    final imagePath = prefs.getString('customImagePath');
    if (imagePath != null) {
      _customImage = File(imagePath);
    }
    await _getData();
    setState(() {});
  }

  Future<void> _getData() async {
    try {
      final response = await myHttp.get(
        Uri.parse('https://azure-stingray-527018.hostingersite.com/api/get-presensi'),
        headers: {'Authorization': 'Bearer ${_token ?? ""}'},
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        homeResponseModel = HomeResponseModel.fromJson(jsonData);
        riwayat.clear();
        for (var item in homeResponseModel!.data) {
          item.isHariIni ? hariIni = item : riwayat.add(item);
        }
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('customImagePath', pickedFile.path);
      setState(() {
        _customImage = File(pickedFile.path);
      });
    }
  }

  Future<String> getName() async => _name ?? "-";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: Text("Presensi",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 22)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Yakin ingin keluar dari aplikasi?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                    ElevatedButton(onPressed: () {
                      Navigator.pop(context);
                      _logout();
                    }, child: const Text('Logout')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: getName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || homeResponseModel == null) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return RefreshIndicator(
            onRefresh: _getData,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildProfil(),
                const SizedBox(height: 24),
                Text("Hai, ${snapshot.data}",
                    style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildTodayCard(),
                const SizedBox(height: 32),
                Text("Riwayat Presensi",
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                ...riwayat.map((item) => _buildRiwayatItem(item)).toList(),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const SimpanPage()))
            .then((_) => setState(() {})),
        icon: const Icon(Icons.fingerprint),
        label: const Text("Presensi"),
        backgroundColor: const Color(0xFF4F46E5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildProfil() => InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundImage: _customImage != null
                    ? FileImage(_customImage!)
                    : const AssetImage('assets/avatar.jpg') as ImageProvider,
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name ?? "Nama Pegawai",
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(pegawaiJabatan,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[700])),
                ],
              )
            ],
          ),
        ),
      );

  Widget _buildTodayCard() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.deepPurple.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Presensi Hari Ini",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 10),
            Text(hariIni?.tanggal ?? '-',
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn("Masuk", hariIni?.masuk),
                _buildTimeColumn("Pulang", hariIni?.pulang),
              ],
            ),
          ],
        ),
      );

  Widget _buildRiwayatItem(Datum item) => InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.tanggal,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeDetail("Masuk", item.masuk),
                  _buildTimeDetail("Pulang", item.pulang),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildTimeColumn(String label, String? time) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time ?? '-',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
        ],
      );

  Widget _buildTimeDetail(String label, String? value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value ?? '-',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500)),
          Text(label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        ],
      );

  Widget _buildShimmerLoading() => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const ShimmerWidget.rectangular(height: 30, width: 150),
            const SizedBox(height: 20),
            const ShimmerWidget.card(height: 150),
            const SizedBox(height: 20),
            const ShimmerWidget.rectangular(height: 24, width: 200),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: ShimmerWidget.card(height: 80),
                ),
              ),
            ),
          ],
        ),
      );
}

class ShimmerWidget extends StatelessWidget {
  final double height, width;
  final ShapeBorder shape;

  const ShimmerWidget.rectangular({
    super.key,
    required this.height,
    this.width = double.infinity,
  }) : shape = const RoundedRectangleBorder();

  const ShimmerWidget.card({
    super.key,
    required this.height,
    this.width = double.infinity,
  }) : shape = const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        );

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: height,
          width: width,
          decoration: ShapeDecoration(
            color: Colors.grey.shade400,
            shape: shape,
          ),
        ),
      );
}
