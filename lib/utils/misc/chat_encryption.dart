import 'package:flutter_string_encryption/flutter_string_encryption.dart';

class ChatEncryption {
  static const failed = "failed";

  static ChatEncryption _instance = ChatEncryption._internal();
  static final cryptor = new PlatformStringCryptor();

  static String key;

  ChatEncryption._internal();

  static ChatEncryption get() {
    return _instance;
  }

  Future<String> encryptMessage(String message) async {
    if (key == null) {
      key = await cryptor.generateKeyFromPassword(
          "0x000000000000000000000000000000000000dEaD", "DEAD");
    }
    final String eMessage = await cryptor.encrypt(message, key);
    return eMessage;
  }

  Future<String> decryptMessage(String message) async {
    final String dMessage = await cryptor.decrypt(message, key);
    return dMessage;
  }
}
