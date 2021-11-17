import 'package:flutter_string_encryption/flutter_string_encryption.dart';

import 'box.dart';

class Encryptions {
  static const failed = "failed";

  static Future<List<String>> encrypt(
      String mnemonic, String privateKey, String pin) async {
    final cryptor = new PlatformStringCryptor();
    final String salt = await cryptor.generateSalt();
    final String key = await cryptor.generateKeyFromPassword(pin, salt);
    final String eMnemonic = await cryptor.encrypt(mnemonic, key);
    final String ePk = await cryptor.encrypt(privateKey, key);
    return [eMnemonic, ePk, salt];
  }

  static Future<List<String>> encryptPrivateKey(
      String privateKey, String pin) async {
    final cryptor = new PlatformStringCryptor();
    final String salt = await cryptor.generateSalt();
    final String key = await cryptor.generateKeyFromPassword(pin, salt);
    final String ePk = await cryptor.encrypt(privateKey, key);
    return [ePk, salt];
  }

  static Future<List<String>> encryptWithSalt(
      String mnemonic, String privateKey, String pin, String salt) async {
    final cryptor = new PlatformStringCryptor();
    final String key = await cryptor.generateKeyFromPassword(pin, salt);
    final String eMnemonic = await cryptor.encrypt(mnemonic, key);
    final String ePk = await cryptor.encrypt(privateKey, key);
    return [eMnemonic, ePk];
  }

  static Future<String> decrypt(
      String encrypted, String salt, String pin) async {
    final cryptor = new PlatformStringCryptor();
    final String key = await cryptor.generateKeyFromPassword(pin, salt);
    String decrypted;
    try {
      decrypted = await cryptor.decrypt(encrypted, key);
    } catch (e) {
      decrypted = failed;
    }

    return decrypted;
  }

  static Future<String> encryptMessage(String message) async {
    final cryptor = new PlatformStringCryptor();
    final String key = await cryptor.generateKeyFromPassword(
        "0x000000000000000000000000000000000000dEaD", "DEAD");
    final String eMessage = await cryptor.encrypt(message, key);
    return eMessage;
  }

  static Future<String> decryptMessage(String message) async {
    final cryptor = new PlatformStringCryptor();
    final String key = await cryptor.generateKeyFromPassword(
        "0x000000000000000000000000000000000000dEaD", "DEAD");
    final String dMessage = await cryptor.decrypt(message, key);
    return dMessage;
  }
}
