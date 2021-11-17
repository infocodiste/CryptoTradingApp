import 'package:coin_analyzer/utils/misc/box.dart';
import 'package:coin_analyzer/utils/misc/encryptions.dart';
import 'package:coin_analyzer/utils/misc/hd_key.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:web3dart/credentials.dart';

import '../../constants.dart';
import '../../loading_indicator.dart';
import '../../theme_data.dart';

class LandingSetPinScreen extends StatefulWidget {
  @override
  LandingSetPinScreenState createState() => LandingSetPinScreenState();
}

class LandingSetPinScreenState extends State<LandingSetPinScreen> {
  TextEditingController pin = new TextEditingController();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  String seed;
  List args;
  bool failed = false;
  bool newMnemonic;
  bool isSeeds = true;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      color: Theme.of(context).primaryColor,
      border: Border.all(color: failed ? Colors.red : AppTheme.primaryColor),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  final FocusNode _pinPutFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    seed = args[0];
    newMnemonic = args[1];
    isSeeds = args[2];
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          "Set up a PIN",
        ),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Container(
              padding: EdgeInsets.all(AppTheme.paddingHeight12),
              child: Center(
                child: Card(
                  shape: AppTheme.cardShape,
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.paddingHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'PIN',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            SizedBox(
                              width: AppTheme.paddingHeight12 / 2,
                            ),
                            Text(
                              '*Must be atleast 4 numbers',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(color: Color(0xFFCB3A31)),
                            )
                          ],
                        ),
                        SizedBox(
                          height: AppTheme.paddingHeight12 / 3,
                        ),
                        Text(
                          "Set up a PIN to secure your wallet",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        SizedBox(
                          height: AppTheme.paddingHeight12,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 200,
                                child: PinPut(
                                  focusNode: _pinPutFocusNode,
                                  obscureText: "*",
                                  controller: pin,
                                  fieldsCount: 4,
                                  submittedFieldDecoration:
                                      _pinPutDecoration.copyWith(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  selectedFieldDecoration: _pinPutDecoration,
                                  followingFieldDecoration:
                                      _pinPutDecoration.copyWith(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                      color: failed
                                          ? Colors.red
                                          : AppTheme.primaryColor
                                              .withOpacity(.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        failed
                            ? Text("Invalid Pin",
                                style: TextStyle(color: Colors.red))
                            : Container()
                        // Container(
                        //   decoration: BoxDecoration(
                        //       borderRadius:
                        //           BorderRadius.circular(AppTheme.cardRadius),
                        //       color: AppTheme.warmgray_100,
                        //       shape: BoxShape.rectangle,
                        //       border:
                        //           Border.all(width: 1, color: AppTheme.purple_600)),
                        //   padding: EdgeInsets.symmetric(horizontal: 8),
                        //   child: TextFormField(
                        //     obscureText: true,
                        //     obscuringCharacter: "*",
                        //     maxLines: 1,
                        //     maxLength: 4,
                        //     controller: pin,
                        //     autovalidateMode: AutovalidateMode.onUserInteraction,
                        //     validator: (val) =>
                        //         val.length == 4 ? null : 'PIN must be of 4 numbers',
                        //     keyboardType: TextInputType.number,
                        //     decoration: InputDecoration(
                        //       fillColor: AppTheme.warmgray_100,
                        //       border: InputBorder.none,
                        //       focusedBorder: InputBorder.none,
                        //       labelStyle: AppTheme.label_medium
                        //           .copyWith(color: AppTheme.warmgray_600),
                        //       labelText: "PIN",
                        //       hintText: "Enter a PIN",
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: AppTheme.buttonHeight_44,
                margin:
                    EdgeInsets.symmetric(horizontal: AppTheme.paddingHeight12),
                child: TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: AppTheme.orange_500,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.buttonRadius))),
                  onPressed: _proceed,
                  child: Text(
                    'Continue',
                    style: AppTheme.label_medium
                        .copyWith(color: AppTheme.lightgray_700),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      //floatingActionButton: ,
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  _proceed() async {
    if (pin.text.length != 4) {
      setState(() {
        failed = true;
      });
      return;
    }
    if (pin.text.length != 4) {
      Fluttertoast.showToast(
          msg: "Invalid PIN",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    Dialogs.showLoadingDialog(context, _keyLoader);
    await Future.delayed(Duration(seconds: 1)).then((val) async {
      if (isSeeds) {
        var pkAddr = await HDKey.generateKey(seed.trim());
        var encrypted =
            await Encryptions.encrypt(seed.trim(), pkAddr[0], pin.text);
        BoxUtils.setFirstAccount(
            encrypted[0], encrypted[1], pkAddr[1], encrypted[2], pin.text);
      } else {
        var encrypted =
            await Encryptions.encryptPrivateKey(seed.trim(), pin.text);
        final private = EthPrivateKey.fromHex(seed.trim());
        final userAddress = await private.extractAddress();
        BoxUtils.setFirstAccount(
            null, encrypted[0], userAddress.hex, encrypted[1], pin.text);
      }
    });
    BoxUtils.setNewMnemonicBox(!newMnemonic);
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    Navigator.pushNamedAndRemoveUntil(
        context, myWalletRoute, ModalRoute.withName(homeRoute));
    // Navigator.of(context)
    //     .pushNamedAndRemoveUntil(myWalletRoute, ModalRoute.withName(homeRoute));
  }
}
