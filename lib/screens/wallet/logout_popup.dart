import 'package:coin_analyzer/models/credential_models/credentails_list_model.dart';
import 'package:coin_analyzer/utils/misc/box.dart';
import 'package:coin_analyzer/utils/misc/credential_manager.dart';
import 'package:coin_analyzer/utils/misc/wc_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';

import '../../constants.dart';


class PopUpDialogLogout {
  static showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () async {
        var cred = await BoxUtils.getCredentialBox();
        var mnemonic;
        var message;
        if (cred != null && cred.mnemonic != null && cred.mnemonic.isNotEmpty) {
          mnemonic = await CredentialManager.getMnemonic(context);
          message = "Your mnemonic is copied to clipboard";
        } else if (cred != null &&
            cred.privateKey != null &&
            cred.privateKey.isNotEmpty) {
          mnemonic = await CredentialManager.getPrivateKey(context);
          message = "Your private key is copied to clipboard";
        }

        if (mnemonic != null) {
          Clipboard.setData(new ClipboardData(text: mnemonic));
          Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
        } else {
          WCHandler.disconnect(context);
        }
        var creds = await Hive.openBox<CredentialsList>(credentialBox);
        await creds.clear();
        creds.close();
        Navigator.pushNamedAndRemoveUntil(
            context, homeRoute, ModalRoute.withName(homeRoute));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      title: Text("Alert"),
      content: Text(
        "You will not be able to get access this account without having the mnemonic, make sure to back it up.",
        style: TextStyle(color: Colors.red),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
