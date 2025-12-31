import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AESCipher {
  static encrypt.Key _generateKey(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);

    return encrypt.Key(Uint8List.fromList(digest.bytes));
  }

  static String encryptText(String text, String password) {
    try {
      final key = _generateKey(password);

      final iv = encrypt.IV.fromUtf8("1234567890123456");

      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encrypt(text, iv: iv);

      return encrypted.base64;
    } catch (e) {
      throw Exception("Gagal Enkripsi: $e");
    }
  }

  static String decryptText(String encryptedBase64, String password) {
    try {
      final key = _generateKey(password);

      final iv = encrypt.IV.fromUtf8("1234567890123456");

      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);

      return decrypted;
    } catch (e) {
      return "PASSWORD SALAH";
    }
  }
}
