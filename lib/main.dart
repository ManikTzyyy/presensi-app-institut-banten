import 'package:flutter/material.dart';
import 'package:aplikasi_presensi/home-page.dart';
import 'package:aplikasi_presensi/login-page.dart';
import 'package:aplikasi_presensi/simpan-page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
    );
  }
}

