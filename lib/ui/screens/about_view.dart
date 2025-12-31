import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const Text("TECHNICAL DOSSIER", 
          style: TextStyle(fontFamily: 'Typewriter', fontWeight: FontWeight.bold, color: AppColors.ink)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(Icons.security, size: 50, color: AppColors.ink),
                  const SizedBox(height: 10),
                  const Text("PROJECT: STENOCRYPT", 
                    style: TextStyle(fontFamily: 'Typewriter', fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.ink)),
                  Text("v1.0.0 Stable Build", 
                    style: TextStyle(fontFamily: 'Typewriter', fontSize: 12, color: AppColors.ink.withValues(alpha: 0.5))),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            const Divider(color: AppColors.ink, thickness: 2),
            const SizedBox(height: 20),

            _buildSectionTitle("1. STEGANOGRAPHY PROTOCOL (LSB)"),
            _buildContentText(
                "The Least Significant Bit (LSB) method manipulates the last bit of pixel color components (RGB)."),
            _buildContentText(
                "Human eyes cannot distinguish color changes of 1 bit (1/255). This allows us to inject data without visible visual degradation."),
            
            _buildCodeBlock(
              "PIXEL MANIPULATION EXAMPLE:\n"
              "Original Pixel: [10101100] (Red)\n"
              "Payload Bit   : [.......1] (Injected)\n"
              "Final Pixel   : [10101101] (Modified)\n"
              ">> Visual change is undetectable."
            ),
            
            const SizedBox(height: 25),

            _buildSectionTitle("2. ENCRYPTION LAYER (AES-256)"),
            _buildContentText(
                "Before injection, the text payload is secured using Advanced Encryption Standard (AES) with a 256-bit symmetric key."),
            _buildContentText(
                "User passwords are hashed using SHA-256 to ensure the encryption key always meets the 32-byte requirement."),
            
            _buildCodeBlock(
              "INPUT : 'Top Secret Intel'\n"
              "KEY   : '123456'\n"
              "OUTPUT: 'U2FsdGVkX1+...'\n"
              ">> Data is unreadable without the key."
            ),

            const SizedBox(height: 25),

            _buildSectionTitle("3. INTEGRITY CHECK (SHA-256)"),
            _buildContentText(
                "To prevent data tampering, the system appends a Digital Signature (Hash) to the message header."),
            _buildContentText(
                "During decoding, the system compares the extracted Hash with a newly computed one. If they differ by even 1 character, the file is flagged as 'COMPROMISED'."),

            const SizedBox(height: 40),
            
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.stamp, width: 3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    const Text(
                      "CLASSIFIED DOCUMENT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Typewriter',
                        color: AppColors.stamp,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "DO NOT DISTRIBUTE OUTSIDE HQ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Typewriter',
                        color: AppColors.stamp.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Typewriter',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.stamp,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2, bottom: 8),
          height: 1,
          width: double.infinity,
          color: AppColors.stamp.withValues(alpha: 0.3),
        )
      ],
    );
  }

  Widget _buildContentText(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        content,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontFamily: 'Typewriter',
          fontSize: 13,
          color: AppColors.ink,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.ink),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 11,
          color: Colors.greenAccent,
          height: 1.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}