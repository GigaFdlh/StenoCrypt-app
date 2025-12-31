import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LSBEngine {
  static String generateHash(String text) {
    var bytes = utf8.encode(text);
    return sha256.convert(bytes).toString().substring(0, 8);
  }

  static Uint8List encodeMessage(Uint8List imageBytes, String message) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception("Gambar tidak dapat dibaca");
    }

    String hash = generateHash(message);

    String fullMessage = "$hash$message##END##";

    List<int> messageBytes = utf8.encode(fullMessage);

    bool hasAlpha = image.numChannels == 4;
    Uint8List pixels = image.getBytes();
    int currentPixelIndex = 0;

    for (int i = 0; i < messageBytes.length; i++) {
      int charCode = messageBytes[i];

      for (int bit = 7; bit >= 0; bit--) {
        if (currentPixelIndex >= pixels.length) {
          break;
        }

        if (hasAlpha && (currentPixelIndex + 1) % 4 == 0) {
          currentPixelIndex++;
        }

        int messageBit = (charCode >> bit) & 1;
        pixels[currentPixelIndex] =
            (pixels[currentPixelIndex] & 0xFE) | messageBit;
        currentPixelIndex++;
      }
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  static Map<String, String> decodeMessageWithIntegrity(Uint8List imageBytes) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      return {"status": "ERROR", "message": "Bukan file gambar valid"};
    }

    Uint8List pixels = image.getBytes();
    bool hasAlpha = image.numChannels == 4;

    List<int> decodedBytes = [];
    int currentByte = 0;
    int bitCount = 0;

    final List<int> terminator = [35, 35, 69, 78, 68, 35, 35];

    for (int i = 0; i < pixels.length; i++) {
      if (hasAlpha && (i + 1) % 4 == 0) {
        continue;
      }

      int bit = pixels[i] & 1;
      currentByte = (currentByte << 1) | bit;
      bitCount++;

      if (bitCount == 8) {
        decodedBytes.add(currentByte);
        currentByte = 0;
        bitCount = 0;

        if (decodedBytes.length >= terminator.length) {
          bool match = true;

          for (int j = 0; j < terminator.length; j++) {
            if (decodedBytes[decodedBytes.length - terminator.length + j] !=
                terminator[j]) {
              match = false;
              break;
            }
          }

          if (match) {
            try {
              List<int> validDataBytes = decodedBytes.sublist(
                0,
                decodedBytes.length - terminator.length,
              );

              String totalData = utf8.decode(validDataBytes);

              if (totalData.length < 8) {
                return {"status": "ERROR", "message": "Data terlalu pendek"};
              }

              String extractedHash = totalData.substring(0, 8);
              String actualMessage = totalData.substring(8);

              String computedHash = generateHash(actualMessage);

              return {
                "message": actualMessage,
                "status": (extractedHash == computedHash)
                    ? "VERIFIED"
                    : "COMPROMISED",
              };
            } catch (e) {
              return {"status": "ERROR", "message": "Gagal parsing data"};
            }
          }
        }
      }
    }

    return {"status": "ERROR", "message": "Marker tidak ditemukan"};
  }
}
