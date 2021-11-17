import 'package:coin_analyzer/models/credential_models/credentials_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants.dart';
import 'box.dart';

class CredentialManager {
  static Future<String> getPrivateKey(BuildContext context) async {
    CredentialsObject creds = await BoxUtils.getCredentialBox();
    var privateKey = await Navigator.pushNamed(context, pinWidgetRoute,
        arguments: creds.privateKey);
    return privateKey;
    // return "2d9d981613930466632a285395355ffed26b38f7697c6787ee8e27f1811ec07b";
  }

  static Future<String> getMnemonic(BuildContext context) async {
    CredentialsObject creds = await BoxUtils.getCredentialBox();

    var mnemonic = await Navigator.pushNamed(context, pinWidgetRoute,
        arguments: creds.mnemonic);

    return mnemonic;
  }

  static Future<String> getAddress() async {
    CredentialsObject creds = await BoxUtils.getCredentialBox();
    var address = creds.address;
    return address;
    // return "0xf605fC4FC37DeD5aa5DeC06Ec3764567B7245352";
  }
}
