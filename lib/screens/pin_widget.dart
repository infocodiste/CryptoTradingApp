import 'package:coin_analyzer/utils/misc/box.dart';
import 'package:coin_analyzer/utils/misc/encryptions.dart';
import 'package:flutter/material.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:pinput/pin_put/pin_put_state.dart';

import '../loading_indicator.dart';
import '../theme_data.dart';

class PinWidget extends StatefulWidget {
  @override
  PinWidgetState createState() => new PinWidgetState();
}

class PinWidgetState extends State<PinWidget> {
  String pin = "";
  bool failed = false;
  final TextEditingController _pinPutController = TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(
          color: failed ? Colors.red : Theme.of(context).iconTheme.color),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              alignment: AlignmentDirectional.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.lock,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Enter 4 digit PIN",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 200,
                      child: PinPut(
                        focusNode: AlwaysDisabledFocusNode(),
                        obscureText: "*",
                        controller: _pinPutController,
                        fieldsCount: 4,
                        submittedFieldDecoration: _pinPutDecoration.copyWith(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        selectedFieldDecoration: _pinPutDecoration,
                        followingFieldDecoration: _pinPutDecoration.copyWith(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: failed
                                ? Colors.red
                                : Theme.of(context)
                                    .iconTheme
                                    .color
                                    .withOpacity(.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  failed
                      ? Text("Invalid Pin",
                          style: TextStyle(
                              color: Theme.of(context).iconTheme.color))
                      : Container()
                ],
              ),
            ),
          ),
          SizedBox(),
          SizedBox(),
          NumericKeyboard(
            onKeyboardTap: _onKeyboardTap,
            textColor: Theme.of(context).iconTheme.color,
            leftButtonFn: () {
              setState(() {
                if (pin.length == 0) return;
                pin = pin.substring(0, pin.length - 1);
                _pinPutController.text = pin;
              });
            },
            leftIcon: Icon(
              Icons.backspace,
            ),
            rightButtonFn: () {
              _decrypt(args);
            },
            rightIcon: Icon(
              Icons.check,
            ),
          ),
          SizedBox()
        ],
      ),
    );
  }

  _onKeyboardTap(String value) {
    if (pin.length >= 4) {
      return;
    }
    setState(() {
      pin = pin + value;
      _pinPutController.text = pin;
    });
  }

  _decrypt(args) async {
    if (pin.length != 4) {
      setState(() {
        failed = true;
      });
      return;
    }
    Dialogs.showLoadingDialog(context, _keyLoader);
    String salt = await BoxUtils.getSalt();
    String key = args;
    String decrypted = await Encryptions.decrypt(key, salt, pin);
    if (decrypted == Encryptions.failed) {
      setState(() {
        failed = true;
        pin = "";
        _pinPutController.text = "";
      });
      if (_keyLoader.currentContext == null) {
      } else {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }
    } else {
      if (_keyLoader.currentContext == null) {
        Navigator.pop(context, decrypted);
      } else {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      }
      Navigator.pop(context, decrypted);
    }
    return;
  }
}
