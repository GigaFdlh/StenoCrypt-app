import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'ui/screens/splash/typewriter_splash.dart';
import 'ui/screens/dossier_home.dart';

void main() {
  runApp(const StenoCrypt());
}

class StenoCrypt extends StatelessWidget {
  const StenoCrypt({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StenoCrypt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Menggunakan font Courier sebagai default agar nuansa mesin ketik terasa di semua halaman
        fontFamily: 'Courier', 
        primaryColor: AppColors.ink,
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.stamp,
          primary: AppColors.ink,
        ),
      ),
      // Alur: Muncul Splash Screen selama beberapa detik, lalu pindah ke DossierHome
      home: const TypewriterSplashWrapper(), 
    );
  }
}

// Wrapper untuk Splash agar otomatis pindah ke Home
class TypewriterSplashWrapper extends StatefulWidget {
  const TypewriterSplashWrapper({super.key});

  @override
  State<TypewriterSplashWrapper> createState() => _TypewriterSplashWrapperState();
}

class _TypewriterSplashWrapperState extends State<TypewriterSplashWrapper> {
  @override
  void initState() {
    super.initState();
    // Setelah 4 detik (waktu animasi ketik selesai), pindah ke Home
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DossierHome()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const TypewriterSplash();
  }
}