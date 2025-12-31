import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'encode_view.dart';
import 'decode_view.dart';
import 'about_view.dart';

class DossierHome extends StatefulWidget {
  const DossierHome({super.key});

  @override
  State<DossierHome> createState() => _DossierHomeState();
}

class _DossierHomeState extends State<DossierHome> {
  DateTime? currentBackPressTime;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PRESS BACK AGAIN TO ABORT MISSION"),
          backgroundColor: AppColors.ink,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),

                _buildMenuCard(
                  context,
                  title: "ENCODE OPERATION",
                  subtitle: "Conceal intelligence within media assets.",
                  icon: Icons.fingerprint,
                  accentColor: AppColors.stamp,
                  onTap: () => _navigate(context, const EncodeView()),
                ),

                const SizedBox(height: 20),

                _buildMenuCard(
                  context,
                  title: "DECRYPT ARCHIVE",
                  subtitle: "Extract hidden data from seized assets.",
                  icon: Icons.lock_open_outlined,
                  accentColor: AppColors.ink,
                  onTap: () => _navigate(context, const DecodeView()),
                ),

                const SizedBox(height: 20),

                _buildMenuCard(
                  context,
                  title: "MISSION PROTOCOL",
                  subtitle: "System specifications and security clearance.",
                  icon: Icons.shield_outlined,
                  accentColor: AppColors.folder,
                  onTap: () => _navigate(context, const AboutView()),
                ),

                const Spacer(),

                Center(
                  child: Column(
                    children: [
                      Text(
                        "RESTRICTED ACCESS - LEVEL 5",
                        style: TextStyle(
                          fontFamily: 'Typewriter',
                          color: AppColors.stamp.withValues(alpha: 0.6),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Secure Channel v1.0.0",
                        style: TextStyle(
                          fontFamily: 'Typewriter',
                          fontSize: 10,
                          color: AppColors.ink.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.security,
                color: AppColors.paper,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            const Text(
              "STENOCRYPT",
              style: TextStyle(
                fontFamily: 'Typewriter',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(height: 2, width: 60, color: AppColors.stamp),
        const SizedBox(height: 10),
        const Text(
          "DIGITAL INTELLIGENCE AGENCY",
          style: TextStyle(
            fontFamily: 'Typewriter',
            color: AppColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.15),
                offset: const Offset(0, 8),
                blurRadius: 15,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: accentColor),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Typewriter',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Typewriter',
                        fontSize: 11,
                        color: AppColors.ink.withValues(alpha: 0.7),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: accentColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
