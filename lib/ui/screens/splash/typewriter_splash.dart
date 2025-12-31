import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';

class TypewriterSplash extends StatefulWidget {
  const TypewriterSplash({super.key});
  @override
  State<TypewriterSplash> createState() => _TypewriterSplashState();
}

class _TypewriterSplashState extends State<TypewriterSplash> {
  String text = "";
  String fullText = "STENO-CRYPT: ACCESSING ARCHIVES...";

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  void _startTypewriter() {
    int i = 0;
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          text += fullText[i];
          i++;
        });
      }
      if (i == fullText.length) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Courier', // Pastikan font ini ada di pubspec.yaml
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}