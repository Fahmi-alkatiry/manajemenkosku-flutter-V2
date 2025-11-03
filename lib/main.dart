// lib/main.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:kosku_app/providers/properti_provider.dart'; // <-- 1. IMPORT BARU
import 'package:kosku_app/screens/login_screen.dart';
import 'package:kosku_app/screens/admin/admin_home_screen.dart';
import 'package:kosku_app/screens/penyewa/penyewa_home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ===================================
    // ==  UBAH MENJADI MULTIPROVIDER   ==
    // ===================================
    return MultiProvider(
      providers: [
        // 1. Provider untuk Auth (Tidak berubah)
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        
        // 2. Provider untuk Properti (BARU)
        // Ini akan "mendengarkan" AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, PropertiProvider>(
          // 'create' menginisialisasi provider (bahkan jika kosong)
          create: (ctx) => PropertiProvider(Provider.of<AuthProvider>(ctx, listen: false)),
          // 'update' memberikan instance baru saat AuthProvider berubah (login/logout)
          update: (ctx, auth, previousProperti) => PropertiProvider(auth),
        ),
      ],
      // 'child'-nya adalah MaterialApp Anda
      child: MaterialApp(
        title: 'Kosku App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) {
            // (Logika ini tidak berubah, sudah benar)
            if (auth.isAuth) {
              return auth.isAdmin ? const AdminHomeScreen() : const PenyewaHomeScreen();
            } else {
              return FutureBuilder(
                future: auth.tryAutoLogin(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(body: Center(child: CircularProgressIndicator()));
                  }
                  return const LoginScreen();
                },
              );
            }
          },
        ),
      ),
    );
  }
}