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
        fontFamily: 'Courier',
        primaryColor: AppColors.ink,
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.stamp,
          primary: AppColors.ink,
        ),
      ),

      home: const TypewriterSplashWrapper(),
    );
  }
}

class TypewriterSplashWrapper extends StatefulWidget {
  const TypewriterSplashWrapper({super.key});

  @override
  State<TypewriterSplashWrapper> createState() =>
      _TypewriterSplashWrapperState();
}

class _TypewriterSplashWrapperState extends State<TypewriterSplashWrapper> {
  @override
  void initState() {
    super.initState();

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
