# 🕵️‍♂️ StenoCrypt: Secure Intelligence Archives

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Security](https://img.shields.io/badge/Security-AES--256-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)

> **"Hidden in plain sight."**
>
> **StenoCrypt** is a mobile application designed for secure communication using **Image Steganography** and **AES-256 Encryption**. Wrapped in a retro-noir detective interface, it allows users to embed secret payloads into ordinary image files, turning your gallery into a hidden archive.

---

## 📱 Interface Preview

| **Dossier Home** | **Encode Operation** | **Decode Operation** | **Splash** | **About** |
|:---:|:---:|:---:|:---:|:---:|
| <img src="assets\screenshots\home.jpeg" width="200" alt="Home"> | <img src="assets\screenshots\encode.jpeg" width="200" alt="Encode"> | <img src="assets\screenshots\decode.jpeg" width="200" alt="Decode"> | <img src="assets\screenshots\splash.jpeg" width="200" alt="Splash"> | <img src="assets\screenshots\about.jpeg" width="200" alt="About"> |

---

## 🛠 Features

### 🔐 Military-Grade Security
* **Double-Layer Encryption:** Messages are first encrypted using **AES-256 (Advanced Encryption Standard)** before being embedded.
* **LSB Steganography:** The encrypted payload is injected into the **Least Significant Bits** of the image pixels, making the alteration invisible to the human eye.
* **Key-Based Access:** Decryption requires the exact custom key used during the encoding process.

### 🕵️‍♂️ Detective Experience (UI/UX)
* **Immersive Retro Design:** A "Top Secret" file aesthetic using typewriter fonts, folder textures (`AppColors.folder`), and ink-stamp styling.
* **Auto-Wipe Mechanism:** Decoded sensitive messages automatically self-destruct (wipe) from the screen after **30 seconds** to prevent prying eyes.
* **Integrity Verification:** The app verifies if the hidden message has been corrupted or tampered with during extraction.

### 📂 File Management
* **Secure Archiving:** Seamlessly saves "stego-images" to a dedicated album (`StenoCrypt Archives`) in the gallery.
* **Direct Dispatch:** Share encoded images directly to other apps (WhatsApp, Telegram, Mail) via the native share sheet.

---

## 🏗 Project Architecture

The project follows a clean, modular architecture to separate UI logic from cryptographic operations.

```text
lib/
├── core/
│   ├── constants/       # App-wide styles, colors (Paper/Ink themes)
│   └── utils/           # Helpers (File processors, Permission handlers)
├── cryptography/
│   ├── aes_cipher.dart  # AES-256 encryption/decryption logic
│   └── lsb_engine.dart  # Bitwise manipulation for LSB encoding/decoding
├── ui/
│   ├── screens/
│   │   ├── splash/      # Initial boot sequence
│   │   ├── dossier_home # Main dashboard
│   │   ├── encode_view  # Image processing & embedding UI
│   │   ├── decode_view  # Extraction & verification UI
│   │   └── about_view   # App information
└── main.dart            # Application entry point
```

## 🧪 The Science Behind It

### 1. AES Encryption
Before the message touches the image, it is passed through an encryption engine using a user-defined key. This ensures that even if the steganography is detected, the message remains unreadable without the password.

### 2. LSB (Least Significant Bit) Insertion
We utilize the **LSB algorithm**. An image consists of pixels, each containing Red, Green, and Blue values (0-255).

* **Concept:** Changing the last bit of a pixel's color value (e.g., changing binary `11111110` to `11111111`) changes the color so slightly that the human eye cannot detect the difference. 
* **Operation:** We break the encrypted message into binary bits and distribute them across the image's pixel data.

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
* An Android or iOS device/emulator.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/GigaFdlh/StenoCrypt-app.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd stenocrypt
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the application:**
    ```bash
    flutter run
    ```

---

## 📦 Key Dependencies

* `gal`: For saving images to the gallery.
* `share_plus`: For sharing files across applications.
* `image`: For pixel-level manipulation.
* `permission_handler`: For managing storage permissions.
* `encrypt`: For AES cryptographic operations.
* `google_fonts`: For the signature typewriter typography.

---

## 🤝 Contributing

Agents interested in improving the protocol are welcome to contribute.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
  <sub>Built with 🕵️‍♂️ & ☕ by <b>Giga Kurnia Fadhillah</b></sub>
</div>