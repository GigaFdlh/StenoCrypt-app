import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/file_processor.dart';
import '../../cryptography/lsb_engine.dart';
import '../../cryptography/aes_cipher.dart';

class DecodeView extends StatefulWidget {
  const DecodeView({super.key});

  @override
  State<DecodeView> createState() => _DecodeViewState();
}

class _DecodeViewState extends State<DecodeView> {
  File? _selectedImage;
  final TextEditingController _passController = TextEditingController();

  String _decodedMessage = "";
  String _integrityStatus = "";
  bool _isProcessing = false;

  Timer? _wipeTimer;
  int _timeLeft = 0;

  @override
  void dispose() {
    _wipeTimer?.cancel();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await FileProcessor.pickImageFromGallery();
    if (image != null) {
      _stopTimer();
      setState(() {
        _selectedImage = image;
        _decodedMessage = "";
        _integrityStatus = "";
      });
    }
  }

  void _startAutoWipeTimer() {
    _stopTimer();
    setState(() => _timeLeft = 30);

    _wipeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _stopTimer();
        setState(() {
          _decodedMessage = "SESSION EXPIRED. EVIDENCE WIPED.";
          _passController.clear();
          _integrityStatus = "";
        });
      }
    });
  }

  void _stopTimer() {
    _wipeTimer?.cancel();
    setState(() => _timeLeft = 0);
  }

  Future<void> _processDecoding() async {
    if (_selectedImage == null || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing Intel: Image or Key required!")),
      );
      return;
    }

    _stopTimer();

    setState(() {
      _isProcessing = true;
      _decodedMessage = "";
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      final imageBytes = await _selectedImage!.readAsBytes();
      final Map<String, String> resultData =
          LSBEngine.decodeMessageWithIntegrity(imageBytes);

      if (resultData["status"] == "ERROR") {
        setState(
          () => _decodedMessage =
              "FAILED: No hidden data found or file compromised.",
        );
        return;
      }

      final String cipherText = resultData["message"]!;
      final String originalText = AESCipher.decryptText(
        cipherText,
        _passController.text,
      );

      if (originalText == "PASSWORD SALAH") {
        setState(
          () => _decodedMessage = "ACCESS DENIED: Invalid Decryption Key.",
        );
      } else {
        setState(() {
          _integrityStatus = resultData["status"]!;
          _decodedMessage = originalText;
        });
        _startAutoWipeTimer();
      }
    } catch (e) {
      setState(() => _decodedMessage = "SYSTEM ERROR: Corrupted Data Stream.");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const Text(
          "DECRYPT ARCHIVE",
          style: TextStyle(
            fontFamily: 'Typewriter',
            color: AppColors.ink,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.folder,
                  border: Border.all(color: AppColors.ink, width: 2),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 60,
                              color: AppColors.ink.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "TAP TO ANALYZE EVIDENCE",
                              style: TextStyle(
                                fontFamily: 'Typewriter',
                                color: AppColors.ink.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_selectedImage!, fit: BoxFit.cover),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "EVIDENCE LOADED",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            _buildSpyTextField(
              controller: _passController,
              hint: "ENTER DECRYPTION KEY...",
              icon: Icons.vpn_key,
              isObscure: true,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isProcessing || _selectedImage == null
                    ? null
                    : _processDecoding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: AppColors.paper,
                  elevation: 5,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isProcessing
                    ? const TerminalLoader(
                        logs: [
                          "READING PIXEL DATA...",
                          "EXTRACTING LSB BITS...",
                          "VERIFYING INTEGRITY...",
                          "DECRYPTING AES-256...",
                          "ACCESS GRANTED.",
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_open),
                          SizedBox(width: 10),
                          Text(
                            "EXTRACT & VERIFY",
                            style: TextStyle(
                              fontFamily: 'Typewriter',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(color: AppColors.ink, thickness: 1.5),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "DECRYPTED INTEL:",
                    style: TextStyle(
                      fontFamily: 'Typewriter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (_timeLeft > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "AUTO-WIPE: ${_timeLeft}s",
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (_integrityStatus.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _integrityStatus == "VERIFIED"
                        ? Colors.green
                        : Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _integrityStatus == "VERIFIED"
                            ? Icons.verified
                            : Icons.warning,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "DATA INTEGRITY: $_integrityStatus",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.folder,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.ink.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Text(
                _decodedMessage.isEmpty
                    ? "WAITING FOR DECRYPTION..."
                    : _decodedMessage,
                style: TextStyle(
                  fontFamily: 'Typewriter',
                  fontSize: 16,
                  color: _decodedMessage.contains("EXPIRED")
                      ? Colors.grey
                      : AppColors.ink,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSpyTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isObscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.folder,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(
          fontFamily: 'Typewriter',
          fontSize: 14,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.ink.withValues(alpha: 0.4)),
          prefixIcon: Icon(icon, color: AppColors.ink),
          filled: true,
          fillColor: AppColors.folder,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 10,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.ink.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.stamp, width: 2),
          ),
        ),
      ),
    );
  }
}

class TerminalLoader extends StatefulWidget {
  final List<String> logs;
  const TerminalLoader({super.key, required this.logs});

  @override
  State<TerminalLoader> createState() => _TerminalLoaderState();
}

class _TerminalLoaderState extends State<TerminalLoader> {
  String _currentLog = "";
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentLog = widget.logs[0];
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % widget.logs.length;
        _currentLog = widget.logs[_index];
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(
            color: AppColors.paper,
            strokeWidth: 2,
          ),
        ),
        const SizedBox(width: 15),
        SizedBox(
          width: 200,
          child: Text(
            "> $_currentLog",
            style: const TextStyle(
              fontFamily: 'Courier',
              color: AppColors.paper,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
