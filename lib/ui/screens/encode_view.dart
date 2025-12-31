import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart'; 
import 'package:permission_handler/permission_handler.dart'; 

import '../../core/constants/app_colors.dart';
import '../../core/utils/file_processor.dart';
import '../../cryptography/lsb_engine.dart';
import '../../cryptography/aes_cipher.dart';

class EncodeView extends StatefulWidget {
  const EncodeView({super.key});

  @override
  State<EncodeView> createState() => _EncodeViewState();
}

class _EncodeViewState extends State<EncodeView> {
  File? _selectedImage;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isProcessing = false;
  
  // PASSWORD STRENGTH VARS
  double _passwordStrength = 0.0;
  String _strengthLabel = "NO KEY";
  Color _strengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _generateRandomKey() {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890!@#\$%^&*';
    Random rnd = Random();
    String newKey = String.fromCharCodes(Iterable.generate(
      12, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    
    setState(() {
      _passwordController.text = newKey;
    });
  }

  void _checkPasswordStrength() {
    String pass = _passwordController.text;
    if (pass.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _strengthLabel = "NO KEY";
        _strengthColor = Colors.grey;
      });
      return;
    }

    double strength = 0;
    if (pass.length > 6) strength += 0.2;
    if (pass.length > 10) strength += 0.2;
    if (pass.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (pass.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (pass.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength += 0.2;

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.4) {
        _strengthLabel = "WEAK";
        _strengthColor = Colors.red;
      } else if (strength <= 0.8) {
        _strengthLabel = "MODERATE";
        _strengthColor = Colors.orange;
      } else {
        _strengthLabel = "SECURE";
        _strengthColor = Colors.green;
      }
    });
  }

  Future<void> _pickImage() async {
    final image = await FileProcessor.pickImageFromGallery();
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _saveAndShareImage(Uint8List bytes) async {
    try {
      await Permission.photos.request();
      final directory = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '${directory.path}/STENO_$timestamp.png';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      await Gal.putImage(file.path, album: "StenoCrypt Archives");
      if (mounted) _showSuccessDialog(file.path);
    } catch (e) {
      debugPrint("Failed: $e");
    }
  }

  void _showSuccessDialog(String path) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.paper, // Dialog tetap warna kertas agar kontras
        shape: RoundedRectangleBorder(
           side: const BorderSide(color: AppColors.ink, width: 2),
           borderRadius: BorderRadius.circular(20) 
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.ink),
            SizedBox(width: 10),
            Text("MISSION SUCCESS", style: TextStyle(fontFamily: 'Typewriter', fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("The document has been sealed and archived to Gallery.",
            style: TextStyle(fontFamily: 'Typewriter', fontSize: 13)),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink, 
              foregroundColor: Colors.white, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            onPressed: () async {
              // ignore: deprecated_member_use
              await Share.shareXFiles([XFile(path)], text: 'StenoCrypt Intelligence Report');
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text("DISPATCH", style: TextStyle(fontFamily: 'Typewriter')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("RETURN TO HQ", 
              style: TextStyle(color: AppColors.stamp, fontFamily: 'Typewriter', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _processEncoding() async {
    if (_selectedImage == null || _messageController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Missing Intel: Image, Payload, or Key required!")));
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1500)); 

    try {
      String encryptedText = AESCipher.encryptText(_messageController.text, _passwordController.text);
      final imageBytes = await _selectedImage!.readAsBytes();
      final Uint8List resultBytes = LSBEngine.encodeMessage(imageBytes, encryptedText);
      await _saveAndShareImage(resultBytes);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper, // Background utama tetap kertas
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const Text("ENCODE OPERATION", 
          style: TextStyle(fontFamily: 'Typewriter', color: AppColors.ink, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // IMAGE AREA
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.folder, // UPDATE: Menggunakan warna folder
                  border: Border.all(color: AppColors.ink, width: 2),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.ink.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(4, 4))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 60, color: AppColors.ink.withValues(alpha: 0.5)),
                            const SizedBox(height: 10),
                            Text("TAP TO ATTACH EVIDENCE", style: TextStyle(fontFamily: 'Typewriter', color: AppColors.ink.withValues(alpha: 0.6))),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_selectedImage!, fit: BoxFit.cover),
                            Positioned(
                              bottom: 10, right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text("TARGET ACQUIRED", style: TextStyle(color: Colors.green, fontSize: 10, fontFamily: 'Courier')),
                              ),
                            )
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            
            // INPUT MESSAGE
            _buildSpyTextField(
              controller: _messageController,
              hint: "SECRET PAYLOAD (MESSAGE)...",
              icon: Icons.message,
              maxLines: 3,
            ),
            
            const SizedBox(height: 15),
            
            // INPUT PASSWORD
            Container(
              decoration: BoxDecoration(
                color: AppColors.folder, // UPDATE: Menggunakan warna folder
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.ink.withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(2, 2))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(fontFamily: 'Typewriter', fontSize: 14, color: AppColors.ink),
                      decoration: InputDecoration(
                        hintText: "ENCRYPTION KEY...",
                        hintStyle: TextStyle(color: AppColors.ink.withValues(alpha: 0.4)),
                        prefixIcon: const Icon(Icons.vpn_key, color: AppColors.ink),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.casino, color: AppColors.stamp),
                          tooltip: "Generate Secure Key",
                          onPressed: _generateRandomKey,
                        ),
                        filled: true,
                        fillColor: AppColors.folder, // UPDATE: Menggunakan warna folder
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                    ),
                    LinearProgressIndicator(
                      value: _passwordStrength == 0 ? 0.05 : _passwordStrength,
                      backgroundColor: AppColors.ink.withValues(alpha: 0.1),
                      color: _strengthColor,
                      minHeight: 4,
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("KEY SECURITY: ", style: TextStyle(fontFamily: 'Typewriter', fontSize: 10)),
                  Text(_strengthLabel, style: TextStyle(fontFamily: 'Typewriter', fontSize: 10, fontWeight: FontWeight.bold, color: _strengthColor)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processEncoding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.stamp,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isProcessing 
                  ? const TerminalLoader(
                      logs: ["INITIALIZING CORE...", "GENERATING AES KEY...", "ENCRYPTING PAYLOAD...", "WRITING LSB DATA...", "SEALING ARCHIVE..."],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline),
                        SizedBox(width: 10),
                        Text("SEAL & ARCHIVE", style: TextStyle(fontFamily: 'Typewriter', fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpyTextField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.folder, // UPDATE: Menggunakan warna folder
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(2, 2))],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontFamily: 'Typewriter', fontSize: 14, color: AppColors.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.ink.withValues(alpha: 0.4)),
          prefixIcon: Icon(icon, color: AppColors.ink),
          filled: true,
          fillColor: AppColors.folder, // UPDATE: Menggunakan warna folder
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.ink.withValues(alpha: 0.5), width: 1)
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.stamp, width: 2)
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
        const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
        const SizedBox(width: 15),
        SizedBox(
          width: 200,
          child: Text("> $_currentLog", style: const TextStyle(fontFamily: 'Courier', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}